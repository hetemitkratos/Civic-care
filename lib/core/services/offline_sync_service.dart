
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'offline_storage_service.dart';
import 'connectivity_service.dart';
import '../models/offline_report_model.dart';
import '../../features/reports/data/repositories/supabase_reports_repository.dart';
import '../../features/reports/domain/entities/report_entity.dart';

class OfflineSyncService {
  final OfflineStorageService _storageService;
  final ConnectivityService _connectivityService;
  final SupabaseReportsRepository _reportsRepository;

  OfflineSyncService({
    required OfflineStorageService storageService,
    required ConnectivityService connectivityService,
    required SupabaseReportsRepository reportsRepository,
  })  : _storageService = storageService,
        _connectivityService = connectivityService,
        _reportsRepository = reportsRepository;

  // Sync all unsynced reports when connection is available
  Future<SyncResult> syncOfflineReports() async {
    if (!_connectivityService.isOnline) {
      return SyncResult(
        success: false,
        message: 'No internet connection available',
        syncedCount: 0,
        failedCount: 0,
      );
    }

    final unsyncedReports = await _storageService.getUnsyncedReports();
    if (unsyncedReports.isEmpty) {
      return SyncResult(
        success: true,
        message: 'No reports to sync',
        syncedCount: 0,
        failedCount: 0,
      );
    }

    int syncedCount = 0;
    int failedCount = 0;
    List<String> errors = [];

    for (final offlineReport in unsyncedReports) {
      try {
        await _syncSingleReport(offlineReport);
        await _storageService.markReportAsSynced(offlineReport.id);
        syncedCount++;
      } catch (e) {
        await _storageService.markReportSyncError(
            offlineReport.id, e.toString());
        errors.add('${offlineReport.title}: $e');
        failedCount++;
      }
    }

    return SyncResult(
      success: failedCount == 0,
      message: _buildSyncMessage(syncedCount, failedCount),
      syncedCount: syncedCount,
      failedCount: failedCount,
      errors: errors,
    );
  }

  Future<void> _syncSingleReport(OfflineReportModel offlineReport) async {
    // Convert offline report to the format expected by repository
    final location = LocationEntity(
      latitude: offlineReport.latitude,
      longitude: offlineReport.longitude,
      address: offlineReport.address,
    );

    // Note: Using stored image paths directly as URLs for now
    // In a production app, you'd upload images to cloud storage first

    // Create the report via repository
    await _reportsRepository.createReport(
      userId: offlineReport.userId,
      title: offlineReport.title,
      description: offlineReport.description,
      category: offlineReport.categoryEnum,
      importance: offlineReport.importanceEnum,
      location: location,
      imageUrls: offlineReport.imagePaths, // Use stored image paths as URLs
    );

    // Clean up offline images after successful sync
    await _storageService.deleteOfflineImages(offlineReport.id);
  }

  // Cache recent reports for offline viewing
  Future<void> cacheRecentReports(String userId) async {
    if (!_connectivityService.isOnline) {
      return;
    }

    try {
      final reports = await _reportsRepository.getAllReports();
      await _storageService.cacheReports(reports, userId);
    } catch (e) {
      print('Failed to cache reports: $e');
    }
  }

  // Get reports (online or cached)
  Future<List<ReportEntity>> getReports() async {
    if (_connectivityService.isOnline) {
      try {
        final onlineReports = await _reportsRepository.getAllReports();
        // Cache for offline use
        await _storageService.cacheReports(onlineReports, 'current_user');
        return onlineReports;
      } catch (e) {
        // Fall back to cached reports if online fetch fails
        return _getCachedReportsAsEntities();
      }
    } else {
      // Return cached reports when offline
      return _getCachedReportsAsEntities();
    }
  }

  Future<List<ReportEntity>> _getCachedReportsAsEntities() async {
    final cachedReports = await _storageService.getCachedReports();
    return cachedReports
        .map((cached) => _convertToReportEntity(cached))
        .toList();
  }

  ReportEntity _convertToReportEntity(OfflineReportModel cached) {
    return ReportEntity(
      id: cached.id,
      userId: cached.userId,
      title: cached.title,
      description: cached.description,
      category: cached.categoryEnum,
      importance: cached.importanceEnum,
      status: ReportStatus.submitted, // Default status for cached reports
      location: LocationEntity(
        latitude: cached.latitude,
        longitude: cached.longitude,
        address: cached.address,
      ),
      imageUrls: [], // Cached reports don't have image URLs
      upvotes: 0,
      upvotedBy: [],
      adminNotes: null,
      createdAt: cached.createdAt,
      updatedAt: cached.createdAt,
    );
  }

  String _buildSyncMessage(int syncedCount, int failedCount) {
    if (syncedCount > 0 && failedCount == 0) {
      return 'Successfully synced $syncedCount report${syncedCount == 1 ? '' : 's'}';
    } else if (syncedCount > 0 && failedCount > 0) {
      return 'Synced $syncedCount report${syncedCount == 1 ? '' : 's'}, $failedCount failed';
    } else if (failedCount > 0) {
      return 'Failed to sync $failedCount report${failedCount == 1 ? '' : 's'}';
    } else {
      return 'No reports to sync';
    }
  }

  // Auto-sync when connection is restored
  void startAutoSync() {
    _connectivityService.connectionStream.listen((isOnline) {
      if (isOnline) {
        // Delay sync to ensure connection is stable
        Future.delayed(const Duration(seconds: 2), () {
          syncOfflineReports();
        });
      }
    });
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final int failedCount;
  final List<String> errors;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedCount,
    required this.failedCount,
    this.errors = const [],
  });
}

final offlineStorageServiceProvider = Provider<OfflineStorageService>((ref) {
  return OfflineStorageService();
});

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  return OfflineSyncService(
    storageService: ref.watch(offlineStorageServiceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
    reportsRepository: ref.watch(supabaseReportsRepositoryProvider),
  );
});
