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
  bool _isCompactView = false;
  
  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchActive = false;
  List<String> _searchHistory = [];
  
  // Advanced filter functionality
  bool _showAdvancedFilters = false;
  DateTimeRange? _dateRange;
  List<ReportCategory> _selectedCategories = [];
  List<ReportImportance> _selectedImportances = [];
  // double _maxDistance = 50.0; // km - Reserved for future location-based filtering
  bool _showMyReportsOnly = false;
  bool _showRecentlyUpdated = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          const SizedBox(height: 16),
          
          // Advanced Filters (if enabled)
          if (_showAdvancedFilters) ...[
            _buildAdvancedFilters(),
            const SizedBox(height: 16),
          ],
          
          // Sort and View Controls
          Row(
            children: [
              // Sort Options
              Icon(
                Icons.sort_rounded,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Sort:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const Spacer(),
              
              // View Toggle
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isCompactView = false;
                        });
                      },
                      icon: Icon(
                        Icons.view_agenda,
                        size: 18,
                        color: !_isCompactView
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                      ),
                      tooltip: 'Expanded View',
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: Theme.of(context).dividerColor,
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isCompactView = true;
                        });
                      },
                      icon: Icon(
                        Icons.view_compact,
                        size: 18,
                        color: _isCompactView
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                      ),
                      tooltip: 'Compact View',
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Sort Chips Row
          SingleChildScrollView(
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
        ],
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
        final reportsAsync = ref.read(allReportsProvider);
        reportsAsync.whenData((reports) {
          _filterAndSortReports(reports);
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

  Widget _buildSearchBar() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isSearchActive 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor,
                    width: _isSearchActive ? 2 : 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onSubmitted: (query) {
                    if (query.trim().isNotEmpty) {
                      _addToSearchHistory(query.trim());
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Search issues by title, description, location...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: _isSearchActive 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    suffixIcon: _isSearchActive
                      ? IconButton(
                          onPressed: _clearSearch,
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          tooltip: 'Clear search',
                        )
                      : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Advanced Filters Toggle
            Container(
              decoration: BoxDecoration(
                color: _showAdvancedFilters 
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _showAdvancedFilters
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
                ),
              ),
              child: IconButton(
                onPressed: _toggleAdvancedFilters,
                icon: Icon(
                  Icons.tune_rounded,
                  color: _showAdvancedFilters
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                tooltip: 'Advanced Filters',
              ),
            ),
          ],
        ),
        
        // Search History/Suggestions
        if (_searchHistory.isNotEmpty && _searchQuery.isEmpty)
          _buildSearchHistory(),
        
        // Search Results Count
        if (_isSearchActive)
          _buildSearchResultsCount(),
      ],
    );
  }

  Widget _buildSearchHistory() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                'Recent Searches',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: _searchHistory.map((query) {
              return InkWell(
                onTap: () => _selectSearchSuggestion(query),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    query,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsCount() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_rounded,
            size: 14,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            '${_filteredReports.length} result${_filteredReports.length == 1 ? '' : 's'} for "$_searchQuery"',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_alt_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Advanced Filters',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAllFilters,
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Categories Filter
          _buildCategoryFilter(),
          const SizedBox(height: 16),
          
          // Importance Filter
          _buildImportanceFilter(),
          const SizedBox(height: 16),
          
          // Date Range Filter
          _buildDateRangeFilter(),
          const SizedBox(height: 16),
          
          // Quick Filters
          _buildQuickFilters(),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: ReportCategory.values.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return FilterChip(
              label: Text(_getCategoryText(category)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
                final reportsAsync = ref.read(allReportsProvider);
                reportsAsync.whenData((reports) {
                  _filterAndSortReports(reports);
                });
              },
              backgroundColor: Colors.transparent,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImportanceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Importance Level',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: ReportImportance.values.map((importance) {
            final isSelected = _selectedImportances.contains(importance);
            return FilterChip(
              label: Text(_getImportanceText(importance)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedImportances.add(importance);
                  } else {
                    _selectedImportances.remove(importance);
                  }
                });
                final reportsAsync = ref.read(allReportsProvider);
                reportsAsync.whenData((reports) {
                  _filterAndSortReports(reports);
                });
              },
              backgroundColor: Colors.transparent,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDateRange,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: _dateRange != null
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
              ),
              borderRadius: BorderRadius.circular(8),
              color: _dateRange != null
                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                : Colors.transparent,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.date_range_rounded,
                  size: 16,
                  color: _dateRange != null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  _dateRange != null
                    ? '${_formatDateShort(_dateRange!.start)} - ${_formatDateShort(_dateRange!.end)}'
                    : 'Select date range',
                  style: TextStyle(
                    color: _dateRange != null
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: _dateRange != null ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (_dateRange != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _dateRange = null;
                      });
                      final reportsAsync = ref.read(allReportsProvider);
                      reportsAsync.whenData((reports) {
                        _filterAndSortReports(reports);
                      });
                    },
                    child: Icon(
                      Icons.clear_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Filters',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            CheckboxListTile(
              title: Text(
                'My Reports Only',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: _showMyReportsOnly,
              onChanged: (value) {
                setState(() {
                  _showMyReportsOnly = value ?? false;
                });
                final reportsAsync = ref.read(allReportsProvider);
                reportsAsync.whenData((reports) {
                  _filterAndSortReports(reports);
                });
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: Text(
                'Recently Updated (Last 7 days)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: _showRecentlyUpdated,
              onChanged: (value) {
                setState(() {
                  _showRecentlyUpdated = value ?? false;
                });
                final reportsAsync = ref.read(allReportsProvider);
                reportsAsync.whenData((reports) {
                  _filterAndSortReports(reports);
                });
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ],
    );
  }

  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
          return _isCompactView
              ? _buildCompactIssueCard(report)
              : _buildIssueCard(report);
        },
      ),
    );
  }

  Widget _buildCompactIssueCard(ReportEntity report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: InkWell(
        onTap: () => context.push('/report-details/${report.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Category Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getImportanceColor(report.importance)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getCategoryIcon(report.category),
                  color: _getImportanceColor(report.importance),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),

              // Title and Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getCategoryText(report.category),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),

              // Status and Importance Chips
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildCompactImportanceChip(report.importance),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(report.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                  ),
                ],
              ),

              const SizedBox(width: 8),
              // Upvote Button
              _buildCompactUpvoteButton(report),
            ],
          ),
        ),
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
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).cardColor,
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
                color: hasUpvoted
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 4),
              Text(
                '${report.upvotes}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: hasUpvoted
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactUpvoteButton(ReportEntity report) {
    final user = ref.watch(authStateProvider).value;
    final hasUpvoted = user != null && report.upvotedBy.contains(user.id);

    return Container(
      decoration: BoxDecoration(
        color: hasUpvoted
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasUpvoted
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: user != null ? () => _handleUpvote(report) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasUpvoted ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                size: 14,
                color: hasUpvoted
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 2),
              Text(
                '${report.upvotes}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: hasUpvoted
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactImportanceChip(ReportImportance importance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getImportanceColor(importance).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getImportanceColor(importance),
          width: 0.5,
        ),
      ),
      child: Text(
        _getImportanceText(importance),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: _getImportanceColor(importance),
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

    // Apply search filter first
    if (_searchQuery.isNotEmpty) {
      filtered = _applySearchFilter(filtered);
    }

    // Apply basic filters
    switch (_selectedFilter) {
      case 'critical':
        filtered = filtered
            .where((r) => r.importance == ReportImportance.critical)
            .toList();
        break;
      case 'high':
        filtered = filtered
            .where((r) => r.importance == ReportImportance.high)
            .toList();
        break;
      case 'submitted':
        filtered =
            filtered.where((r) => r.status == ReportStatus.submitted).toList();
        break;
      case 'inProgress':
        filtered =
            filtered.where((r) => r.status == ReportStatus.inProgress).toList();
        break;
      case 'resolved':
        filtered =
            filtered.where((r) => r.status == ReportStatus.resolved).toList();
        break;
      default:
        filtered = filtered;
    }

    // Apply advanced filters
    filtered = _applyAdvancedFilters(filtered);

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

  List<ReportEntity> _applySearchFilter(List<ReportEntity> reports) {
    final query = _searchQuery.toLowerCase().trim();
    if (query.isEmpty) return reports;

    return reports.where((report) {
      // Search in title
      if (report.title.toLowerCase().contains(query)) return true;
      
      // Search in description
      if (report.description.toLowerCase().contains(query)) return true;
      
      // Search in address
      if (report.location.address?.toLowerCase().contains(query) == true) return true;
      
      // Search in category
      if (_getCategoryText(report.category).toLowerCase().contains(query)) return true;
      
      // Search in importance
      if (_getImportanceText(report.importance).toLowerCase().contains(query)) return true;
      
      return false;
    }).toList();
  }

  List<ReportEntity> _applyAdvancedFilters(List<ReportEntity> reports) {
    List<ReportEntity> filtered = reports;

    // Filter by selected categories
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered.where((report) => 
        _selectedCategories.contains(report.category)).toList();
    }

    // Filter by selected importance levels
    if (_selectedImportances.isNotEmpty) {
      filtered = filtered.where((report) => 
        _selectedImportances.contains(report.importance)).toList();
    }

    // Filter by date range
    if (_dateRange != null) {
      filtered = filtered.where((report) {
        final reportDate = DateTime(
          report.createdAt.year,
          report.createdAt.month,
          report.createdAt.day,
        );
        final startDate = DateTime(
          _dateRange!.start.year,
          _dateRange!.start.month,
          _dateRange!.start.day,
        );
        final endDate = DateTime(
          _dateRange!.end.year,
          _dateRange!.end.month,
          _dateRange!.end.day,
        );
        return reportDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
               reportDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    }

    // Filter by recently updated (last 7 days)
    if (_showRecentlyUpdated) {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      filtered = filtered.where((report) => 
        report.updatedAt?.isAfter(sevenDaysAgo) == true).toList();
    }

    // Filter by my reports only
    if (_showMyReportsOnly) {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        filtered = filtered.where((report) => 
          report.userId == user.id).toList();
      }
    }

    return filtered;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _isSearchActive = query.isNotEmpty;
    });
    
    // Debounce search to avoid excessive filtering
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchQuery == query) {
        final reportsAsync = ref.read(allReportsProvider);
        reportsAsync.whenData((reports) {
          _filterAndSortReports(reports);
        });
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _isSearchActive = false;
    });
    
    final reportsAsync = ref.read(allReportsProvider);
    reportsAsync.whenData((reports) {
      _filterAndSortReports(reports);
    });
  }

  void _addToSearchHistory(String query) {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _searchHistory.remove(query); // Remove if already exists
      _searchHistory.insert(0, query); // Add to beginning
      if (_searchHistory.length > 5) {
        _searchHistory = _searchHistory.take(5).toList(); // Keep only 5 recent searches
      }
    });
  }

  void _selectSearchSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _onSearchChanged(suggestion);
  }

  void _toggleAdvancedFilters() {
    setState(() {
      _showAdvancedFilters = !_showAdvancedFilters;
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategories.clear();
      _selectedImportances.clear();
      _dateRange = null;
      _showMyReportsOnly = false;
      _showRecentlyUpdated = false;
      _selectedFilter = 'all';
      _selectedSort = 'newest';
    });
    
    final reportsAsync = ref.read(allReportsProvider);
    reportsAsync.whenData((reports) {
      _filterAndSortReports(reports);
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
      
      final reportsAsync = ref.read(allReportsProvider);
      reportsAsync.whenData((reports) {
        _filterAndSortReports(reports);
      });
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
