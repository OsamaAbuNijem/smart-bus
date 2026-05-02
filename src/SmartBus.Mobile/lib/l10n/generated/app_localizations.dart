import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SmartBus'**
  String get appTitle;

  /// No description provided for @loginAppName.
  ///
  /// In en, this message translates to:
  /// **'School Bus Tracker'**
  String get loginAppName;

  /// No description provided for @loginAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your child safe on every ride'**
  String get loginAppSubtitle;

  /// No description provided for @loginBadgeSecure.
  ///
  /// In en, this message translates to:
  /// **'Secure'**
  String get loginBadgeSecure;

  /// No description provided for @loginBadgeLiveGps.
  ///
  /// In en, this message translates to:
  /// **'Live GPS'**
  String get loginBadgeLiveGps;

  /// No description provided for @loginBadgeTrusted.
  ///
  /// In en, this message translates to:
  /// **'Trusted'**
  String get loginBadgeTrusted;

  /// No description provided for @loginEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginEyebrow;

  /// No description provided for @loginCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginCardTitle;

  /// No description provided for @loginCardDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose how you\'d like to access your account'**
  String get loginCardDesc;

  /// No description provided for @loginTabPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get loginTabPhone;

  /// No description provided for @loginTabScan.
  ///
  /// In en, this message translates to:
  /// **'Scan Card'**
  String get loginTabScan;

  /// No description provided for @loginPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get loginPhoneLabel;

  /// No description provided for @loginPhonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'7X XXX XXXX'**
  String get loginPhonePlaceholder;

  /// No description provided for @loginPhoneHelp.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a 4-digit verification code'**
  String get loginPhoneHelp;

  /// No description provided for @loginSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get loginSendOtp;

  /// No description provided for @loginTerms.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our Terms and Privacy Policy'**
  String get loginTerms;

  /// No description provided for @loginScanComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Scan card sign-in is coming soon'**
  String get loginScanComingSoon;

  /// No description provided for @loginInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get loginInvalidPhone;

  /// No description provided for @loginPhoneNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'This phone number isn\'t registered. Please contact your school administration.'**
  String get loginPhoneNotRegistered;

  /// No description provided for @loginNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection and try again.'**
  String get loginNetworkError;

  /// No description provided for @loginUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get loginUnknownError;

  /// No description provided for @otpHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get otpHeroTitle;

  /// No description provided for @otpHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A code was sent to your device'**
  String get otpHeroSubtitle;

  /// No description provided for @otpEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get otpEyebrow;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit code'**
  String get otpTitle;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Sent to'**
  String get otpSentTo;

  /// No description provided for @otpConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm & sign in'**
  String get otpConfirm;

  /// No description provided for @otpResendPrefix.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive it?'**
  String get otpResendPrefix;

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get otpResend;

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code'**
  String get otpInvalid;

  /// No description provided for @otpFooter.
  ///
  /// In en, this message translates to:
  /// **'Never share this code — School Bus Tracker will never ask for it'**
  String get otpFooter;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navTrips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get navTrips;

  /// No description provided for @navStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get navStudents;

  /// No description provided for @navDrivers.
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get navDrivers;

  /// No description provided for @navBuses.
  ///
  /// In en, this message translates to:
  /// **'Buses'**
  String get navBuses;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get navLogout;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validationEmail;

  /// No description provided for @validationPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get validationPhone;

  /// No description provided for @validationNationalNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid national number'**
  String get validationNationalNumber;

  /// No description provided for @validationMinLength.
  ///
  /// In en, this message translates to:
  /// **'Must be at least {n} characters'**
  String validationMinLength(int n);

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String homeWelcome(String name);

  /// No description provided for @homeParentTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent Dashboard'**
  String get homeParentTitle;

  /// No description provided for @homeDriverTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Dashboard'**
  String get homeDriverTitle;

  /// No description provided for @homeAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistant Dashboard'**
  String get homeAssistantTitle;

  /// No description provided for @homeParentTrack.
  ///
  /// In en, this message translates to:
  /// **'Track Bus'**
  String get homeParentTrack;

  /// No description provided for @homeParentTrips.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Trip'**
  String get homeParentTrips;

  /// No description provided for @homeParentAbsence.
  ///
  /// In en, this message translates to:
  /// **'Report Absence'**
  String get homeParentAbsence;

  /// No description provided for @homeDriverStartTrip.
  ///
  /// In en, this message translates to:
  /// **'Start a Trip'**
  String get homeDriverStartTrip;

  /// No description provided for @homeDriverActiveTrip.
  ///
  /// In en, this message translates to:
  /// **'Active Trip'**
  String get homeDriverActiveTrip;

  /// No description provided for @homeDriverHistory.
  ///
  /// In en, this message translates to:
  /// **'Trip History'**
  String get homeDriverHistory;

  /// No description provided for @homeDriverAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get homeDriverAttendance;

  /// No description provided for @homeAssistantBoarding.
  ///
  /// In en, this message translates to:
  /// **'Mark Boarding'**
  String get homeAssistantBoarding;

  /// No description provided for @homeAssistantScan.
  ///
  /// In en, this message translates to:
  /// **'Scan Card'**
  String get homeAssistantScan;

  /// No description provided for @homeAssistantRoster.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Roster'**
  String get homeAssistantRoster;

  /// No description provided for @parentGreetingEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get parentGreetingEyebrow;

  /// No description provided for @parentNoChildren.
  ///
  /// In en, this message translates to:
  /// **'No children linked to your account yet.'**
  String get parentNoChildren;

  /// No description provided for @parentNoTrips.
  ///
  /// In en, this message translates to:
  /// **'No trips yet.'**
  String get parentNoTrips;

  /// No description provided for @parentTripEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Last Trip'**
  String get parentTripEyebrow;

  /// No description provided for @parentTripPickup.
  ///
  /// In en, this message translates to:
  /// **'Pick-up'**
  String get parentTripPickup;

  /// No description provided for @parentTripDropoff.
  ///
  /// In en, this message translates to:
  /// **'Drop-off'**
  String get parentTripDropoff;

  /// No description provided for @parentMetaBus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get parentMetaBus;

  /// No description provided for @parentMetaDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get parentMetaDriver;

  /// No description provided for @parentMetaDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get parentMetaDuration;

  /// No description provided for @parentDayToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get parentDayToday;

  /// No description provided for @parentDayYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get parentDayYesterday;

  /// No description provided for @parentStatusArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived safely'**
  String get parentStatusArrived;

  /// No description provided for @parentStatusOnBus.
  ///
  /// In en, this message translates to:
  /// **'On the bus'**
  String get parentStatusOnBus;

  /// No description provided for @parentStatusAwaiting.
  ///
  /// In en, this message translates to:
  /// **'Awaiting today'**
  String get parentStatusAwaiting;

  /// No description provided for @parentSectionQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get parentSectionQuickActions;

  /// No description provided for @parentSectionRecentTrips.
  ///
  /// In en, this message translates to:
  /// **'Recent trips'**
  String get parentSectionRecentTrips;

  /// No description provided for @parentViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get parentViewAll;

  /// No description provided for @parentActionStudentInfo.
  ///
  /// In en, this message translates to:
  /// **'Student Info'**
  String get parentActionStudentInfo;

  /// No description provided for @parentActionStudentInfoSub.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get parentActionStudentInfoSub;

  /// No description provided for @parentActionTripHistory.
  ///
  /// In en, this message translates to:
  /// **'Trip History'**
  String get parentActionTripHistory;

  /// No description provided for @parentActionTripHistorySub.
  ///
  /// In en, this message translates to:
  /// **'Past trips'**
  String get parentActionTripHistorySub;

  /// No description provided for @parentActionAbsence.
  ///
  /// In en, this message translates to:
  /// **'Report Absence'**
  String get parentActionAbsence;

  /// No description provided for @parentActionAbsenceSub.
  ///
  /// In en, this message translates to:
  /// **'Notify driver'**
  String get parentActionAbsenceSub;

  /// No description provided for @parentTagOnTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get parentTagOnTime;

  /// No description provided for @parentTagAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get parentTagAbsent;

  /// No description provided for @parentTagPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get parentTagPending;

  /// No description provided for @studentInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Student Info'**
  String get studentInfoTitle;

  /// No description provided for @studentInfoIdLabel.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get studentInfoIdLabel;

  /// No description provided for @studentInfoClassPrefix.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get studentInfoClassPrefix;

  /// No description provided for @studentInfoGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Information'**
  String get studentInfoGeneral;

  /// No description provided for @studentInfoDob.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get studentInfoDob;

  /// No description provided for @studentInfoSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get studentInfoSchool;

  /// No description provided for @studentInfoHomeAddress.
  ///
  /// In en, this message translates to:
  /// **'Home Address'**
  String get studentInfoHomeAddress;

  /// No description provided for @studentInfoRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get studentInfoRoute;

  /// No description provided for @studentInfoNotes.
  ///
  /// In en, this message translates to:
  /// **'Parent Notes'**
  String get studentInfoNotes;

  /// No description provided for @studentInfoEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get studentInfoEmergency;

  /// No description provided for @studentInfoParentContact.
  ///
  /// In en, this message translates to:
  /// **'Parent Contact'**
  String get studentInfoParentContact;

  /// No description provided for @studentInfoNoContacts.
  ///
  /// In en, this message translates to:
  /// **'No contact on file.'**
  String get studentInfoNoContacts;

  /// No description provided for @studentEditEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Editing'**
  String get studentEditEyebrow;

  /// No description provided for @studentEditBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get studentEditBasicInfo;

  /// No description provided for @studentEditFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get studentEditFullName;

  /// No description provided for @studentEditFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Student full name'**
  String get studentEditFullNameHint;

  /// No description provided for @studentEditStudentId.
  ///
  /// In en, this message translates to:
  /// **'Student ID'**
  String get studentEditStudentId;

  /// No description provided for @studentEditAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get studentEditAuto;

  /// No description provided for @studentEditGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get studentEditGrade;

  /// No description provided for @studentEditClass.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get studentEditClass;

  /// No description provided for @studentEditClassHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. A'**
  String get studentEditClassHint;

  /// No description provided for @studentEditNotes.
  ///
  /// In en, this message translates to:
  /// **'Parent Notes'**
  String get studentEditNotes;

  /// No description provided for @studentEditDriverNote.
  ///
  /// In en, this message translates to:
  /// **'Note for the driver'**
  String get studentEditDriverNote;

  /// No description provided for @studentEditNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Anything the driver should know?'**
  String get studentEditNotesHint;

  /// No description provided for @studentEditParentInfo.
  ///
  /// In en, this message translates to:
  /// **'Parent Info'**
  String get studentEditParentInfo;

  /// No description provided for @studentEditVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get studentEditVerified;

  /// No description provided for @studentEditParentNameHint.
  ///
  /// In en, this message translates to:
  /// **'Parent full name'**
  String get studentEditParentNameHint;

  /// No description provided for @studentEditMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get studentEditMobile;

  /// No description provided for @studentEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get studentEditSave;

  /// No description provided for @studentEditSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get studentEditSaved;

  /// No description provided for @studentEditFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Please try again.'**
  String get studentEditFailed;

  /// No description provided for @studentEditMissingFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the required fields.'**
  String get studentEditMissingFields;

  /// No description provided for @tripHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip History'**
  String get tripHistoryTitle;

  /// No description provided for @tripHistoryLast7.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get tripHistoryLast7;

  /// No description provided for @tripHistoryThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get tripHistoryThisWeek;

  /// No description provided for @tripHistoryToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tripHistoryToday;

  /// No description provided for @tripHistoryYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get tripHistoryYesterday;

  /// No description provided for @tripHistoryMorningPickup.
  ///
  /// In en, this message translates to:
  /// **'Morning Pickup'**
  String get tripHistoryMorningPickup;

  /// No description provided for @tripHistoryAfternoonDropoff.
  ///
  /// In en, this message translates to:
  /// **'Afternoon Drop-off'**
  String get tripHistoryAfternoonDropoff;

  /// No description provided for @tripHistoryOnTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get tripHistoryOnTime;

  /// No description provided for @tripHistoryLateMinutes.
  ///
  /// In en, this message translates to:
  /// **'+{n} min late'**
  String tripHistoryLateMinutes(int n);

  /// No description provided for @tripHistoryAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get tripHistoryAbsent;

  /// No description provided for @tripHistoryPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get tripHistoryPending;

  /// No description provided for @tripHistoryDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get tripHistoryDriver;

  /// No description provided for @tripHistoryAssistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get tripHistoryAssistant;

  /// No description provided for @tripHistoryReportedAbsent.
  ///
  /// In en, this message translates to:
  /// **'Reported absent'**
  String get tripHistoryReportedAbsent;

  /// No description provided for @tripHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No trips yet for this child.'**
  String get tripHistoryEmpty;

  /// No description provided for @absenceEyebrow.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get absenceEyebrow;

  /// No description provided for @absenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Absence'**
  String get absenceTitle;

  /// No description provided for @absenceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The driver and school will be notified instantly'**
  String get absenceSubtitle;

  /// No description provided for @absenceSectionStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get absenceSectionStudent;

  /// No description provided for @absenceSectionDate.
  ///
  /// In en, this message translates to:
  /// **'Absence Date'**
  String get absenceSectionDate;

  /// No description provided for @absenceSectionService.
  ///
  /// In en, this message translates to:
  /// **'Bus Service'**
  String get absenceSectionService;

  /// No description provided for @absenceSectionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get absenceSectionReason;

  /// No description provided for @absenceSectionNote.
  ///
  /// In en, this message translates to:
  /// **'Note for the driver'**
  String get absenceSectionNote;

  /// No description provided for @absenceOptional.
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get absenceOptional;

  /// No description provided for @absenceOptionFullTitle.
  ///
  /// In en, this message translates to:
  /// **'Full day off'**
  String get absenceOptionFullTitle;

  /// No description provided for @absenceOptionFullDesc.
  ///
  /// In en, this message translates to:
  /// **'Student will not attend school today'**
  String get absenceOptionFullDesc;

  /// No description provided for @absenceFullNote.
  ///
  /// In en, this message translates to:
  /// **'No bus service today. Driver and school will be notified.'**
  String get absenceFullNote;

  /// No description provided for @absenceOptionMorningTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip morning bus'**
  String get absenceOptionMorningTitle;

  /// No description provided for @absenceOptionMorningDesc.
  ///
  /// In en, this message translates to:
  /// **'Parent will drop the student at school'**
  String get absenceOptionMorningDesc;

  /// No description provided for @absenceOptionReturnTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip return bus'**
  String get absenceOptionReturnTitle;

  /// No description provided for @absenceOptionReturnDesc.
  ///
  /// In en, this message translates to:
  /// **'Parent will pick up the student from school'**
  String get absenceOptionReturnDesc;

  /// No description provided for @absenceReasonIllness.
  ///
  /// In en, this message translates to:
  /// **'Illness'**
  String get absenceReasonIllness;

  /// No description provided for @absenceReasonAppointment.
  ///
  /// In en, this message translates to:
  /// **'Medical Appt'**
  String get absenceReasonAppointment;

  /// No description provided for @absenceReasonFamily.
  ///
  /// In en, this message translates to:
  /// **'Family Matter'**
  String get absenceReasonFamily;

  /// No description provided for @absenceReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get absenceReasonOther;

  /// No description provided for @absenceNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Anything else the driver should know?'**
  String get absenceNoteHint;

  /// No description provided for @absenceInfoBox.
  ///
  /// In en, this message translates to:
  /// **'You can cancel this request up to 30 minutes before the bus departs'**
  String get absenceInfoBox;

  /// No description provided for @absenceSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit absence request'**
  String get absenceSubmit;

  /// No description provided for @absenceSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Absence reported'**
  String get absenceSubmitted;

  /// No description provided for @absenceFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t submit. Please try again.'**
  String get absenceFailed;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Track buses in real time'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDescription1.
  ///
  /// In en, this message translates to:
  /// **'See exactly where your child\'s bus is, every step of the way.'**
  String get onboardingDescription1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Arrival alerts'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDescription2.
  ///
  /// In en, this message translates to:
  /// **'Get notified for pickup, drop-off, and unexpected delays.'**
  String get onboardingDescription2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Stay connected'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDescription3.
  ///
  /// In en, this message translates to:
  /// **'Direct line to drivers and school staff when it matters.'**
  String get onboardingDescription3;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
