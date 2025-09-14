import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/supabase_reports_repository.dart';
import '../../domain/entities/report_entity.dart';

final allReportsProvider = FutureProvider<List<ReportEntity>>((ref) async {
  final repository = ref.watch(supabaseReportsRepositoryProvider);
  return repository.getAllReports();
});

final userReportsProvider = FutureProvider.family<List<ReportEntity>, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(supabaseReportsRepositoryProvider);
  return repository.getUserReports(userId);
});

final reportsControllerProvider =
    StateNotifierProvider<ReportsController, AsyncValue<void>>((ref) {
  return ReportsController(ref.watch(supabaseReportsRepositoryProvider));
});

class ReportsController extends StateNotifier<AsyncValue<void>> {
  final SupabaseReportsRepository _repository;

  ReportsController(this._repository) : super(const AsyncValue.data(null));

  Future<void> createReport({
    required String userId,
    required String title,
    required String description,
    required ReportCategory category,
    required ReportImportance importance,
    required LocationEntity location,
    required List<File> images,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Upload images first
      final imageUrls = <String>[];
      for (final image in images) {
        final url = await _repository.uploadImage(image);
        imageUrls.add(url);
      }

      await _repository.createReport(
        userId: userId,
        title: title,
        description: description,
        category: category,
        importance: importance,
        location: location,
        imageUrls: imageUrls,
      );

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateReportStatus({
    required String reportId,
    required ReportStatus status,
    String? adminNotes,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateReportStatus(
        reportId: reportId,
        status: status,
        adminNotes: adminNotes,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteReport(String reportId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteReport(reportId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleUpvote({
    required String reportId,
    required String userId,
  }) async {
    try {
      await _repository.toggleUpvote(reportId: reportId, userId: userId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
