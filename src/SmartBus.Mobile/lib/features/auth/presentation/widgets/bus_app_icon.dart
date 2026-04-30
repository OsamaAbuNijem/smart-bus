import 'package:flutter/material.dart';

import 'package:smart_bus/core/theme/app_theme.dart';

/// 76×76 rounded badge with the bus illustration from
/// `Template/login-en (3).html`. Yellow gradient + soft glow.
class BusAppIcon extends StatelessWidget {
  const BusAppIcon({super.key, this.size = 76});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.29),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.yellow, AppColors.yellowDeep],
        ),
        boxShadow: AppShadows.yellow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.29),
        child: Stack(
          children: [
            // Subtle inner highlight
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            Center(
              child: SizedBox(
                width: size * 0.55,
                height: size * 0.55,
                child: const _BusIllustration(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BusIllustration extends StatelessWidget {
  const _BusIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BusPainter());
  }
}

class _BusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 48×48 logical canvas (matches template viewBox).
    final scaleX = size.width / 48;
    final scaleY = size.height / 48;
    canvas.scale(scaleX, scaleY);

    final body = Paint()..color = Colors.white;
    final windowFill = Paint()..color = AppColors.yellow;
    final windowStroke = Paint()
      ..color = AppColors.yellowDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final lightStroke = Paint()
      ..color = AppColors.yellowDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final wheelOuter = Paint()..color = AppColors.ink;
    final wheelInner = Paint()..color = Colors.white;
    final tail = Paint()..color = const Color(0xFFEF4444);

    // Body 8,14 → 32×22, radius 5
    final bodyRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(8, 14, 32, 22),
      const Radius.circular(5),
    );
    canvas.drawRRect(bodyRect, body);

    // Three windows at x=11,19,27, y=18, 6×7, radius 1.5
    for (final x in [11.0, 19.0, 27.0]) {
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 18, 6, 7),
        const Radius.circular(1.5),
      );
      canvas.drawRRect(r, windowFill);
      canvas.drawRRect(r, windowStroke);
    }

    // Driver light at 35,20, 3×5
    final light = RRect.fromRectAndRadius(
      const Rect.fromLTWH(35, 20, 3, 5),
      const Radius.circular(1),
    );
    canvas.drawRRect(light, body);
    canvas.drawRRect(light, lightStroke);

    // Wheels at (15,38) and (33,38) radius 3.5 with white center 1.5
    canvas.drawCircle(const Offset(15, 38), 3.5, wheelOuter);
    canvas.drawCircle(const Offset(15, 38), 1.5, wheelInner);
    canvas.drawCircle(const Offset(33, 38), 3.5, wheelOuter);
    canvas.drawCircle(const Offset(33, 38), 1.5, wheelInner);

    // Red tail bar at 9,29, 3×2
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(9, 29, 3, 2),
        const Radius.circular(0.5),
      ),
      tail,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
