import 'package:flutter/material.dart';

import 'package:smart_bus/core/theme/app_theme.dart';
import 'package:smart_bus/l10n/generated/app_localizations.dart';

/// Hero used by [LoginScreen] and [OtpScreen]: bus badge → app name →
/// subtitle → 3-feature row (Safety / Live Track / Peace).
class LoginTopSection extends StatelessWidget {
  const LoginTopSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
      child: Column(
        children: [
          const _BusBadge(),
          const SizedBox(height: 16),
          Text(
            l.loginAppName,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.loginAppSubtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.text2,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FeatureChip(
                bg: AppColors.blueLight,
                icon: Icons.shield_outlined,
                color: AppColors.blue,
                label: l.loginFeatureSafety,
              ),
              const SizedBox(width: 22),
              _FeatureChip(
                bg: AppColors.yellowLight,
                icon: Icons.gps_fixed,
                color: AppColors.yellowDark,
                label: l.loginFeatureLiveTrack,
              ),
              const SizedBox(width: 22),
              _FeatureChip(
                bg: AppColors.purpleLight,
                icon: Icons.favorite_outline,
                color: AppColors.purple,
                label: l.loginFeaturePeace,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BusBadge extends StatelessWidget {
  const _BusBadge();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.yellow.withValues(alpha: 0.18),
          ),
        ),
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.yellow,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.yellowDark.withValues(alpha: 0.30),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.directions_bus_filled,
            color: Colors.white,
            size: 36,
          ),
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.bg,
    required this.icon,
    required this.color,
    required this.label,
  });
  final Color bg;
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.text2,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
