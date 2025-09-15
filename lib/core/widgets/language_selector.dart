import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../../generated/l10n/app_localizations.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);

    return PopupMenuButton<Locale>(
      icon: Icon(
        Icons.language_rounded,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      tooltip: AppLocalizations.of(context).selectLanguage,
      onSelected: (Locale locale) {
        localeNotifier.setLocale(locale);
      },
      itemBuilder: (BuildContext context) {
        return LocaleNotifier.supportedLocales.map((Locale locale) {
          final isSelected = currentLocale.languageCode == locale.languageCode;

          return PopupMenuItem<Locale>(
            value: locale,
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  localeNotifier.getLanguageName(locale),
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
