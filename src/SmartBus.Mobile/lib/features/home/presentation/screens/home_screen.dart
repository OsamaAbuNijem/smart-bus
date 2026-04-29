import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_bus/features/auth/presentation/providers/auth_controller.dart';
import 'package:smart_bus/l10n/generated/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.navDashboard),
        actions: [
          IconButton(
            tooltip: l.navLogout,
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: Text(
          l.homeWelcome(user?.fullName ?? ''),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
