import '../../domain/entities/report_entity.dart';

class LocationModel {
  final double latitude;
  final double longitude;
  final String? address;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  LocationEntity toEntity() {
    return LocationEntity(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude, 'address': address};
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
    );
  }
}

class ReportModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final ReportCategory category;
  final ReportImportance importance;
  final ReportStatus status;
  final LocationModel location;
  final List<String> imageUrls;
  final int upvotes;
  final List<String> upvotedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminNotes;

  const ReportModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.importance,
    required this.status,
    required this.location,
    required this.imageUrls,
    this.upvotes = 0,
    this.upvotedBy = const [],
    required this.createdAt,
    this.updatedAt,
    this.adminNotes,
  });

  ReportEntity toEntity() {
    return ReportEntity(
      id: id,
      userId: userId,
      title: title,
      description: description,
      category: category,
      importance: importance,
      status: status,
      location: location.toEntity(),
      imageUrls: imageUrls,
      upvotes: upvotes,
      upvotedBy: upvotedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      adminNotes: adminNotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category.name,
      'status': status.name,
      'location': location.toJson(),
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'adminNotes': adminNotes,
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      category: ReportCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ReportCategory.other,
      ),
      importance: ReportImportance.values.firstWhere(
        (e) => e.name == json['importance'],
        orElse: () => ReportImportance.medium,
      ),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.submitted,
      ),
      location: LocationModel.fromJson(json['location']),
      imageUrls: json['image_urls'] != null 
          ? List<String>.from(json['image_urls'])
          : <String>[],
      upvotes: json['upvotes'] ?? 0,
      upvotedBy: json['upvoted_by'] != null 
          ? List<String>.from(json['upvoted_by'])
          : <String>[],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      adminNotes: json['admin_notes'],
    );
  }
}
