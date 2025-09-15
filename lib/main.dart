import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/services/offline_storage_service.dart';
import 'generated/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline storage
  await OfflineStorageService.initialize();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: CivicReporterApp()));
}

class CivicReporterApp extends ConsumerWidget {
  const CivicReporterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Civic Reporter',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleNotifier.supportedLocales,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
