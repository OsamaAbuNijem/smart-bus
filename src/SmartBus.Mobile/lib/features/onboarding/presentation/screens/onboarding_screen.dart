import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_bus/core/routing/app_router.dart';
import 'package:smart_bus/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:smart_bus/l10n/generated/app_localizations.dart';

class _Slide {
  const _Slide({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String Function(AppLocalizations l) title;
  final String Function(AppLocalizations l) description;
}

const _slides = <_Slide>[
  _Slide(
    icon: Icons.directions_bus_filled,
    title: _t1,
    description: _d1,
  ),
  _Slide(
    icon: Icons.notifications_active,
    title: _t2,
    description: _d2,
  ),
  _Slide(
    icon: Icons.shield_outlined,
    title: _t3,
    description: _d3,
  ),
];

String _t1(AppLocalizations l) => l.onboardingTitle1;
String _d1(AppLocalizations l) => l.onboardingDescription1;
String _t2(AppLocalizations l) => l.onboardingTitle2;
String _d2(AppLocalizations l) => l.onboardingDescription2;
String _t3(AppLocalizations l) => l.onboardingTitle3;
String _d3(AppLocalizations l) => l.onboardingDescription3;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _slides.length - 1;

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
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: TextButton(
                onPressed: _isLast ? null : _finish,
                child: Text(l.onboardingSkip),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            _Dots(count: _slides.length, index: _index),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FilledButton(
                onPressed: _next,
                child: Text(_isLast ? l.onboardingGetStarted : l.onboardingNext),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(slide.icon, size: 120, color: theme.colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            slide.title(l),
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            slide.description(l),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: active ? 24 : 8,
          decoration: BoxDecoration(
            color: active ? scheme.primary : scheme.outlineVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

