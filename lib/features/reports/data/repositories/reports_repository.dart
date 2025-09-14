import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/report_model.dart';
import '../../domain/entities/report_entity.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository();
});

class ReportsRepository {
  static const String _reportsKey = 'reports';
  final _uuid = const Uuid();

  Future<List<ReportEntity>> getAllReports() async {
    final prefs = await SharedPreferences.getInstance();
    final reportsJson = prefs.getStringList(_reportsKey) ?? [];

    return reportsJson
        .map((json) => ReportModel.fromJson(jsonDecode(json)).toEntity())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<ReportEntity>> getUserReports(String userId) async {
    final allReports = await getAllReports();
    return allReports.where((report) => report.userId == userId).toList();
  }

  Future<ReportEntity> createReport({
    required String userId,
    required String title,
    required String description,
    required ReportCategory category,
    required ReportImportance importance,
    required LocationEntity location,
    required List<String> imageUrls,
  }) async {
    final report = ReportModel(
      id: _uuid.v4(),
      userId: userId,
      title: title,
      description: description,
      category: category,
      importance: importance,
      status: ReportStatus.submitted,
      location: LocationModel(
        latitude: location.latitude,
        longitude: location.longitude,
        address: location.address,
      ),
      imageUrls: imageUrls,
      upvotes: 0,
      upvotedBy: [],
      createdAt: DateTime.now(),
    );

    await _saveReport(report);
    return report.toEntity();
  }

  Future<ReportEntity> updateReportStatus({
    required String reportId,
    required ReportStatus status,
    String? adminNotes,
  }) async {
    final reports = await _getAllReportModels();
    final reportIndex = reports.indexWhere((r) => r.id == reportId);

    if (reportIndex == -1) {
      throw Exception('Report not found');
    }

    final updatedReport = ReportModel(
      id: reports[reportIndex].id,
      userId: reports[reportIndex].userId,
      title: reports[reportIndex].title,
      description: reports[reportIndex].description,
      category: reports[reportIndex].category,
      importance: reports[reportIndex].importance,
      status: status,
      location: reports[reportIndex].location,
      imageUrls: reports[reportIndex].imageUrls,
      upvotes: reports[reportIndex].upvotes,
      upvotedBy: reports[reportIndex].upvotedBy,
      createdAt: reports[reportIndex].createdAt,
      updatedAt: DateTime.now(),
      adminNotes: adminNotes ?? reports[reportIndex].adminNotes,
    );

    reports[reportIndex] = updatedReport;
    await _saveAllReports(reports);
    return updatedReport.toEntity();
  }

  Future<void> deleteReport(String reportId) async {
    final reports = await _getAllReportModels();
    reports.removeWhere((r) => r.id == reportId);
    await _saveAllReports(reports);
  }

  Future<void> _saveReport(ReportModel report) async {
    final reports = await _getAllReportModels();
    reports.add(report);
    await _saveAllReports(reports);
  }

  Future<List<ReportModel>> _getAllReportModels() async {
    final prefs = await SharedPreferences.getInstance();
    final reportsJson = prefs.getStringList(_reportsKey) ?? [];

    return reportsJson
        .map((json) => ReportModel.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _saveAllReports(List<ReportModel> reports) async {
    final prefs = await SharedPreferences.getInstance();
    final reportsJson = reports
        .map((report) => jsonEncode(report.toJson()))
        .toList();

    await prefs.setStringList(_reportsKey, reportsJson);
  }

  // Mock method for image upload - in real app, this would upload to cloud storage
  Future<String> uploadImage(File imageFile) async {
    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 1));

    // Return a mock URL - in real app, this would be the actual uploaded image URL
    return 'https://example.com/images/${_uuid.v4()}.jpg';
  }
}
