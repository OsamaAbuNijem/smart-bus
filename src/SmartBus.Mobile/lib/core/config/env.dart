enum Flavor { dev, staging, prod }

class Env {
  Env._();

  static const String _flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );

  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// 10.0.2.2 is the Android emulator's loopback to the host's localhost.
  /// iOS simulator can use localhost directly. Switch via --dart-define.
  static const String _devAndroidEmulatorBase = 'http://10.0.2.2:8083';
  static const String _devLocalhostBase = 'http://localhost:8083';
  static const String _stagingBase = 'https://staging.smartbus.example/api';
  static const String _prodBase = 'https://api.smartbus.example';

  static Flavor get flavor => switch (_flavor) {
        'prod' => Flavor.prod,
        'staging' => Flavor.staging,
        _ => Flavor.dev,
      };

  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) return _apiBaseUrlOverride;
    return switch (flavor) {
      Flavor.prod => _prodBase,
      Flavor.staging => _stagingBase,
      Flavor.dev => _devAndroidEmulatorBase,
    };
  }

  /// API version segment, e.g. /api/v1
  static const String apiVersion = 'v1';

  /// Demo mode bypasses the live API entirely. Off by default — the app
  /// calls the real `/auth/otp/*` endpoints. Enable for offline UI demos:
  ///   flutter run --dart-define=DEMO_MODE=true
  static const bool _demoMode =
      bool.fromEnvironment('DEMO_MODE', defaultValue: false);
  static bool get demoMode => _demoMode;
  static const String demoOtp = '1234';

  /// Just the host part of [apiBaseUrl] when needed for SignalR etc.
  static String get apiHost => apiBaseUrl;

  static String get devLocalhostBase => _devLocalhostBase;

  static bool get isDev => flavor == Flavor.dev;
  static bool get isProd => flavor == Flavor.prod;
}
