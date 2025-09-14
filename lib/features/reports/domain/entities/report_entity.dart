enum ReportStatus { submitted, inProgress, resolved, rejected }

enum ReportCategory {
  pothole,
  streetLight,
  garbage,
  graffiti,
  brokenSidewalk,
  other,
}

enum ReportImportance { low, medium, high, critical }

class LocationEntity {
  final double latitude;
  final double longitude;
  final String? address;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}

class ReportEntity {
  final String id;
  final String userId;
  final String title;
  final String description;
  final ReportCategory category;
  final ReportImportance importance;
  final ReportStatus status;
  final LocationEntity location;
  final List<String> imageUrls;
  final int upvotes;
  final List<String> upvotedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminNotes;

  const ReportEntity({
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

  ReportEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    ReportCategory? category,
    ReportImportance? importance,
    ReportStatus? status,
    LocationEntity? location,
    List<String>? imageUrls,
    int? upvotes,
    List<String>? upvotedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminNotes,
  }) {
    return ReportEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      importance: importance ?? this.importance,
      status: status ?? this.status,
      location: location ?? this.location,
      imageUrls: imageUrls ?? this.imageUrls,
      upvotes: upvotes ?? this.upvotes,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }
}
