import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/reports/presentation/providers/offline_reports_provider.dart';

class ConnectivityIndicator extends ConsumerWidget {
  const ConnectivityIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStatusProvider);
    final unsyncedCountAsync = ref.watch(unsyncedReportsCountProvider);

    return connectivityAsync.when(
      data: (isOnline) {
        if (isOnline) {
          return unsyncedCountAsync.when(
            data: (unsyncedCount) {
              if (unsyncedCount > 0) {
                return _buildSyncingIndicator(context, unsyncedCount);
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          );
        } else {
          return _buildOfflineIndicator(context);
        }
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => _buildOfflineIndicator(context),
    );
  }

  Widget _buildOfflineIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.onError,
          ),
          const SizedBox(width: 6),
          Text(
            'Offline',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncingIndicator(BuildContext context, int unsyncedCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Syncing $unsyncedCount',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
