import 'package:flutter/material.dart';

import 'package:smart_bus/core/theme/app_theme.dart';
import 'package:smart_bus/features/home/presentation/widgets/role_home_scaffold.dart';
import 'package:smart_bus/l10n/generated/app_localizations.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return RoleHomeScaffold(
      title: l.homeDriverTitle,
      accentColor: AppColors.emerald,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StartTripCta(label: l.homeDriverStartTrip),
          const SizedBox(height: 14),
          _Tile(
            icon: Icons.directions_bus,
            color: AppColors.blue,
            title: l.homeDriverActiveTrip,
          ),
          const SizedBox(height: 10),
          _Tile(
            icon: Icons.history,
            color: AppColors.slate500,
            title: l.homeDriverHistory,
          ),
          const SizedBox(height: 10),
          _Tile(
            icon: Icons.checklist,
            color: AppColors.violet,
            title: l.homeDriverAttendance,
          ),
        ],
      ),
    );
  }
}

class _StartTripCta extends StatelessWidget {
  const _StartTripCta({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.yellow, AppColors.yellowDeep],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.yellow,
      ),
      child: Row(
        children: [
          const Icon(Icons.play_arrow_rounded, color: AppColors.ink, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward, color: AppColors.ink, size: 18),
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
