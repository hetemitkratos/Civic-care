import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/report_entity.dart';
import '../providers/reports_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ReportDetailsScreen extends ConsumerWidget {
  final ReportEntity report;

  const ReportDetailsScreen({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final hasUpvoted = user != null && report.upvotedBy.contains(user.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildStatusChip(context, report.status),
              ],
            ),

            const SizedBox(height: 16),

            // Category and Importance
            Row(
              children: [
                _buildCategoryChip(context, report.category),
                const SizedBox(width: 8),
                _buildImportanceChip(context, report.importance),
              ],
            ),

            const SizedBox(height: 16),

            // Upvote section
            Card(
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: user != null
                          ? () => _handleUpvote(ref, user.id)
                          : null,
                      icon: Icon(
                        hasUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                        color: hasUpvoted
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${report.upvotes} ${report.upvotes == 1 ? 'upvote' : 'upvotes'}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: hasUpvoted
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    if (user == null) ...[
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.push('/login'),
                        child: const Text('Login to upvote'),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              report.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 16),

            // Location
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(
                  report.location.address ??
                      'Lat: ${report.location.latitude.toStringAsFixed(6)}, '
                          'Lng: ${report.location.longitude.toStringAsFixed(6)}',
                ),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {
                  // Could open in maps app
                },
              ),
            ),

            const SizedBox(height: 16),

            // Images
            if (report.imageUrls.isNotEmpty) ...[
              Text(
                'Photos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: report.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: report.imageUrls[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Timestamps
            Text(
              'Reported',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDateTime(report.createdAt),
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            if (report.updatedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last Updated',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatDateTime(report.updatedAt!),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            if (report.adminNotes != null) ...[
              const SizedBox(height: 16),
              Text(
                'Admin Notes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    report.adminNotes!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, ReportStatus status) {
    Color color;
    String label;

    switch (status) {
      case ReportStatus.submitted:
        color = Colors.red;
        label = 'Submitted';
        break;
      case ReportStatus.inProgress:
        color = Colors.orange;
        label = 'In Progress';
        break;
      case ReportStatus.resolved:
        color = Colors.green;
        label = 'Resolved';
        break;
      case ReportStatus.rejected:
        color = Colors.purple;
        label = 'Rejected';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontSize: 12,
            ),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildCategoryChip(BuildContext context, ReportCategory category) {
    String label;
    IconData icon;

    switch (category) {
      case ReportCategory.pothole:
        label = 'Pothole';
        icon = Icons.warning;
        break;
      case ReportCategory.streetLight:
        label = 'Street Light';
        icon = Icons.lightbulb;
        break;
      case ReportCategory.garbage:
        label = 'Garbage';
        icon = Icons.delete;
        break;
      case ReportCategory.graffiti:
        label = 'Graffiti';
        icon = Icons.brush;
        break;
      case ReportCategory.brokenSidewalk:
        label = 'Broken Sidewalk';
        icon = Icons.construction;
        break;
      case ReportCategory.other:
        label = 'Other';
        icon = Icons.help;
        break;
    }

    return Chip(
      avatar:
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface),
      label: Text(label,
          style:
              Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12)),
    );
  }

  Widget _buildImportanceChip(
      BuildContext context, ReportImportance importance) {
    Color color;
    String label;
    IconData icon;

    switch (importance) {
      case ReportImportance.low:
        color = Colors.green;
        label = 'Low';
        icon = Icons.low_priority;
        break;
      case ReportImportance.medium:
        color = Colors.orange;
        label = 'Medium';
        icon = Icons.remove;
        break;
      case ReportImportance.high:
        color = Colors.red;
        label = 'High';
        icon = Icons.priority_high;
        break;
      case ReportImportance.critical:
        color = Colors.red.shade800;
        label = 'Critical';
        icon = Icons.warning;
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontSize: 12,
            ),
      ),
      backgroundColor: color,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleUpvote(WidgetRef ref, String userId) async {
    try {
      await ref.read(reportsControllerProvider.notifier).toggleUpvote(
            reportId: report.id,
            userId: userId,
          );

      // Refresh the reports list
      ref.refresh(allReportsProvider);
    } catch (e) {
      // Error handling is done in the provider
    }
  }
}
