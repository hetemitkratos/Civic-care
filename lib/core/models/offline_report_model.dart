import 'package:hive/hive.dart';
import '../../features/reports/domain/entities/report_entity.dart';

part 'offline_report_model.g.dart';

@HiveType(typeId: 0)
class OfflineReportModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String importance;

  @HiveField(6)
  final double latitude;

  @HiveField(7)
  final double longitude;

  @HiveField(8)
  final String? address;

  @HiveField(9)
  final List<String> imagePaths;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final bool isSynced;

  @HiveField(12)
  final String? syncError;

  OfflineReportModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.importance,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.imagePaths,
    required this.createdAt,
    this.isSynced = false,
    this.syncError,
  });

  factory OfflineReportModel.fromReportEntity({
    required ReportEntity report,
    required String userId,
    required List<String> imagePaths,
  }) {
    return OfflineReportModel(
      id: report.id,
      userId: userId,
      title: report.title,
      description: report.description,
      category: report.category.name,
      importance: report.importance.name,
      latitude: report.location.latitude,
      longitude: report.location.longitude,
      address: report.location.address,
      imagePaths: imagePaths,
      createdAt: report.createdAt,
      isSynced: true,
    );
  }

  ReportCategory get categoryEnum {
    switch (category) {
      case 'pothole':
        return ReportCategory.pothole;
      case 'streetLight':
        return ReportCategory.streetLight;
      case 'garbage':
        return ReportCategory.garbage;
      case 'graffiti':
        return ReportCategory.graffiti;
      case 'brokenSidewalk':
        return ReportCategory.brokenSidewalk;
      default:
        return ReportCategory.other;
    }
  }

  ReportImportance get importanceEnum {
    switch (importance) {
      case 'low':
        return ReportImportance.low;
      case 'medium':
        return ReportImportance.medium;
      case 'high':
        return ReportImportance.high;
      case 'critical':
        return ReportImportance.critical;
      default:
        return ReportImportance.medium;
    }
  }

  OfflineReportModel copyWith({
    bool? isSynced,
    String? syncError,
  }) {
    return OfflineReportModel(
      id: id,
      userId: userId,
      title: title,
      description: description,
      category: category,
      importance: importance,
      latitude: latitude,
      longitude: longitude,
      address: address,
      imagePaths: imagePaths,
      createdAt: createdAt,
      isSynced: isSynced ?? this.isSynced,
      syncError: syncError ?? this.syncError,
    );
  }
}
