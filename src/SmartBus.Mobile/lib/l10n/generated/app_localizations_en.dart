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
  String get loginAppName => 'School Bus Tracker';

  @override
  String get loginAppSubtitle => 'Keep your child safe on every ride';

  @override
  String get loginBadgeSecure => 'Secure';

  @override
  String get loginBadgeLiveGps => 'Live GPS';

  @override
  String get loginBadgeTrusted => 'Trusted';

  @override
  String get loginEyebrow => 'Welcome Back';

  @override
  String get loginCardTitle => 'Sign in to continue';

  @override
  String get loginCardDesc => 'Choose how you\'d like to access your account';

  @override
  String get loginTabPhone => 'Phone';

  @override
  String get loginTabScan => 'Scan Card';

  @override
  String get loginPhoneLabel => 'Phone number';

  @override
  String get loginPhonePlaceholder => '7X XXX XXXX';

  @override
  String get loginPhoneHelp => 'We\'ll send a 4-digit verification code';

  @override
  String get loginSendOtp => 'Send verification code';

  @override
  String get loginTerms =>
      'By continuing you agree to our Terms and Privacy Policy';

  @override
  String get loginScanComingSoon => 'Scan card sign-in is coming soon';

  @override
  String get loginInvalidPhone => 'Enter a valid phone number';

  @override
  String get loginPhoneNotRegistered =>
      'This phone number isn\'t registered. Please contact your school administration.';

  @override
  String get loginNetworkError =>
      'Network error. Check your connection and try again.';

  @override
  String get loginUnknownError => 'Something went wrong. Please try again.';

  @override
  String get otpHeroTitle => 'Verify your number';

  @override
  String get otpHeroSubtitle => 'A code was sent to your device';

  @override
  String get otpEyebrow => 'Verification';

  @override
  String get otpTitle => 'Enter the 4-digit code';

  @override
  String get otpSentTo => 'Sent to';

  @override
  String get otpConfirm => 'Confirm & sign in';

  @override
  String get otpResendPrefix => 'Didn\'t receive it?';

  @override
  String get otpResend => 'Resend';

  @override
  String get otpInvalid => 'Invalid or expired code';

  @override
  String get otpFooter =>
      'Never share this code — School Bus Tracker will never ask for it';

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
  String get homeParentTitle => 'Parent Dashboard';

  @override
  String get homeDriverTitle => 'Driver Dashboard';

  @override
  String get homeAssistantTitle => 'Assistant Dashboard';

  @override
  String get homeParentTrack => 'Track Bus';

  @override
  String get homeParentTrips => 'Today\'s Trip';

  @override
  String get homeParentAbsence => 'Report Absence';

  @override
  String get homeDriverStartTrip => 'Start a Trip';

  @override
  String get homeDriverActiveTrip => 'Active Trip';

  @override
  String get homeDriverHistory => 'Trip History';

  @override
  String get homeDriverAttendance => 'Attendance';

  @override
  String get homeAssistantBoarding => 'Mark Boarding';

  @override
  String get homeAssistantScan => 'Scan Card';

  @override
  String get homeAssistantRoster => 'Today\'s Roster';

  @override
  String get parentGreetingEyebrow => 'Good morning';

  @override
  String get parentNoChildren => 'No children linked to your account yet.';

  @override
  String get parentNoTrips => 'No trips yet.';

  @override
  String get parentTripEyebrow => 'Last Trip';

  @override
  String get parentTripPickup => 'Pick-up';

  @override
  String get parentTripDropoff => 'Drop-off';

  @override
  String get parentMetaBus => 'Bus';

  @override
  String get parentMetaDriver => 'Driver';

  @override
  String get parentMetaDuration => 'Duration';

  @override
  String get parentDayToday => 'Today';

  @override
  String get parentDayYesterday => 'Yesterday';

  @override
  String get parentStatusArrived => 'Arrived safely';

  @override
  String get parentStatusOnBus => 'On the bus';

  @override
  String get parentStatusAwaiting => 'Awaiting today';

  @override
  String get parentSectionQuickActions => 'Quick actions';

  @override
  String get parentSectionRecentTrips => 'Recent trips';

  @override
  String get parentViewAll => 'View all';

  @override
  String get parentActionStudentInfo => 'Student Info';

  @override
  String get parentActionStudentInfoSub => 'View details';

  @override
  String get parentActionTripHistory => 'Trip History';

  @override
  String get parentActionTripHistorySub => 'Past trips';

  @override
  String get parentActionAbsence => 'Report Absence';

  @override
  String get parentActionAbsenceSub => 'Notify driver';

  @override
  String get parentTagOnTime => 'On time';

  @override
  String get parentTagAbsent => 'Absent';

  @override
  String get parentTagPending => 'Pending';

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
