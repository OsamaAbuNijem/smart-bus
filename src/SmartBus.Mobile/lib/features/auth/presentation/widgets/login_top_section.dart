import 'package:flutter/material.dart';

import 'package:smart_bus/core/theme/app_theme.dart';
import 'package:smart_bus/features/auth/presentation/widgets/bus_app_icon.dart';
import 'package:smart_bus/l10n/generated/app_localizations.dart';

/// Hero used by Login + OTP screens: bus icon → app name → subtitle →
/// 3 pill badges (Secure / Live GPS / Trusted).
class LoginTopSection extends StatelessWidget {
  const LoginTopSection({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBadges = true,
  });

  final String title;
  final String subtitle;
  final bool showBadges;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 14),
      child: Column(
        children: [
          const BusAppIcon(),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              letterSpacing: -0.6,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.slate500,
              letterSpacing: -0.05,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (showBadges) ...[
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _Badge(
                  icon: Icons.shield_outlined,
                  label: l.loginBadgeSecure,
                  color: AppColors.blue,
                  bg: AppColors.blueSoft.withValues(alpha: 0.7),
                  border: const Color(0xFFBFDBFE),
                ),
                _Badge(
                  icon: Icons.access_time,
                  label: l.loginBadgeLiveGps,
                  color: AppColors.emerald,
                  bg: AppColors.emeraldSoft.withValues(alpha: 0.6),
                  border: const Color(0xFFA7F3D0),
                ),
                _Badge(
                  icon: Icons.lock_outline,
                  label: l.loginBadgeTrusted,
                  color: AppColors.violet,
                  bg: AppColors.violetSoft.withValues(alpha: 0.6),
                  border: const Color(0xFFDDD6FE),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.border,
  });
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: -0.05,
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft yellow + blue radial orbs, matching the template `body` background.
class LoginBackdrop extends StatelessWidget {
  const LoginBackdrop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.yellowTint,
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: -60,
          left: -50,
          child: _Orb(color: AppColors.yellow.withValues(alpha: 0.45), size: 200),
        ),
        Positioned(
          top: 120,
          right: -40,
          child: _Orb(
            color: AppColors.blueSoft.withValues(alpha: 0.7),
            size: 160,
          ),
        ),
        child,
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
