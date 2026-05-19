import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/features/auth/presentation/providers/auth_controller.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';

/// Shared scaffold for the per-role home screens. Lets each role render its
/// own body via [child] while sharing the app bar + sign-out action.
class RoleHomeScaffold extends ConsumerWidget {
  const RoleHomeScaffold({
    super.key,
    required this.title,
    required this.accentColor,
    required this.child,
  });

  final String title;
  final Color accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: l.navLogout,
            icon: const Icon(Icons.logout, size: 20),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (user != null)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.slate200),
                    boxShadow: AppShadows.md,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.person, color: accentColor, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.homeWelcome(user.fullName),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.phoneNumber,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.slate500,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 18),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
