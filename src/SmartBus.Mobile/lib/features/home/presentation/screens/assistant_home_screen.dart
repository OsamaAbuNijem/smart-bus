import 'package:flutter/material.dart';

import 'package:smart_bus/core/theme/app_theme.dart';
import 'package:smart_bus/features/home/presentation/widgets/role_home_scaffold.dart';
import 'package:smart_bus/l10n/generated/app_localizations.dart';

class AssistantHomeScreen extends StatelessWidget {
  const AssistantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return RoleHomeScaffold(
      title: l.homeAssistantTitle,
      accentColor: AppColors.violet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Tile(
            icon: Icons.how_to_reg,
            color: AppColors.emerald,
            title: l.homeAssistantBoarding,
          ),
          const SizedBox(height: 10),
          _Tile(
            icon: Icons.qr_code_scanner,
            color: AppColors.blue,
            title: l.homeAssistantScan,
          ),
          const SizedBox(height: 10),
          _Tile(
            icon: Icons.list_alt,
            color: AppColors.violet,
            title: l.homeAssistantRoster,
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.color, required this.title});
  final IconData icon;
  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -0.1,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.slate400,
            size: 20,
          ),
        ],
      ),
    );
  }
}
