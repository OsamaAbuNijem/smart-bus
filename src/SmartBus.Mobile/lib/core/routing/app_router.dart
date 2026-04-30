import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:smart_bus/features/auth/domain/entities/user.dart';
import 'package:smart_bus/features/auth/presentation/providers/auth_controller.dart';
import 'package:smart_bus/features/auth/presentation/providers/otp_controller.dart';
import 'package:smart_bus/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_bus/features/auth/presentation/screens/otp_screen.dart';
import 'package:smart_bus/features/auth/presentation/screens/splash_screen.dart';
import 'package:smart_bus/features/home/presentation/screens/assistant_home_screen.dart';
import 'package:smart_bus/features/home/presentation/screens/driver_home_screen.dart';
import 'package:smart_bus/features/home/presentation/screens/parent_home_screen.dart';
import 'package:smart_bus/features/onboarding/presentation/providers/onboarding_controller.dart';
import 'package:smart_bus/features/onboarding/presentation/screens/onboarding_screen.dart';

part 'app_router.g.dart';

abstract class AppRoute {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const otp = '/otp';
  static const homeParent = '/home/parent';
  static const homeDriver = '/home/driver';
  static const homeAssistant = '/home/assistant';

  static String homeFor(UserRole role) => switch (role) {
        UserRole.parent => homeParent,
        UserRole.driver => homeDriver,
        UserRole.assistant => homeAssistant,
      };

  static const _allHomes = [homeParent, homeDriver, homeAssistant];
  static bool isHome(String loc) => _allHomes.contains(loc);
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

      if (auth.isLoading || onboarding.isLoading) {
        return loc == AppRoute.splash ? null : AppRoute.splash;
      }

      final hasSeenOnboarding = onboarding.valueOrNull ?? false;
      final user = auth.valueOrNull;
      final loggedIn = user != null;

      if (!hasSeenOnboarding) {
        return loc == AppRoute.onboarding ? null : AppRoute.onboarding;
      }

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

      // Logged in — route to the role-specific home and keep them out of
      // splash / login / otp / onboarding / wrong-role homes.
      final correctHome = AppRoute.homeFor(user.role);
      if (loc == AppRoute.splash ||
          loc == AppRoute.login ||
          loc == AppRoute.otp ||
          loc == AppRoute.onboarding) {
        return correctHome;
      }
      if (AppRoute.isHome(loc) && loc != correctHome) {
        return correctHome;
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
        path: AppRoute.homeParent,
        builder: (_, _) => const ParentHomeScreen(),
      ),
      GoRoute(
        path: AppRoute.homeDriver,
        builder: (_, _) => const DriverHomeScreen(),
      ),
      GoRoute(
        path: AppRoute.homeAssistant,
        builder: (_, _) => const AssistantHomeScreen(),
      ),
    ],
  );
}

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
