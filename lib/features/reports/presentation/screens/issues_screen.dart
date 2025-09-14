import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/reports_provider.dart';
import '../../data/repositories/supabase_reports_repository.dart';
import '../../domain/entities/report_entity.dart';

import '../../../../core/theme/app_theme.dart';

class IssuesScreen extends ConsumerStatefulWidget {
  const IssuesScreen({super.key});

  @override
  ConsumerState<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends ConsumerState<IssuesScreen> {
  List<ReportEntity> _filteredReports = [];
  String _selectedFilter = 'all';
  String _selectedSort = 'newest';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(allReportsProvider);

    return reportsAsync.when(
      data: (reports) {
        _filterAndSortReports(reports);

        return Column(
          children: [
            _buildFilterAndSortBar(),
            Expanded(
              child: _filteredReports.isEmpty
                  ? _buildEmptyState()
                  : _buildIssuesList(),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildFilterAndSortBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'All Issues'),
                const SizedBox(width: 8),
                _buildFilterChip('critical', 'Critical'),
                const SizedBox(width: 8),
                _buildFilterChip('high', 'High Priority'),
                const SizedBox(width: 8),
                _buildFilterChip('submitted', 'New'),
                const SizedBox(width: 8),
                _buildFilterChip('inProgress', 'In Progress'),
                const SizedBox(width: 8),
                _buildFilterChip('resolved', 'Resolved'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Sort Options
          Row(
            children: [
              Icon(
                Icons.sort_rounded,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Sort by:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSortChip('newest', 'Newest'),
                      const SizedBox(width: 8),
                      _buildSortChip('oldest', 'Oldest'),
                      const SizedBox(width: 8),
                      _buildSortChip('upvotes', 'Most Upvoted'),
                      const SizedBox(width: 8),
                      _buildSortChip('importance', 'Importance'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.transparent,
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.1),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : null,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _selectedSort == value;

    return ActionChip(
      label: Text(label),
      onPressed: () {
        setState(() {
          _selectedSort = value;
        });
      },
      backgroundColor: isSelected
          ? AppTheme.secondaryColor.withValues(alpha: 0.1)
          : Colors.transparent,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.secondaryColor : null,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.secondaryColor : Colors.grey.shade300,
        width: 1,
      ),
    );
  }

  Widget _buildIssuesList() {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allReportsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredReports.length,
        itemBuilder: (context, index) {
          final report = _filteredReports[index];
          return _buildIssueCard(report);
        },
      ),
    );
  }

  Widget _buildIssueCard(ReportEntity report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/report-details/${report.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Category Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getImportanceColor(report.importance)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(report.category),
                      color: _getImportanceColor(report.importance),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title and Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getCategoryText(report.category),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),

                  // Upvote Button
                  _buildUpvoteButton(report),
                ],
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                report.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 16),

              // Tags and Info Row
              Row(
                children: [
                  _buildImportanceChip(report.importance),
                  const SizedBox(width: 8),
                  _buildStatusChip(report.status),
                  const Spacer(),

                  // Date
                  Text(
                    _formatDate(report.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),

              // Location (if available)
              if (report.location.address != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report.location.address!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpvoteButton(ReportEntity report) {
    final user = ref.watch(authStateProvider).value;
    final hasUpvoted = user != null && report.upvotedBy.contains(user.id);

    return Container(
      decoration: BoxDecoration(
        color: hasUpvoted
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: user != null ? () => _handleUpvote(report) : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasUpvoted ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                size: 16,
                color: hasUpvoted ? AppTheme.primaryColor : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '${report.upvotes}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: hasUpvoted ? AppTheme.primaryColor : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportanceChip(ReportImportance importance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getImportanceColor(importance).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getImportanceColor(importance),
          width: 1,
        ),
      ),
      child: Text(
        _getImportanceText(importance),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getImportanceColor(importance),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ReportStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.list_alt_rounded,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Issues Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'all'
                  ? 'Be the first to report an issue in your community!'
                  : 'No issues match your current filter.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/create-report'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Report First Issue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error Loading Issues',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.errorColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load issues: $error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(allReportsProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _filterAndSortReports(List<ReportEntity> reports) {
    List<ReportEntity> filtered = reports;

    // Apply filters
    switch (_selectedFilter) {
      case 'critical':
        filtered = reports
            .where((r) => r.importance == ReportImportance.critical)
            .toList();
        break;
      case 'high':
        filtered = reports
            .where((r) => r.importance == ReportImportance.high)
            .toList();
        break;
      case 'submitted':
        filtered =
            reports.where((r) => r.status == ReportStatus.submitted).toList();
        break;
      case 'inProgress':
        filtered =
            reports.where((r) => r.status == ReportStatus.inProgress).toList();
        break;
      case 'resolved':
        filtered =
            reports.where((r) => r.status == ReportStatus.resolved).toList();
        break;
      default:
        filtered = reports;
    }

    // Apply sorting
    switch (_selectedSort) {
      case 'oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'upvotes':
        filtered.sort((a, b) => b.upvotes.compareTo(a.upvotes));
        break;
      case 'importance':
        filtered.sort((a, b) => _getImportanceOrder(b.importance)
            .compareTo(_getImportanceOrder(a.importance)));
        break;
      default: // newest
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    setState(() {
      _filteredReports = filtered;
    });
  }

  int _getImportanceOrder(ReportImportance importance) {
    switch (importance) {
      case ReportImportance.critical:
        return 4;
      case ReportImportance.high:
        return 3;
      case ReportImportance.medium:
        return 2;
      case ReportImportance.low:
        return 1;
    }
  }

  Future<void> _handleUpvote(ReportEntity report) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    try {
      await ref.read(supabaseReportsRepositoryProvider).toggleUpvote(
            reportId: report.id,
            userId: user.id,
          );
      ref.invalidate(allReportsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upvote: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Color _getImportanceColor(ReportImportance importance) {
    switch (importance) {
      case ReportImportance.low:
        return AppTheme.secondaryColor;
      case ReportImportance.medium:
        return AppTheme.accentColor;
      case ReportImportance.high:
        return AppTheme.warningColor;
      case ReportImportance.critical:
        return AppTheme.errorColor;
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.submitted:
        return AppTheme.primaryColor;
      case ReportStatus.inProgress:
        return AppTheme.accentColor;
      case ReportStatus.resolved:
        return AppTheme.secondaryColor;
      case ReportStatus.rejected:
        return AppTheme.errorColor;
    }
  }

  String _getImportanceText(ReportImportance importance) {
    switch (importance) {
      case ReportImportance.low:
        return 'Low';
      case ReportImportance.medium:
        return 'Medium';
      case ReportImportance.high:
        return 'High';
      case ReportImportance.critical:
        return 'Critical';
    }
  }

  String _getStatusText(ReportStatus status) {
    switch (status) {
      case ReportStatus.submitted:
        return 'New';
      case ReportStatus.inProgress:
        return 'In Progress';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }

  String _getCategoryText(ReportCategory category) {
    switch (category) {
      case ReportCategory.pothole:
        return 'Pothole';
      case ReportCategory.streetLight:
        return 'Street Light';
      case ReportCategory.garbage:
        return 'Garbage';
      case ReportCategory.graffiti:
        return 'Graffiti';
      case ReportCategory.brokenSidewalk:
        return 'Broken Sidewalk';
      case ReportCategory.other:
        return 'Other';
    }
  }

  IconData _getCategoryIcon(ReportCategory category) {
    switch (category) {
      case ReportCategory.pothole:
        return Icons.warning_rounded;
      case ReportCategory.streetLight:
        return Icons.lightbulb_rounded;
      case ReportCategory.garbage:
        return Icons.delete_rounded;
      case ReportCategory.graffiti:
        return Icons.brush_rounded;
      case ReportCategory.brokenSidewalk:
        return Icons.construction_rounded;
      case ReportCategory.other:
        return Icons.help_rounded;
    }
  }
}
