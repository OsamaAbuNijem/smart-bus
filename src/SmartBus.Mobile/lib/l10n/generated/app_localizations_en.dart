// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SmartBus';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get loginAppName => 'School Bus Tracker';

  @override
  String get loginAppSubtitle => 'Keep your child safe on the road';

  @override
  String get loginFeatureSafety => 'Safety';

  @override
  String get loginFeatureLiveTrack => 'Live Track';

  @override
  String get loginFeaturePeace => 'Peace';

  @override
  String get loginPhonePlaceholder => '7X XXX XXXX';

  @override
  String get loginSendOtp => 'Send Verification Code';

  @override
  String get loginSendOtpHint => 'Get a 4-digit code on your phone';

  @override
  String get loginTerms => 'Accept Terms & Privacy Policy';

  @override
  String get loginInvalidPhone => 'Enter a valid phone number';

  @override
  String get loginUnknownError => 'Something went wrong. Please try again.';

  @override
  String get otpTitle => 'Enter Verification Code';

  @override
  String get otpConfirm => 'Confirm & Sign In';

  @override
  String get otpResendPrefix => 'Didn\'t receive it?';

  @override
  String get otpResend => 'Resend';

  @override
  String otpExpires(String time) {
    return 'Expires $time';
  }

  @override
  String get otpInvalid => 'Invalid or expired code';

  @override
  String get otpFooter => 'Your code is private, never share it with anyone';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navTrips => 'Trips';

  @override
  String get navStudents => 'Students';

  @override
  String get navDrivers => 'Drivers';

  @override
  String get navBuses => 'Buses';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navSettings => 'Settings';

  @override
  String get navLogout => 'Sign out';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationEmail => 'Enter a valid email';

  @override
  String get validationPhone => 'Enter a valid phone number';

  @override
  String get validationNationalNumber => 'Enter a valid national number';

  @override
  String validationMinLength(int n) {
    return 'Must be at least $n characters';
  }

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonOk => 'OK';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonLoading => 'Loading…';

  @override
  String homeWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingTitle1 => 'Track buses in real time';

  @override
  String get onboardingDescription1 =>
      'See exactly where your child\'s bus is, every step of the way.';

  @override
  String get onboardingTitle2 => 'Arrival alerts';

  @override
  String get onboardingDescription2 =>
      'Get notified for pickup, drop-off, and unexpected delays.';

  @override
  String get onboardingTitle3 => 'Stay connected';

  @override
  String get onboardingDescription3 =>
      'Direct line to drivers and school staff when it matters.';
}
