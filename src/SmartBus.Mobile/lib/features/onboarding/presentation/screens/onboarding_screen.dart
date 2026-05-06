import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_bus/core/routing/app_router.dart';
import 'package:smart_bus/core/theme/app_theme.dart';
import 'package:smart_bus/features/auth/presentation/screens/login_screen.dart' show LangSwitchButton;
import 'package:smart_bus/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:smart_bus/l10n/generated/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pager = PageController();
  int _index = 0;

  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  )..repeat();

  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4000),
  )..repeat(reverse: true);

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  )..repeat();

  @override
  void dispose() {
    _pager.dispose();
    _spin.dispose();
    _float.dispose();
    _pulse.dispose();
    super.dispose();
  }

  bool get _isLast => _index == 2;

  Future<void> _finish() async {
    await ref.read(onboardingControllerProvider.notifier).markSeen();
    if (!mounted) return;
    context.go(AppRoute.login);
  }

  void _next() {
    if (_isLast) {
      unawaited(_finish());
      return;
    }
    _pager.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 52),
                Expanded(
                  child: PageView(
                    controller: _pager,
                    onPageChanged: (i) => setState(() => _index = i),
                    children: [
                      _Slide(
                        spin: _spin,
                        stepIndex: 0,
                        totalSteps: 3,
                        title: l.onboardingTitle1,
                        description: l.onboardingDescription1,
                        primaryLabel: l.onboardingContinue,
                        onPrimary: _next,
                        footer: _PlainFooter(text: l.onboardingFooter1),
                        artBg: const _ArtBg(tint: AppColors.yellowTint),
                        artBuilder: (_) => const _BusArt(),
                      ),
                      _Slide(
                        spin: _spin,
                        stepIndex: 1,
                        totalSteps: 3,
                        title: l.onboardingTitle2,
                        description: l.onboardingDescription2,
                        primaryLabel: l.onboardingContinue,
                        onPrimary: _next,
                        footer: _PlainFooter(text: l.onboardingFooter2),
                        artBg: const _ArtBg(tint: AppColors.blueSoft),
                        artBuilder: (_) => _BellArt(l: l, float: _float),
                      ),
                      _Slide(
                        spin: _spin,
                        stepIndex: 2,
                        totalSteps: 3,
                        title: l.onboardingTitle3,
                        description: l.onboardingDescription3,
                        primaryLabel: l.onboardingGetStarted,
                        onPrimary: _next,
                        secondaryLabel: l.onboardingHasAccount,
                        onSecondary: _finish,
                        footer: _TermsFooter(l: l),
                        artBg: _ArtBg(
                          tint: AppColors.emeraldSoft.withValues(alpha: 0.7),
                        ),
                        artBuilder: (_) => _ShieldArt(pulse: _pulse),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            PositionedDirectional(
              top: 8,
              start: 12,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isLast ? 0 : 1,
                child: IgnorePointer(
                  ignoring: _isLast,
                  child: _SkipButton(label: l.onboardingSkip, onTap: _finish),
                ),
              ),
            ),
            const PositionedDirectional(
              top: 10,
              end: 14,
              child: LangSwitchButton(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Slide layout ────────────────────────────────────────────────────────────

class _Slide extends StatelessWidget {
  const _Slide({
    required this.spin,
    required this.stepIndex,
    required this.totalSteps,
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.onPrimary,
    required this.footer,
    required this.artBg,
    required this.artBuilder,
    this.secondaryLabel,
    this.onSecondary,
  });

  final Animation<double> spin;
  final int stepIndex;
  final int totalSteps;
  final String title;
  final String description;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Widget footer;
  final Widget artBg;
  final Widget Function(BuildContext) artBuilder;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: _ArtFrame(
              spin: spin,
              background: artBg,
              child: artBuilder(context),
            ),
          ),
          const SizedBox(height: 14),
          _Dots(count: totalSteps, index: stepIndex),
          const SizedBox(height: 16),
          _StepBadge(label: l.onboardingStep(stepIndex + 1, totalSteps)),
          const SizedBox(height: 12),
          _Title(html: title),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.slate500,
                letterSpacing: -0.05,
                height: 1.5,
              ),
            ),
          ),
          const Spacer(),
          _PrimaryButton(label: primaryLabel, onTap: onPrimary),
          if (secondaryLabel != null) ...[
            const SizedBox(height: 4),
            TextButton(
              onPressed: onSecondary,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.slate500,
                minimumSize: const Size.fromHeight(40),
              ),
              child: Text(
                secondaryLabel!,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate500,
                  letterSpacing: -0.05,
                ),
              ),
            ),
          ],
          const SizedBox(height: 6),
          footer,
        ],
      ),
    );
  }
}

