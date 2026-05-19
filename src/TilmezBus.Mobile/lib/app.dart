import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tilmez_bus/core/locale/locale_controller.dart';
import 'package:tilmez_bus/core/routing/app_router.dart';
import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';

class TilmezBusApp extends ConsumerWidget {
  const TilmezBusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeControllerProvider).valueOrNull;

    return MaterialApp.router(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: (preferred, supported) {
        if (locale != null) return locale;
        // Default to Arabic when there's nothing stored — only fall back
        // to system / supported.first if Arabic isn't actually supported.
        return supported.firstWhere(
          (s) => s.languageCode == 'ar',
          orElse: () => supported.first,
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
