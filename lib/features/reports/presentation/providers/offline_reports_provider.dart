import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/offline_sync_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/offline_storage_service.dart';
import '../../../../core/models/offline_report_model.dart';
import '../../domain/entities/report_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class OfflineReportsNotifier
    extends StateNotifier<AsyncValue<List<ReportEntity>>> {
  final OfflineSyncService _syncService;
  final OfflineStorageService _storageService;
  final ConnectivityService _connectivityService;
  final Ref _ref;

  OfflineReportsNotifier(
    this._syncService,
    this._storageService,
    this._connectivityService,
    this._ref,
  ) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _storageService.openBoxes();
    _syncService.startAutoSync();
    await loadReports();
  }

  Future<void> loadReports() async {
    try {
      state = const AsyncValue.loading();
      final reports = await _syncService.getReports();
      state = AsyncValue.data(reports);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createReport({
    required String title,
    required String description,
    required ReportCategory category,
    required ReportImportance importance,
    required LocationEntity location,
    required List<File> images,
  }) async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) throw Exception('User not authenticated');

    final reportId = const Uuid().v4();

    try {
      if (_connectivityService.isOnline) {
        // Try to create online first
        await _createOnlineReport(
          userId: user.id,
          title: title,
          description: description,
          category: category,
          importance: importance,
          location: location,
          images: images,
        );
      } else {
        // Create offline report
        await _createOfflineReport(
          reportId: reportId,
          userId: user.id,
          title: title,
          description: description,
          category: category,
          importance: importance,
          location: location,
          images: images,
        );
      }

      // Refresh the reports list
      await loadReports();
    } catch (e) {
      // If online creation fails, fall back to offline
      if (_connectivityService.isOnline) {
        await _createOfflineReport(
          reportId: reportId,
          userId: user.id,
          title: title,
          description: description,
          category: category,
          importance: importance,
          location: location,
          images: images,
        );
        await loadReports();
      } else {
        rethrow;
      }
    }
  }

  Future<void> _createOnlineReport({
    required String userId,
    required String title,
    required String description,
    required ReportCategory category,
    required ReportImportance importance,
    required LocationEntity location,
    required List<File> images,
  }) async {
    // This would use the existing Supabase repository
    // For now, we'll simulate the call
    await _syncService.syncOfflineReports();
  }

  Future<void> _createOfflineReport({
    required String reportId,
    required String userId,
    required String title,
    required String description,
    required ReportCategory category,
    required ReportImportance importance,
    required LocationEntity location,
    required List<File> images,
  }) async {
    // Save images offline
    final imagePaths = <String>[];
    for (final image in images) {
      final savedPath = await _storageService.saveOfflineImage(image, reportId);
      imagePaths.add(savedPath);
    }

    // Create offline report
    final offlineReport = OfflineReportModel(
      id: reportId,
      userId: userId,
      title: title,
      description: description,
      category: category.name,
      importance: importance.name,
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
      imagePaths: imagePaths,
      createdAt: DateTime.now(),
      isSynced: false,
    );

    await _storageService.saveOfflineReport(offlineReport);
  }

  Future<SyncResult> syncOfflineReports() async {
    final result = await _syncService.syncOfflineReports();
    if (result.syncedCount > 0) {
      await loadReports();
    }
    return result;
  }

  Future<List<OfflineReportModel>> getOfflineReports() async {
    return await _storageService.getOfflineReports();
  }

  Future<List<OfflineReportModel>> getUnsyncedReports() async {
    return await _storageService.getUnsyncedReports();
  }

  Future<Map<String, int>> getOfflineStats() async {
    return await _storageService.getStorageStats();
  }

  bool get isOnline => _connectivityService.isOnline;
}

final offlineReportsProvider = StateNotifierProvider<OfflineReportsNotifier,
    AsyncValue<List<ReportEntity>>>((ref) {
  return OfflineReportsNotifier(
    ref.watch(offlineSyncServiceProvider),
    ref.watch(offlineStorageServiceProvider),
    ref.watch(connectivityServiceProvider),
    ref,
  );
});

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).connectionStream;
});

final unsyncedReportsCountProvider = FutureProvider<int>((ref) async {
  final notifier = ref.watch(offlineReportsProvider.notifier);
  final unsyncedReports = await notifier.getUnsyncedReports();
  return unsyncedReports.length;
});