// ── Top bar buttons ─────────────────────────────────────────────────────────

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate500,
                  letterSpacing: -0.05,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                size: 14,
                color: AppColors.slate500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dots indicator ──────────────────────────────────────────────────────────

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 6,
          width: active ? 24 : 6,
          decoration: BoxDecoration(
            color: active ? AppColors.yellowDeep : AppColors.slate200,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// ── Step badge ("Step 1 of 3") ─────────────────────────────────────────────

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.yellowTint,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.yellow.withValues(alpha: 0.25)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.yellowDeep,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

// ── Title with `<b>` accent ─────────────────────────────────────────────────

class _Title extends StatelessWidget {
  const _Title({required this.html});
  final String html;

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      color: AppColors.ink,
      letterSpacing: -0.7,
      height: 1.15,
    );
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: base,
        children: _parseBoldSpans(html, accent: AppColors.yellowDeep),
      ),
    );
  }
}

List<TextSpan> _parseBoldSpans(String input, {required Color accent}) {
  final out = <TextSpan>[];
  final pattern = RegExp(r'<b>(.*?)</b>');
  var last = 0;
  for (final m in pattern.allMatches(input)) {
    if (m.start > last) {
      out.add(TextSpan(text: input.substring(last, m.start)));
    }
    out.add(
      TextSpan(text: m.group(1), style: TextStyle(color: accent)),
    );
    last = m.end;
  }
  if (last < input.length) {
    out.add(TextSpan(text: input.substring(last)));
  }
  return out;
}

// ── Primary CTA (yellow gradient) ───────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.yellow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.yellow, AppColors.yellowDeep],
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 14, color: AppColors.ink),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Footers ─────────────────────────────────────────────────────────────────

class _PlainFooter extends StatelessWidget {
  const _PlainFooter({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
          color: AppColors.slate400,
          letterSpacing: -0.05,
          height: 1.5,
        ),
      ),
    );
  }
}

class _TermsFooter extends StatelessWidget {
  const _TermsFooter({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    const muted = TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w500,
      color: AppColors.slate400,
      letterSpacing: -0.05,
      height: 1.5,
    );
    const link = TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      color: AppColors.slate700,
      letterSpacing: -0.05,
      height: 1.5,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: muted,
          children: [
            TextSpan(text: l.onboardingFooterTermsPrefix),
            TextSpan(text: l.onboardingFooterTerms, style: link),
            TextSpan(text: l.onboardingFooterAnd),
            TextSpan(text: l.onboardingFooterPrivacy, style: link),
          ],
        ),
      ),
    );
  }
}

// ── Art frame: radial blob + slowly-rotating dashed circle ──────────────────

class _ArtBg extends StatelessWidget {
  const _ArtBg({required this.tint});
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BlobPainter(tint: tint),
      size: Size.infinite,
    );
  }
}

class _BlobPainter extends CustomPainter {
  _BlobPainter({required this.tint});
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    const radius = 140.0;
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        colors: [tint, tint.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: c, radius: radius));
    canvas.drawCircle(c, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _BlobPainter old) => old.tint != tint;
}

