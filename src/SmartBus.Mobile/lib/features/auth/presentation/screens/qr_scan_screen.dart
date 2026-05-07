import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_bus/core/theme/app_theme.dart';
import 'package:smart_bus/l10n/generated/app_localizations.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _laser = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2500),
  )..repeat(reverse: true);

  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _laser.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: Stack(
          children: [
            // ── Camera viewport (placeholder dark gradient) ─────────────────
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.1,
                    colors: [Color(0xFF1A1A1A), Color(0xFF050505)],
                  ),
                ),
              ),
            ),

            // ── Dim overlay around the scan frame ───────────────────────────
            Positioned.fill(
              child: CustomPaint(painter: _ScanMaskPainter()),
            ),

            // ── Centered scan frame + tip ───────────────────────────────────
            // Frame anchored to a Stack-layer overlay so its centre lines up
            // exactly with the dim-mask cutout below it.
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final centerY = constraints.maxHeight *
                      (0.5 + _frameAlignmentY * 0.5);
                  final frameTop = centerY - _frameSide / 2;
                  return Stack(
                    children: [
                      Positioned(
                        top: frameTop,
                        left: 0,
                        right: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: _frameSide,
                              height: _frameSide,
                              child: Stack(
                                children: [
                                  const _ScanCorner(alignment: Alignment.topLeft),
                                  const _ScanCorner(alignment: Alignment.topRight),
                                  const _ScanCorner(alignment: Alignment.bottomLeft),
                                  const _ScanCorner(alignment: Alignment.bottomRight),
                                  AnimatedBuilder(
                                    animation: _laser,
                                    builder: (_, _) {
                                      final t = Curves.easeInOut.transform(_laser.value);
                                      // 8% .. 92% of frame.
                                      final top = _frameSide * (0.08 + 0.84 * t);
                                      return Positioned(
                                        top: top,
                                        left: 0,
                                        right: 0,
                                        child: const _LaserLine(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _ScanTip(label: l.scanTip),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── Back arrow pinned to the top-left corner ────────────────────
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child:
                      _GlassButton(icon: Icons.arrow_back, onTap: _close),
                ),
              ),
            ),

            // ── Bottom sheet (manual code entry) ────────────────────────────
            Align(
              alignment: Alignment.bottomCenter,
              child: _ManualCodeSheet(
                titleText: l.scanCantTitle,
                subText: l.scanCantSub,
                hint: l.scanCodeHint,
                buttonText: l.scanContinue,
                controller: _codeCtrl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top scan bar ────────────────────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 16, color: Colors.white),
        ),
      ),
    );
  }
}

// ── Scan frame corners + laser ──────────────────────────────────────────────

class _ScanCorner extends StatelessWidget {
  const _ScanCorner({required this.alignment});
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;
    final radius = BorderRadius.only(
      topLeft: isTop && isLeft ? const Radius.circular(14) : Radius.zero,
      topRight: isTop && !isLeft ? const Radius.circular(14) : Radius.zero,
      bottomLeft: !isTop && isLeft ? const Radius.circular(14) : Radius.zero,
      bottomRight: !isTop && !isLeft ? const Radius.circular(14) : Radius.zero,
    );
    final border = Border(
      top: isTop
          ? const BorderSide(color: AppColors.yellow, width: 3.5)
          : BorderSide.none,
      bottom: !isTop
          ? const BorderSide(color: AppColors.yellow, width: 3.5)
          : BorderSide.none,
      left: isLeft
          ? const BorderSide(color: AppColors.yellow, width: 3.5)
          : BorderSide.none,
      right: !isLeft
          ? const BorderSide(color: AppColors.yellow, width: 3.5)
          : BorderSide.none,
    );

    return Align(
      alignment: alignment,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          border: border,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: AppColors.yellow.withValues(alpha: 0.6),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}

class _LaserLine extends StatelessWidget {
  const _LaserLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.yellow,
            Colors.transparent,
          ],
        ),
        boxShadow: [
          BoxShadow(color: AppColors.yellow, blurRadius: 12),
        ],
      ),
    );
  }
}

class _ScanTip extends StatelessWidget {
  const _ScanTip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, size: 11, color: AppColors.yellow),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.05,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom sheet ────────────────────────────────────────────────────────────

class _ManualCodeSheet extends StatelessWidget {
  const _ManualCodeSheet({
    required this.titleText,
    required this.subText,
    required this.hint,
    required this.buttonText,
    required this.controller,
  });
  final String titleText;
  final String subText;
  final String hint;
  final String buttonText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 30,
            offset: Offset(0, -10),
            spreadRadius: -10,
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        18 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.slate200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            titleText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.slate500,
              letterSpacing: -0.05,
            ),
          ),
          const SizedBox(height: 12),
          _CodeInput(controller: controller, hint: hint),
          const SizedBox(height: 10),
          _DarkButton(label: buttonText, onTap: () {}),
        ],
      ),
    );
  }
}

class _CodeInput extends StatelessWidget {
  const _CodeInput({required this.controller, required this.hint});
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      textCapitalization: TextCapitalization.characters,
      maxLength: 9,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        letterSpacing: 1.5,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
      ],
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.slate400,
          fontWeight: FontWeight.w500,
          letterSpacing: 2,
        ),
        filled: true,
        fillColor: AppColors.slate50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.slate200, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.slate200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.yellowDeep, width: 1.5),
        ),
      ),
    );
  }
}

class _DarkButton extends StatelessWidget {
  const _DarkButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Darkens the area outside the centered 240×240 scan frame.
/// Vertical alignment used by both the visible bracket frame and this
/// dim-overlay cutout. Keep them in sync — the visible brackets live in an
/// `Align(alignment: Alignment(0, _frameAlignmentY))` above. Flutter's
/// Alignment maps `y` over half the height: centerY = h * (0.5 + y * 0.5).
const double _frameAlignmentY = -0.18;
const double _frameSide       = 240.0;

class _ScanMaskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dim = Paint()..color = const Color(0x66000000);
    final centerY = size.height * (0.5 + _frameAlignmentY * 0.5);
    final frameTop = centerY - _frameSide / 2;
    final left = (size.width - _frameSide) / 2;
    final frame = Rect.fromLTWH(left, frameTop, _frameSide, _frameSide);
    final whole = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(whole),
      Path()
        ..addRRect(RRect.fromRectAndRadius(frame, const Radius.circular(14))),
    );
    canvas.drawPath(path, dim);
  }

  @override
  bool shouldRepaint(covariant _ScanMaskPainter oldDelegate) => false;
}
