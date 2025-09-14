import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/report_model.dart';
import '../../domain/entities/report_entity.dart';

final supabaseReportsRepositoryProvider =
    Provider<SupabaseReportsRepository>((ref) {
  return SupabaseReportsRepository(Supabase.instance.client);
});

class SupabaseReportsRepository {
  final SupabaseClient _supabase;
  final _uuid = const Uuid();

  SupabaseReportsRepository(this._supabase);

  Future<List<ReportEntity>> getAllReports() async {
    try {
      final response = await _supabase
          .from('reports')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ReportModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reports: $e');
    }
  }

  Future<List<ReportEntity>> getUserReports(String userId) async {
    try {
      final response = await _supabase
          .from('reports')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ReportModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user reports: $e');
    }
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
    try {
      final reportData = {
        'id': _uuid.v4(),
        'user_id': userId,
        'title': title,
        'description': description,
        'category': category.name,
        'importance': importance.name,
        'status': ReportStatus.submitted.name,
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'address': location.address,
        },
        'image_urls': imageUrls,
        'upvotes': 0,
        'upvoted_by': <String>[],
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase.from('reports').insert(reportData).select().single();

      return ReportModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  Future<ReportEntity> updateReportStatus({
    required String reportId,
    required ReportStatus status,
    String? adminNotes,
  }) async {
    try {
      final updateData = {
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
        if (adminNotes != null) 'admin_notes': adminNotes,
      };

      final response = await _supabase
          .from('reports')
          .update(updateData)
          .eq('id', reportId)
          .select()
          .single();

      return ReportModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Failed to update report: $e');
    }
  }

  Future<void> deleteReport(String reportId) async {
    try {
      await _supabase.from('reports').delete().eq('id', reportId);
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  Future<ReportEntity> toggleUpvote({
    required String reportId,
    required String userId,
  }) async {
    try {
      // First get the current report
      final currentReport = await _supabase
          .from('reports')
          .select()
          .eq('id', reportId)
          .single();

      final upvotedBy = List<String>.from(currentReport['upvoted_by'] ?? []);
      final currentUpvotes = currentReport['upvotes'] ?? 0;

      Map<String, dynamic> updateData;
      
      if (upvotedBy.contains(userId)) {
        // Remove upvote
        upvotedBy.remove(userId);
        updateData = {
          'upvotes': currentUpvotes - 1,
          'upvoted_by': upvotedBy,
          'updated_at': DateTime.now().toIso8601String(),
        };
      } else {
        // Add upvote
        upvotedBy.add(userId);
        updateData = {
          'upvotes': currentUpvotes + 1,
          'upvoted_by': upvotedBy,
          'updated_at': DateTime.now().toIso8601String(),
        };
      }

      final response = await _supabase
          .from('reports')
          .update(updateData)
          .eq('id', reportId)
          .select()
          .single();

      return ReportModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Failed to toggle upvote: $e');
    }
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      final fileName = '${_uuid.v4()}.jpg';
      final filePath = 'reports/$fileName';

      await _supabase.storage.from('images').upload(filePath, imageFile);

      final publicUrl = _supabase.storage.from('images').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