class _ArtFrame extends StatelessWidget {
  const _ArtFrame({
    required this.spin,
    required this.background,
    required this.child,
  });
  final Animation<double> spin;
  final Widget background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: background),
        SizedBox(
          width: 220,
          height: 220,
          child: AnimatedBuilder(
            animation: spin,
            builder: (_, _) => Transform.rotate(
              angle: spin.value * 2 * math.pi,
              child: CustomPaint(painter: _DashedCirclePainter()),
            ),
          ),
        ),
        SizedBox(
          width: 240,
          height: 240,
          child: FittedBox(child: SizedBox(width: 240, height: 240, child: child)),
        ),
      ],
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    final paint = Paint()
      ..color = AppColors.slate200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final circumference = 2 * math.pi * r;
    const dash = 6.0;
    const gap = 6.0;
    const total = dash + gap;
    final dashCount = (circumference / total).floor();
    final sweepDash = (dash / circumference) * 2 * math.pi;
    final sweepGap = (gap / circumference) * 2 * math.pi;

    final rect = Rect.fromCircle(center: c, radius: r);
    var start = -math.pi / 2;
    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(rect, start, sweepDash, false, paint);
      start += sweepDash + sweepGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) => false;
}

// ── Illustrations ───────────────────────────────────────────────────────────
// Each painter draws into a 240×240 canvas matching the HTML SVG viewBox.

class _BusArt extends StatelessWidget {
  const _BusArt();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BusPainter(), size: const Size(240, 240));
  }
}

class _BusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final inkFill = Paint()..color = AppColors.ink;
    final white = Paint()..color = Colors.white;

    // Dashed route path
    final route = Path()
      ..moveTo(30, 200)
      ..quadraticBezierTo(60, 180, 90, 190)
      ..quadraticBezierTo(120, 200, 160, 160)
      ..quadraticBezierTo(200, 140, 210, 90);
    final routePaint = Paint()
      ..color = AppColors.yellowDeep.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    _drawDashed(canvas, route, routePaint, dash: 4, gap: 6);

    // Start pin
    canvas.drawCircle(const Offset(30, 200), 9, white);
    canvas.drawCircle(const Offset(30, 200), 9, ink);
    canvas.drawCircle(const Offset(30, 200), 3, inkFill);

    // End pin (school)
    final endPin = Path()
      ..moveTo(210, 90)
      ..cubicTo(210, 78, 200, 68, 188, 68)
      ..cubicTo(176, 68, 166, 78, 166, 90)
      ..cubicTo(166, 104, 188, 124, 188, 124)
      ..cubicTo(188, 124, 210, 104, 210, 90)
      ..close();
    canvas.drawPath(endPin, Paint()..color = const Color(0xFFE11D48));
    canvas.drawPath(endPin, ink);
    canvas.drawCircle(const Offset(188, 89), 6, white);

    // Bus group, translated by (60, 100)
    canvas.save();
    canvas.translate(60, 100);

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 78), width: 100, height: 10),
      Paint()..color = AppColors.ink.withValues(alpha: 0.10),
    );

    // Body
    final bodyRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(6, 10, 108, 60),
      const Radius.circular(12),
    );
    canvas.drawRRect(bodyRect, Paint()..color = AppColors.yellow);
    canvas.drawRRect(bodyRect, ink);

    // Lower stripe
    const stripe = Rect.fromLTWH(6, 58, 108, 12);
    canvas.save();
    canvas.clipRRect(bodyRect);
    canvas.drawRect(stripe, Paint()..color = AppColors.yellowDeep);
    canvas.restore();
    canvas.drawLine(const Offset(6, 58), const Offset(114, 58), ink);

    // Windows + door
    final winInk = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    void window(double x, double y, double w, double h, double r) {
      final rr =
          RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
      canvas.drawRRect(rr, Paint()..color = const Color(0xFFDBEAFE));
      canvas.drawRRect(rr, winInk);
    }

    window(14, 18, 22, 22, 4);
    window(42, 18, 22, 22, 4);
    window(70, 18, 22, 22, 4);
    window(96, 18, 14, 32, 3);

    // Headlight
    final hlStroke = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(const Offset(110, 56), 2.5, white);
    canvas.drawCircle(const Offset(110, 56), 2.5, hlStroke);

    // Wheels
    void wheel(double cx, double cy) {
      canvas.drawCircle(Offset(cx, cy), 10, inkFill);
      canvas.drawCircle(Offset(cx, cy), 4, white);
    }

    wheel(28, 72);
    wheel(92, 72);

    canvas.restore();

    // Speed lines
    final speed = Paint()
      ..color = AppColors.slate400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(40, 135), const Offset(55, 135),
        Paint.from(speed)..color = AppColors.slate400.withValues(alpha: 0.6));
    canvas.drawLine(const Offset(44, 148), const Offset(56, 148),
        Paint.from(speed)..color = AppColors.slate400.withValues(alpha: 0.5));
  }

  @override
  bool shouldRepaint(covariant _BusPainter old) => false;
}

