import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_bus/core/locale/locale_controller.dart';
import 'package:smart_bus/core/routing/app_router.dart';
import 'package:smart_bus/core/theme/app_theme.dart';
import 'package:smart_bus/l10n/generated/app_localizations.dart';

class SmartBusApp extends ConsumerWidget {
  const SmartBusApp({super.key});

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
        if (preferred == null) return supported.first;
        for (final l in preferred) {
          for (final s in supported) {
            if (s.languageCode == l.languageCode) return s;
          }
        }
        return supported.first;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
