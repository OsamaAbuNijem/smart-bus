import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smart_bus/features/auth/presentation/providers/auth_controller.dart';
import 'package:smart_bus/features/auth/presentation/providers/otp_controller.dart';
import 'package:smart_bus/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_bus/features/auth/presentation/screens/otp_screen.dart';
import 'package:smart_bus/features/auth/presentation/screens/splash_screen.dart';
import 'package:smart_bus/features/home/presentation/screens/home_screen.dart';
import 'package:smart_bus/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:smart_bus/features/onboarding/presentation/screens/onboarding_screen.dart';

part 'app_router.g.dart';

abstract class AppRoute {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const otp = '/otp';
  static const home = '/home';
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final notifier = _RouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: AppRoute.splash,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final onboarding = ref.read(onboardingControllerProvider);
      final loc = state.matchedLocation;

      // While initial loads are in flight, stay on splash.
      if (auth.isLoading || onboarding.isLoading) {
        return loc == AppRoute.splash ? null : AppRoute.splash;
      }

      final hasSeenOnboarding = onboarding.valueOrNull ?? false;
      final loggedIn = auth.valueOrNull != null;

      // First-launch flow: force onboarding before anything else.
      if (!hasSeenOnboarding) {
        return loc == AppRoute.onboarding ? null : AppRoute.onboarding;
      }

      // Onboarding done — gate by auth. State-driven: as soon as OTP is
      // pending, push to /otp; once cleared, push back to /login.
      if (!loggedIn) {
        final otpPending =
            ref.read(otpControllerProvider).valueOrNull is OtpPending;
        if (otpPending && loc != AppRoute.otp) return AppRoute.otp;
        if (!otpPending && loc == AppRoute.otp) return AppRoute.login;
        if (loc != AppRoute.login && loc != AppRoute.otp) {
          return AppRoute.login;
        }
        return null;
      }

      // Logged in — keep them out of splash/login/otp/onboarding.
      if (loc == AppRoute.splash ||
          loc == AppRoute.login ||
          loc == AppRoute.otp ||
          loc == AppRoute.onboarding) {
        return AppRoute.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoute.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoute.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoute.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.otp,
        builder: (_, _) => const OtpScreen(),
      ),
      GoRoute(
        path: AppRoute.home,
        builder: (_, _) => const HomeScreen(),
      ),
    ],
  );
}

/// Bridges Riverpod state changes (auth + onboarding) into a [Listenable]
/// that GoRouter reacts to via [GoRouter.refreshListenable].
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(this._ref) {
    _authSub = _ref.listen(
      authControllerProvider,
      (_, _) => notifyListeners(),
      fireImmediately: false,
    );
    _onboardingSub = _ref.listen(
      onboardingControllerProvider,
      (_, _) => notifyListeners(),
      fireImmediately: false,
    );
    _otpSub = _ref.listen(
      otpControllerProvider,
      (_, _) => notifyListeners(),
      fireImmediately: false,
    );
  }
  final Ref _ref;
  late final ProviderSubscription<Object?> _authSub;
  late final ProviderSubscription<Object?> _onboardingSub;
  late final ProviderSubscription<Object?> _otpSub;

  @override
  void dispose() {
    _authSub.close();
    _onboardingSub.close();
    _otpSub.close();
    super.dispose();
  }
}