class _BellArt extends StatelessWidget {
  const _BellArt({required this.l, required this.float});
  final AppLocalizations l;
  final Animation<double> float;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _BellPainter()),
          ),
          _floating(
            top: 20,
            start: -18,
            offset: 0,
            child: _MiniCard(
              icon: Icons.check,
              iconBg: AppColors.emeraldSoft,
              iconColor: AppColors.emerald,
              title: l.onboardingMiniCardPickedUp,
              sub: l.onboardingMiniCardPickedUpSub,
            ),
          ),
          _floating(
            top: 110,
            end: -22,
            offset: 0.6,
            child: _MiniCard(
              icon: Icons.access_time,
              iconBg: AppColors.yellowTint,
              iconColor: AppColors.yellowDeep,
              title: l.onboardingMiniCardEta,
              sub: l.onboardingMiniCardEtaSub,
            ),
          ),
          _floating(
            bottom: 18,
            start: 8,
            offset: 1.2,
            child: _MiniCard(
              icon: Icons.refresh,
              iconBg: AppColors.blueSoft,
              iconColor: AppColors.blue,
              title: l.onboardingMiniCardOnTheWay,
              sub: l.onboardingMiniCardOnTheWaySub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _floating({
    double? top,
    double? bottom,
    double? start,
    double? end,
    required double offset,
    required Widget child,
  }) {
    return PositionedDirectional(
      top: top,
      bottom: bottom,
      start: start,
      end: end,
      child: AnimatedBuilder(
        animation: float,
        builder: (_, c) {
          final t = (math.sin((float.value + offset) * math.pi) + 1) / 2;
          final dy = -6 * t;
          return Transform.translate(offset: Offset(0, dy), child: c);
        },
        child: child,
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.sub,
  });
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate100),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: -0.1,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                sub,
                style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.slate500,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BellPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final inkFill = Paint()..color = AppColors.ink;

    // Bell shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(120, 200), width: 100, height: 10),
      Paint()..color = AppColors.ink.withValues(alpha: 0.10),
    );

    // Bell body
    final bell = Path()
      ..moveTo(120, 60)
      ..cubicTo(88, 60, 70, 84, 70, 120)
      ..lineTo(70, 150)
      ..lineTo(60, 162)
      ..lineTo(60, 170)
      ..lineTo(180, 170)
      ..lineTo(180, 162)
      ..lineTo(170, 150)
      ..lineTo(170, 120)
      ..cubicTo(170, 84, 152, 60, 120, 60)
      ..close();
    canvas.drawPath(bell, Paint()..color = AppColors.yellow);
    canvas.drawPath(bell, ink);

    // Highlight
    final highlight = Path()
      ..moveTo(88, 90)
      ..cubicTo(84, 100, 82, 112, 82, 122);
    canvas.drawPath(
      highlight,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Top knob
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(112, 48, 16, 16),
        const Radius.circular(4),
      ),
      inkFill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(108, 44, 24, 8),
        const Radius.circular(3),
      ),
      inkFill,
    );

    // Clapper
    canvas.drawCircle(const Offset(120, 178), 10, inkFill);

    // Notification badge
    canvas.drawCircle(const Offset(170, 76), 18,
        Paint()..color = const Color(0xFFE11D48));
    canvas.drawCircle(
      const Offset(170, 76),
      18,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: '3',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(170 - tp.width / 2, 76 - tp.height / 2),
    );

    // Sound waves
    void wave(Path p, double opacity) {
      canvas.drawPath(
        p,
        Paint()
          ..color = AppColors.yellowDeep.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    wave(
      Path()
        ..moveTo(40, 110)
        ..quadraticBezierTo(30, 120, 40, 130),
      0.7,
    );
    wave(
      Path()
        ..moveTo(28, 100)
        ..quadraticBezierTo(14, 120, 28, 140),
      0.4,
    );
    wave(
      Path()
        ..moveTo(200, 110)
        ..quadraticBezierTo(210, 120, 200, 130),
      0.7,
    );
    wave(
      Path()
        ..moveTo(212, 100)
        ..quadraticBezierTo(226, 120, 212, 140),
      0.4,
    );
  }

  @override
  bool shouldRepaint(covariant _BellPainter old) => false;
}

