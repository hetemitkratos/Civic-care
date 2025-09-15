import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/screens/dashboard_screen.dart';
import '../../../reports/presentation/screens/issues_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../reports/presentation/screens/my_reports_screen.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/language_selector.dart';
import '../../../../generated/l10n/app_localizations.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  final String currentRoute;

  const MainNavigationScreen({
    super.key,
    this.currentRoute = '/home',
  });

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  Widget _getCurrentScreen() {
    switch (widget.currentRoute) {
      case '/home':
      case '/dashboard':
        return const DashboardScreen();
      case '/issues':
        return const IssuesScreen();
      case '/my-reports':
        return const MyReportsScreen();
      case '/profile':
        return const ProfileScreen();
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle()),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Open menu',
          ),
        ),
        actions: [
          const LanguageSelector(),
          IconButton(
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
            icon: Icon(
              ref.watch(themeProvider) == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      drawer: _buildDrawer(context, user),
      body: _getCurrentScreen(),
      floatingActionButton: _shouldShowFAB() && user != null
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/create-report'),
              icon: const Icon(Icons.add_rounded),
              label: Text(AppLocalizations.of(context).reportIssue),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  String _getScreenTitle() {
    final l10n = AppLocalizations.of(context);
    switch (widget.currentRoute) {
      case '/home':
      case '/dashboard':
        return l10n.home;
      case '/issues':
        return l10n.allIssues;
      case '/my-reports':
        return l10n.myReports;
      case '/profile':
        return l10n.profile;
      default:
        return l10n.appName;
    }
  }

  bool _shouldShowFAB() {
    // Show FAB on home, issues, and my-reports screens
    return widget.currentRoute == '/home' ||
        widget.currentRoute == '/dashboard' ||
        widget.currentRoute == '/issues' ||
        widget.currentRoute == '/my-reports';
  }

  Widget _buildDrawer(BuildContext context, user) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Drawer(
      child: Column(
        children: [
          // Beautiful Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Logo/Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.report_problem,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),

                // App Name
                Text(
                  'Civic Reporter',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // User Info
                if (user != null) ...[
                  Text(
                    user.displayName ?? 'User',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home_rounded,
                  title: AppLocalizations.of(context).home,
                  route: '/home',
                  isSelected: widget.currentRoute == '/home' ||
                      widget.currentRoute == '/dashboard',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.list_alt_rounded,
                  title: AppLocalizations.of(context).allIssues,
                  route: '/issues',
                  isSelected: widget.currentRoute == '/issues',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.assignment_rounded,
                  title: AppLocalizations.of(context).myReports,
                  route: '/my-reports',
                  isSelected: widget.currentRoute == '/my-reports',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person_rounded,
                  title: AppLocalizations.of(context).profile,
                  route: '/profile',
                  isSelected: widget.currentRoute == '/profile',
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),

                // Quick Actions
                _buildDrawerItem(
                  context,
                  icon: Icons.add_circle_rounded,
                  title: AppLocalizations.of(context).reportIssue,
                  route: '/create-report',
                  isSelected: false,
                  isAction: true,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),

                // Theme Toggle
                ListTile(
                  leading: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: AppTheme.primaryColor,
                  ),
                  title: Text(
                    'Toggle Theme',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  onTap: () {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                ),
              ],
            ),
          ),

          // Logout Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go('/');
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: Text(AppLocalizations.of(context).logout),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                  side: const BorderSide(color: AppTheme.errorColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isSelected,
    bool isAction = false,
  }) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? AppTheme.primaryColor
              : isAction
                  ? AppTheme.secondaryColor
                  : (isDark ? Colors.white70 : const Color(0xFF64748B)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? AppTheme.primaryColor
                : isAction
                    ? AppTheme.secondaryColor
                    : (isDark ? Colors.white : const Color(0xFF1E293B)),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () {
          Navigator.pop(context);
          context.go(route);
        },
      ),
    );
  }
}
