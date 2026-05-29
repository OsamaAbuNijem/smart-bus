// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TilmezBus';

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
  String get loginTagline => 'Track every ride. Every child. Every time.';

  @override
  String get loginCardTitle => 'Sign in';

  @override
  String get loginCardDesc => 'Enter your phone, we\'ll send a 4-digit code.';

  @override
  String get loginTabPhone => 'Phone';

  @override
  String get loginTabScan => 'Scan Card';

  @override
  String get loginPhoneLabel => 'Phone number';

  @override
  String get loginPhonePlaceholder => '7X XXX XXXX';

  @override
  String get loginSendOtp => 'Send code';

  @override
  String get loginTerms => 'By continuing you agree to our Terms and Privacy';

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
  String get otpTitle => 'Verify your number';

  @override
  String get otpSentTo => 'Sent to';

  @override
  String get otpConfirm => 'Verify';

  @override
  String get otpResendPrefix => 'Didn\'t receive it?';

  @override
  String get otpResend => 'Resend';

  @override
  String otpResendWait(String time) {
    return 'Please wait $time before resending';
  }

  @override
  String get otpInvalid => 'Invalid or expired code';

  @override
  String get otpFooter =>
      'Never share this code — TilmezBus will never ask for it';

  @override
  String get otpBack => 'Back';

  @override
  String get scanTitle => 'Register';

  @override
  String get scanSubtitle => 'Scan your student card';

  @override
  String get scanTip => 'Hold the card inside the frame';

  @override
  String get scanCantTitle => 'Can\'t scan?';

  @override
  String get scanCantSub => 'Enter the 8-digit code printed on your card';

  @override
  String get scanCodeHint => 'XXXX-XXXX';

  @override
  String get scanContinue => 'Continue';

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
  String get parentStatusWaitingPickup => 'Bus on the way';

  @override
  String get assistantStartAllAbsentTitle => 'Nothing to do';

  @override
  String get assistantStartAllAbsentBody =>
      'Every student on this trip is marked absent — there\'s nothing to drive.';

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
  String get studentInfoTitle => 'Student Info';

  @override
  String get studentInfoIdLabel => 'ID';

  @override
  String get studentInfoClassPrefix => 'Class';

  @override
  String get studentInfoGeneral => 'General Information';

  @override
  String get studentInfoDob => 'Date of Birth';

  @override
  String get studentInfoSchool => 'School';

  @override
  String get studentInfoHomeAddress => 'Home Address';

  @override
  String get studentInfoSchoolAddress => 'School Address';

  @override
  String get studentInfoRoute => 'Route';

  @override
  String get studentInfoNotes => 'Parent Notes';

  @override
  String get studentInfoEmergency => 'Emergency Contact';

  @override
  String get studentInfoParentContact => 'Parent Contact';

  @override
  String get studentInfoNoContacts => 'No contact on file.';

  @override
  String get studentEditEyebrow => 'Editing';

  @override
  String get studentEditBasicInfo => 'Basic Information';

  @override
  String get studentEditFullName => 'Full Name';

  @override
  String get studentEditFullNameHint => 'Student full name';

  @override
  String get studentEditStudentId => 'Student ID';

  @override
  String get studentEditAuto => 'Auto';

  @override
  String get studentEditGrade => 'Grade';

  @override
  String get studentEditClass => 'Class';

  @override
  String get studentEditClassHint => 'e.g. A';

  @override
  String get studentEditNotes => 'Notes';

  @override
  String get studentEditDriverNote => 'Note for the driver';

  @override
  String get studentEditNotesHint => 'Anything the driver should know?';

  @override
  String get studentEditParentInfo => 'Parent Info';

  @override
  String get studentEditVerified => 'Verified';

  @override
  String get studentEditParentNameHint => 'Parent full name';

  @override
  String get studentEditMobile => 'Mobile Number';

  @override
  String get studentEditSave => 'Save changes';

  @override
  String get studentEditSaved => 'Saved';

  @override
  String get studentEditFailed => 'Couldn\'t save. Please try again.';

  @override
  String get studentEditMissingFields => 'Please fill in the required fields.';

  @override
  String get tripHistoryTitle => 'Trip History';

  @override
  String get tripHistoryLast7 => 'Last 7 days';

  @override
  String get tripHistoryThisWeek => 'This week';

  @override
  String get tripHistoryToday => 'Today';

  @override
  String get tripHistoryYesterday => 'Yesterday';

  @override
  String get tripHistoryMorningPickup => 'Morning Pickup';

  @override
  String get tripHistoryAfternoonDropoff => 'Afternoon Drop-off';

  @override
  String get tripHistoryOnTime => 'On time';

  @override
  String tripHistoryLateMinutes(int n) {
    return '+$n min late';
  }

  @override
  String get tripHistoryAbsent => 'Absent';

  @override
  String get tripHistoryPending => 'Pending';

  @override
  String get tripHistoryDriver => 'Driver';

  @override
  String get tripHistoryAssistant => 'Assistant';

  @override
  String get tripHistoryReportedAbsent => 'Reported absent';

  @override
  String get tripHistoryEmpty => 'No trips yet for this child.';

  @override
  String get absenceEyebrow => 'New Request';

  @override
  String get absenceTitle => 'Report Absence';

  @override
  String get absenceSubtitle =>
      'The driver and school will be notified instantly';

  @override
  String get absenceSectionStudent => 'Student';

  @override
  String get absenceSectionRequested => 'Requested absences';

  @override
  String get absenceSummaryTotal => 'Total absences';

  @override
  String get absenceSummaryMorning => 'Morning absences';

  @override
  String get absenceSummaryReturn => 'Return absences';

  @override
  String get absenceCancelWindowNote =>
      'You can cancel this absence anytime before the trip starts. Once the trip is in progress, it can\'t be cancelled.';

  @override
  String get absenceNoRequests => 'No absence requests for this week yet.';

  @override
  String get absenceCreateRequest => 'Create absence request';

  @override
  String get absenceCreateTitle => 'New absence request';

  @override
  String get absenceCreateSubtitle =>
      'Submit a one-off absence for this student';

  @override
  String get absenceStatusPending => 'Pending';

  @override
  String get absenceStatusApproved => 'Approved';

  @override
  String get absenceStatusRejected => 'Rejected';

  @override
  String get absenceCancelTitle => 'Cancel absence?';

  @override
  String get absenceCancelBody =>
      'The driver and school will be notified that the absence was cancelled.';

  @override
  String get absenceCancelYes => 'Cancel absence';

  @override
  String get absenceCancelled => 'Absence cancelled.';

  @override
  String get absenceSectionDate => 'Absence Date';

  @override
  String get absenceSectionService => 'Bus Service';

  @override
  String get absenceSectionReason => 'Reason';

  @override
  String get absenceSectionNote => 'Note for the driver';

  @override
  String get absenceOptional => '(optional)';

  @override
  String get absenceOptionFullTitle => 'Full day off';

  @override
  String get absenceOptionFullDesc => 'Student will not attend school today';

  @override
  String get absenceFullNote =>
      'No bus service today. Driver and school will be notified.';

  @override
  String get absenceOptionMorningTitle => 'Skip morning bus';

  @override
  String get absenceOptionMorningDesc =>
      'Parent will drop the student at school';

  @override
  String get absenceOptionReturnTitle => 'Skip return bus';

  @override
  String get absenceOptionReturnDesc =>
      'Parent will pick up the student from school';

  @override
  String get absenceReasonIllness => 'Illness';

  @override
  String get absenceReasonAppointment => 'Medical Appt';

  @override
  String get absenceReasonFamily => 'Family Matter';

  @override
  String get absenceReasonOther => 'Other';

  @override
  String get absenceNoteHint => 'Anything else the driver should know?';

  @override
  String get absenceInfoBox =>
      'You can cancel this request up to 30 minutes before the bus departs';

  @override
  String get absenceSubmit => 'Submit absence request';

  @override
  String get absenceSubmitted => 'Absence reported';

  @override
  String get absenceFailed => 'Couldn\'t submit. Please try again.';

  @override
  String get parentTrackLive => 'Track Live';

  @override
  String get liveTrackingLive => 'Live';

  @override
  String get liveTrackingMin => 'min';

  @override
  String get liveTrackingOnTime => 'On time';

  @override
  String get liveTrackingOnTheWaySchool => 'On the way to school';

  @override
  String get liveTrackingOnTheWayHome => 'On the way home';

  @override
  String get liveTrackingHome => 'Home';

  @override
  String get liveTrackingBoarded => 'Boarded';

  @override
  String get liveTrackingDistance => 'Distance';

  @override
  String get liveTrackingSpeed => 'Speed';

  @override
  String get liveTrackingArrives => 'Arrives';

  @override
  String get liveTrackingDriver => 'Driver';

  @override
  String get liveTrackingCall => 'Call';

  @override
  String get liveTrackingAssistant => 'Assistant';

  @override
  String get liveTrackingNoCrew => 'Crew not assigned yet';

  @override
  String liveTrackingLastUpdated(String when) {
    return 'Last updated $when';
  }

  @override
  String get liveTrackingJustNow => 'just now';

  @override
  String get liveTrackingNever => '—';

  @override
  String get liveTrackingTripEndedTitle => 'Trip ended';

  @override
  String get liveTrackingTripEndedBody => 'The assistant has ended this trip.';

  @override
  String get liveTrackingTripEndedClose => 'Close';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingHasAccount => 'I already have an account';

  @override
  String get onboardingLangSwitch => 'عربي';

  @override
  String onboardingStep(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get onboardingTitle1 => 'Track every ride <b>in real time</b>';

  @override
  String get onboardingDescription1 =>
      'See exactly where your child\'s bus is — from the first pickup to the school gate, on a live map.';

  @override
  String get onboardingTitle2 => 'Get notified <b>the moment</b> it matters';

  @override
  String get onboardingDescription2 =>
      'Pickup, drop-off, delays, arrivals — instant alerts so you\'re never left wondering.';

  @override
  String get onboardingTitle3 => 'Verified drivers, <b>safer rides</b>';

  @override
  String get onboardingDescription3 =>
      'Every driver is screened, every trip is logged. Peace of mind from morning bell to home.';

  @override
  String get onboardingFooter1 =>
      'Trusted by thousands of families across Jordan';

  @override
  String get onboardingFooter2 => 'Allow notifications anytime in Settings';

  @override
  String get onboardingFooterTermsPrefix => 'By continuing, you agree to our ';

  @override
  String get onboardingFooterTerms => 'Terms';

  @override
  String get onboardingFooterAnd => ' & ';

  @override
  String get onboardingFooterPrivacy => 'Privacy';

  @override
  String get onboardingMiniCardPickedUp => 'Picked up';

  @override
  String get onboardingMiniCardPickedUpSub => '7:42 AM';

  @override
  String get onboardingMiniCardEta => '5 min away';

  @override
  String get onboardingMiniCardEtaSub => 'From school';

  @override
  String get onboardingMiniCardOnTheWay => 'On the way';

  @override
  String get onboardingMiniCardOnTheWaySub => 'Driver: Ahmad';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEyebrow => 'Activity';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String notificationsCountSummary(int newCount, int total) {
    return '$newCount new · $total total';
  }

  @override
  String get notificationsToday => 'Today';

  @override
  String get notificationsYesterday => 'Yesterday';

  @override
  String notificationsDaysAgo(int days) {
    return '$days days ago';
  }

  @override
  String notificationsCountNew(int count) {
    return '$count new';
  }

  @override
  String notificationsCountItems(int count) {
    return '$count items';
  }

  @override
  String get notificationsEmptyTitle => 'No notifications yet';

  @override
  String get notificationsEmptySub =>
      'Updates about your child\'s trip will appear here.';

  @override
  String get assistantGreetMorning => 'Good morning';

  @override
  String get assistantGreetAfternoon => 'Good afternoon';

  @override
  String get assistantGreetEvening => 'Good evening';

  @override
  String get assistantTodaysTrips => 'Last trips';

  @override
  String get assistantScanBusQr => 'Scan Bus QR';

  @override
  String get assistantScanBusQrSub => 'Scan to start a new trip';

  @override
  String get assistantManualSetupCta => 'Or set up manually';

  @override
  String get assistantCreateNewTrip => 'Create new trip';

  @override
  String get assistantMorningPickup => 'Morning Pickup';

  @override
  String get assistantAfternoonDropoff => 'Afternoon Drop-off';

  @override
  String get assistantStartedAt => 'Started';

  @override
  String get assistantCreatedAt => 'Created';

  @override
  String get assistantBoarded => 'boarded';

  @override
  String get assistantStudents => 'students';

  @override
  String get assistantStatusLive => 'Live';

  @override
  String get assistantStatusDone => 'Done';

  @override
  String get assistantStatusScheduled => 'Scheduled';

  @override
  String get assistantNoTripsToday =>
      'No trips assigned for today.\nScan a bus QR to get started.';

  @override
  String get assistantTripSetupTitle => 'New Trip';

  @override
  String get assistantBusFromQr => 'From QR';

  @override
  String get assistantTripTypeLabel => 'Trip type';

  @override
  String get assistantTripTypeMorning => 'Morning';

  @override
  String get assistantTripTypeMorningSub => 'Home → School';

  @override
  String get assistantTripTypeAfternoon => 'Afternoon';

  @override
  String get assistantTripTypeAfternoonSub => 'School → Home';

  @override
  String get assistantStudentsAuto => 'Auto-loaded from last trip';

  @override
  String get assistantSkipRoster => 'Skip auto-roster';

  @override
  String get assistantSkipRosterHint =>
      'Start empty — students join when their QR/NFC is scanned.';

  @override
  String get assistantRosterSheetTitle => 'Auto-loaded students';

  @override
  String get assistantStartTrip => 'Start trip';

  @override
  String get assistantBusLabel => 'Bus';

  @override
  String get assistantDriverLabel => 'Driver';

  @override
  String get assistantQrEntryHint => 'Paste or type QR token';

  @override
  String get assistantQrEntryConfirm => 'Use this token';

  @override
  String get assistantQrSimulatorTitle => 'QR scanner unavailable in simulator';

  @override
  String get assistantQrSimulatorBody =>
      'Type or paste the bus QR token below to continue.';

  @override
  String get loginRoleParent => 'Parent';

  @override
  String get loginRoleDriver => 'Driver';

  @override
  String get loginRoleAssistant => 'Assistant';

  @override
  String get assistantSelectBus => 'Select a bus';

  @override
  String get assistantSelectDriver => 'Select a driver';

  @override
  String get assistantNoLastRoster =>
      'No prior trip on this bus + type. Trip will start with an empty roster.';

  @override
  String get assistantScanStudentTitle => 'Scan student QR';

  @override
  String get assistantScanStudentOk => 'Student boarded.';

  @override
  String get assistantNfcUnavailable => 'NFC isn\'t available on this device.';

  @override
  String get assistantNfcUnsupported => 'This device doesn\'t support NFC.';

  @override
  String get assistantNfcDisabled =>
      'NFC is turned off. Enable it from settings to scan.';

  @override
  String get assistantNfcHint =>
      'Hold the student\'s NFC card near the top of the phone.';

  @override
  String get assistantScanQr => 'Scan QR';

  @override
  String get assistantScanNfc => 'Scan NFC';

  @override
  String get assistantSearchByName => 'Search by name';

  @override
  String get assistantRosterHeader => 'Students on this trip';

  @override
  String get assistantRosterEmpty => 'Add at least one student before starting';

  @override
  String get assistantNoResults => 'No results';

  @override
  String get assistantBoardedLabel => 'Boarded';

  @override
  String get assistantOf => 'of';

  @override
  String get assistantScanQrShort => 'Scan QR';

  @override
  String get assistantScanQrSubShort => 'Use camera';

  @override
  String get assistantTapNfc => 'Tap NFC';

  @override
  String get assistantTapNfcSub => 'Hold to phone';

  @override
  String get assistantStudentsByStop => 'Students · sorted by stop';

  @override
  String get assistantRouteOrder => 'Route order';

  @override
  String get assistantAbsenceReported => 'Parent reported absence';

  @override
  String get assistantBoardedAt => 'Boarded';

  @override
  String get assistantWaitingForPickup => 'Waiting for pickup';

  @override
  String get assistantAbsentBadge => 'Absent';

  @override
  String get assistantNotifyArrivedOk => 'Parent notified.';

  @override
  String get assistantNoParentPhone => 'No parent phone on file.';

  @override
  String get assistantOpenFailed => 'Could not open the app.';

  @override
  String assistantStartTripBody(int count) {
    return 'Start trip with $count students now?';
  }

  @override
  String get assistantStartTripYes => 'Start';

  @override
  String get assistantDeleteScheduledTitle => 'Delete trip';

  @override
  String get assistantDeleteScheduledBody =>
      'Delete this scheduled trip? This cannot be undone.';

  @override
  String get assistantDeleteScheduledYes => 'Delete';

  @override
  String get assistantSaveTripTitle => 'Save trip';

  @override
  String assistantSaveTripBody(int count) {
    return 'Save trip with $count students? You can start the trip later from the details screen.';
  }

  @override
  String get assistantSaveTripCta => 'Save trip';

  @override
  String get assistantEndTrip => 'End trip';

  @override
  String get assistantEndTripConfirmTitle => 'End this trip?';

  @override
  String get assistantEndTripConfirmBody =>
      'All boarding actions will be saved and the trip will be marked as completed.';

  @override
  String get assistantEndTripConfirmYes => 'End trip';

  @override
  String get assistantDeleteTrip => 'Delete trip';

  @override
  String get assistantDeleteTripConfirmTitle => 'Delete this trip?';

  @override
  String get assistantDeleteTripConfirmBody =>
      'No students are on this trip yet. Deleting cancels it without leaving a history entry.';

  @override
  String get assistantDeleteTripConfirmYes => 'Delete';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSchoolInfo => 'School info';

  @override
  String get settingsSchoolName => 'School name';

  @override
  String get settingsSchoolCity => 'Area';

  @override
  String get settingsSchoolPhone => 'Phone';

  @override
  String get settingsSchoolMissing => 'No school linked yet.';

  @override
  String get assistantScanStudentHint =>
      'Hold the student\'s QR inside the frame.';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsFullName => 'Full name';

  @override
  String get settingsFullNameHint => 'Your full name';

  @override
  String get settingsPhoneNumber => 'Phone number';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSave => 'Save changes';

  @override
  String get settingsSaved => 'Profile updated.';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get settingsLogoutTitle => 'Log out?';

  @override
  String get settingsLogoutBody =>
      'You\'ll need to sign in again with your phone number.';

  @override
  String get assistantEndedAt => 'Ended';

  @override
  String get assistantNotBoarded => 'Did not board';

  @override
  String get assistantNotBoardedShort => 'No-show';

  @override
  String get assistantTripCompletedTitle => 'Trip completed';

  @override
  String get assistantAbsenceSheetTitle => 'Absence details';

  @override
  String get assistantAbsenceCancelTitle => 'Cancel this absence?';

  @override
  String get assistantAbsenceCancelBody =>
      'The student will rejoin the trip and the parent will be notified that the absence was cancelled.';

  @override
  String get assistantAbsenceCancelYes => 'Cancel absence';

  @override
  String get assistantAbsenceCancelled => 'Absence cancelled.';

  @override
  String get assistantAbsenceReasonLabel => 'Reason';

  @override
  String get assistantAbsencePickupBy => 'Picked up by';

  @override
  String get assistantAbsenceNoteLabel => 'Parent\'s note';

  @override
  String get assistantAbsenceReasonIllness => 'Illness';

  @override
  String get assistantAbsenceReasonMedical => 'Medical appointment';

  @override
  String get assistantAbsenceReasonFamily => 'Family matter';

  @override
  String get assistantAbsenceReasonOther => 'Other';

  @override
  String get driverActiveTrips => 'Active trips';

  @override
  String get driverNoActiveTrip => 'No active trip';

  @override
  String get driverNoActiveTripBody =>
      'Once the assistant starts a trip, it\'ll show up here so you can open the route map.';

  @override
  String get driverOpenRouteMap => 'Open route map';

  @override
  String get driverRouteOrderTitle => 'Route order';

  @override
  String get driverSchoolPin => 'School';

  @override
  String get driverNoBoardedStopsTitle => 'No stops to route yet';

  @override
  String get driverNeedMoreStopsTitle => 'Not enough stops to route';

  @override
  String get driverNoBoardedStopsBody =>
      'The route appears once at least one student has been boarded with a known location.';

  @override
  String get driverRouteFallback =>
      'Couldn\'t fetch driving route — showing direct lines.';

  @override
  String driverStopsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stops',
      one: '1 stop',
    );
    return '$_temp0';
  }

  @override
  String get assistantDroppedAt => 'Dropped';

  @override
  String get assistantStatusDropped => 'Arrived';

  @override
  String get assistantArrivedSchool => 'Arrived at school';

  @override
  String get assistantArrivedHome => 'Arrived home';

  @override
  String get assistantOnBus => 'On bus';

  @override
  String get assistantMarkAbsentTitle => 'Mark as absent?';

  @override
  String assistantMarkAbsentBody(String name) {
    return 'Mark $name as absent for this trip. The student will be removed from the route and counts.';
  }

  @override
  String get assistantMarkAbsentConfirm => 'Mark absent';

  @override
  String get assistantContactParent => 'Contact parent';

  @override
  String get assistantNotifyArrivedMenu => 'Notify arrived';

  @override
  String get assistantCallMenu => 'Call';

  @override
  String get driverProgressLabel => 'Drop-offs';

  @override
  String get driverProgressLabelReturn => 'At home';

  @override
  String get driverPinArrived => 'Arrived';

  @override
  String get driverPinAtHome => 'At home';
}