class _ShieldArt extends StatelessWidget {
  const _ShieldArt({required this.pulse});
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: pulse,
            builder: (_, _) {
              final t = pulse.value;
              return SizedBox(
                width: 220,
                height: 220,
                child: CustomPaint(painter: _PulseRingsPainter(t: t)),
              );
            },
          ),
          CustomPaint(painter: _ShieldPainter(), size: const Size(240, 240)),
        ],
      ),
    );
  }
}

class _PulseRingsPainter extends CustomPainter {
  _PulseRingsPainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    void ring(double phase) {
      final p = (t + phase) % 1.0;
      final scale = 0.7 + (1.2 - 0.7) * p;
      final opacity = (1 - p) * 0.6;
      canvas.drawCircle(
        c,
        size.width / 2 * scale,
        Paint()
          ..color = AppColors.emerald.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    ring(0);
    ring(0.5);
  }

  @override
  bool shouldRepaint(covariant _PulseRingsPainter old) => old.t != t;
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Shield shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(120, 210), width: 96, height: 10),
      Paint()..color = AppColors.ink.withValues(alpha: 0.10),
    );

    // Shield outer
    final shield = Path()
      ..moveTo(120, 30)
      ..lineTo(60, 56)
      ..lineTo(60, 120)
      ..cubicTo(60, 162, 88, 196, 120, 208)
      ..cubicTo(152, 196, 180, 162, 180, 120)
      ..lineTo(180, 56)
      ..close();
    canvas.drawPath(shield, Paint()..color = AppColors.yellow);
    canvas.drawPath(shield, ink);

    // Inner highlight
    final hl = Path()
      ..moveTo(120, 44)
      ..lineTo(74, 64)
      ..lineTo(74, 122)
      ..cubicTo(74, 156, 96, 184, 120, 194);
    canvas.drawPath(
      hl,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Inner circle
    canvas.drawCircle(const Offset(120, 118), 32, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(120, 118), 32, ink);

    // Big checkmark
    final check = Path()
      ..moveTo(106, 118)
      ..lineTo(117, 130)
      ..lineTo(136, 108);
    canvas.drawPath(
      check,
      Paint()
        ..color = AppColors.emerald
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Small star accents
    void star4(double cx, double cy, double r, Color color) {
      final p = Path()
        ..moveTo(cx - r, cy)
        ..lineTo(cx - r * 0.5, cy - r * 0.5)
        ..lineTo(cx, cy - r)
        ..lineTo(cx + r * 0.5, cy - r * 0.5)
        ..lineTo(cx + r, cy)
        ..lineTo(cx + r * 0.5, cy + r * 0.5)
        ..lineTo(cx, cy + r)
        ..lineTo(cx - r * 0.5, cy + r * 0.5)
        ..close();
      canvas.drawPath(p, Paint()..color = color);
    }

    star4(50, 82, 5, AppColors.yellowDeep);
    star4(194, 92, 5, AppColors.yellowDeep);
    star4(201, 161, 2.5, AppColors.emerald);
  }

  @override
  bool shouldRepaint(covariant _ShieldPainter old) => false;
}

// ── Dashed-stroke helper ────────────────────────────────────────────────────

void _drawDashed(
  Canvas canvas,
  Path source,
  Paint paint, {
  required double dash,
  required double gap,
}) {
  for (final metric in source.computeMetrics()) {
    var distance = 0.0;
    while (distance < metric.length) {
      final next = distance + dash;
      canvas.drawPath(
        metric.extractPath(distance, math.min(next, metric.length)),
        paint,
      );
      distance = next + gap;
    }
  }
}
