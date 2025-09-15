import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/landing_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/navigation/presentation/screens/main_navigation_screen.dart';
import '../../features/reports/presentation/screens/create_report_screen.dart';
import '../../features/reports/presentation/screens/report_details_screen.dart';
import '../../features/reports/presentation/providers/reports_provider.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password';

      // If not logged in, show landing page for root, or allow auth routes
      if (!isLoggedIn) {
        if (state.matchedLocation == '/' ||
            state.matchedLocation == '/home' ||
            state.matchedLocation == '/issues' ||
            state.matchedLocation == '/profile') {
          return '/landing';
        }
        // Redirect to landing for protected routes
        if (state.matchedLocation == '/create-report' ||
            state.matchedLocation == '/my-reports' ||
            state.matchedLocation == '/edit-profile' ||
            state.matchedLocation.startsWith('/report-details/')) {
          return '/landing';
        }
      }

      // Redirect logged-in users away from auth screens to home
      if (isLoggedIn && (isAuthRoute || state.matchedLocation == '/landing')) {
        return '/home';
      }

      // Redirect logged-in users from root to home
      if (isLoggedIn && state.matchedLocation == '/') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/landing',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            const MainNavigationScreen(currentRoute: '/home'),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) =>
            const MainNavigationScreen(currentRoute: '/home'),
      ),
      GoRoute(
        path: '/issues',
        builder: (context, state) =>
            const MainNavigationScreen(currentRoute: '/issues'),
      ),
      GoRoute(
        path: '/my-reports',
        builder: (context, state) =>
            const MainNavigationScreen(currentRoute: '/my-reports'),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) =>
            const MainNavigationScreen(currentRoute: '/profile'),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/create-report',
        builder: (context, state) => const CreateReportScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/report-details/:id',
        builder: (context, state) {
          final reportId = state.pathParameters['id']!;
          return ReportDetailsWrapper(reportId: reportId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

class ReportDetailsWrapper extends ConsumerWidget {
  final String reportId;

  const ReportDetailsWrapper({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(allReportsProvider);

    return reportsAsync.when(
      data: (reports) {
        final report = reports.firstWhere(
          (r) => r.id == reportId,
          orElse: () => throw Exception('Report not found'),
        );
        return ReportDetailsScreen(report: report);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading report: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
