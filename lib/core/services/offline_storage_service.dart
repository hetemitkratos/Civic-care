import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/offline_report_model.dart';
import '../../features/reports/domain/entities/report_entity.dart';

class OfflineStorageService {
  static const String _offlineReportsBox = 'offline_reports';
  static const String _cachedReportsBox = 'cached_reports';
  static const String _offlineImagesBox = 'offline_images';

  late Box<OfflineReportModel> _offlineReportsBox_;
  late Box<OfflineReportModel> _cachedReportsBox_;
  late Box<String> _offlineImagesBox_;

  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(OfflineReportModelAdapter());
    }
  }

  Future<void> openBoxes() async {
    _offlineReportsBox_ =
        await Hive.openBox<OfflineReportModel>(_offlineReportsBox);
    _cachedReportsBox_ =
        await Hive.openBox<OfflineReportModel>(_cachedReportsBox);
    _offlineImagesBox_ = await Hive.openBox<String>(_offlineImagesBox);
  }

  // Offline Reports Management
  Future<void> saveOfflineReport(OfflineReportModel report) async {
    await _offlineReportsBox_.put(report.id, report);
  }

  Future<List<OfflineReportModel>> getOfflineReports() async {
    return _offlineReportsBox_.values.toList();
  }

  Future<List<OfflineReportModel>> getUnsyncedReports() async {
    return _offlineReportsBox_.values
        .where((report) => !report.isSynced)
        .toList();
  }

  Future<void> markReportAsSynced(String reportId) async {
    final report = _offlineReportsBox_.get(reportId);
    if (report != null) {
      final updatedReport = report.copyWith(isSynced: true, syncError: null);
      await _offlineReportsBox_.put(reportId, updatedReport);
    }
  }

  Future<void> markReportSyncError(String reportId, String error) async {
    final report = _offlineReportsBox_.get(reportId);
    if (report != null) {
      final updatedReport = report.copyWith(syncError: error);
      await _offlineReportsBox_.put(reportId, updatedReport);
    }
  }

  Future<void> deleteOfflineReport(String reportId) async {
    await _offlineReportsBox_.delete(reportId);
  }

  // Cached Reports Management
  Future<void> cacheReports(List<ReportEntity> reports, String userId) async {
    await _cachedReportsBox_.clear();

    for (final report in reports) {
      final offlineReport = OfflineReportModel.fromReportEntity(
        report: report,
        userId: userId,
        imagePaths: [], // We'll handle image caching separately
      );
      await _cachedReportsBox_.put(report.id, offlineReport);
    }
  }

  Future<List<OfflineReportModel>> getCachedReports() async {
    return _cachedReportsBox_.values.toList();
  }

  // Image Management
  Future<String> saveOfflineImage(File imageFile, String reportId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final offlineImagesDir = Directory('${appDir.path}/offline_images');

      if (!await offlineImagesDir.exists()) {
        await offlineImagesDir.create(recursive: true);
      }

      final fileName =
          '${reportId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = File('${offlineImagesDir.path}/$fileName');

      await imageFile.copy(savedImage.path);
      await _offlineImagesBox_.put(fileName, savedImage.path);

      return savedImage.path;
    } catch (e) {
      throw Exception('Failed to save offline image: $e');
    }
  }

  Future<List<String>> getOfflineImages(String reportId) async {
    final allImages = _offlineImagesBox_.toMap();
    return allImages.entries
        .where((entry) => entry.key.startsWith(reportId))
        .map((entry) => entry.value)
        .toList();
  }

  Future<void> deleteOfflineImages(String reportId) async {
    final imagesToDelete = _offlineImagesBox_
        .toMap()
        .entries
        .where((entry) => entry.key.startsWith(reportId))
        .toList();

    for (final entry in imagesToDelete) {
      try {
        final file = File(entry.value);
        if (await file.exists()) {
          await file.delete();
        }
        await _offlineImagesBox_.delete(entry.key);
      } catch (e) {
        // Log error but continue cleanup
        print('Error deleting offline image: $e');
      }
    }
  }

  // Storage Statistics
  Future<Map<String, int>> getStorageStats() async {
    return {
      'offlineReports': _offlineReportsBox_.length,
      'cachedReports': _cachedReportsBox_.length,
      'offlineImages': _offlineImagesBox_.length,
      'unsyncedReports':
          getUnsyncedReports().then((reports) => reports.length) as int,
    };
  }

  // Cleanup
  Future<void> clearAllOfflineData() async {
    await _offlineReportsBox_.clear();
    await _cachedReportsBox_.clear();

    // Delete all offline images
    final allImages = _offlineImagesBox_.toMap();
    for (final imagePath in allImages.values) {
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error deleting image: $e');
      }
    }
    await _offlineImagesBox_.clear();
  }

  Future<void> closeBoxes() async {
    await _offlineReportsBox_.close();
    await _cachedReportsBox_.close();
    await _offlineImagesBox_.close();
  }
}
