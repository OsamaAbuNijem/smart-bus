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
  /// **'TilmezBus'**
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

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'Track every ride. Every child. Every time.'**
  String get loginTagline;

  /// No description provided for @loginCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginCardTitle;

  /// No description provided for @loginCardDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone, we\'ll send a 4-digit code.'**
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

  /// No description provided for @loginSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get loginSendOtp;

  /// No description provided for @loginTerms.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our Terms and Privacy'**
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
  /// **'Verify your number'**
  String get otpTitle;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Sent to'**
  String get otpSentTo;

  /// No description provided for @otpConfirm.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
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

  /// No description provided for @otpResendWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait {time} before resending'**
  String otpResendWait(String time);

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code'**
  String get otpInvalid;

  /// No description provided for @otpFooter.
  ///
  /// In en, this message translates to:
  /// **'Never share this code — TilmezBus will never ask for it'**
  String get otpFooter;

  /// No description provided for @otpBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get otpBack;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get scanTitle;

  /// No description provided for @scanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan your student card'**
  String get scanSubtitle;

  /// No description provided for @scanTip.
  ///
  /// In en, this message translates to:
  /// **'Hold the card inside the frame'**
  String get scanTip;

  /// No description provided for @scanCantTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t scan?'**
  String get scanCantTitle;

  /// No description provided for @scanCantSub.
  ///
  /// In en, this message translates to:
  /// **'Enter the 8-digit code printed on your card'**
  String get scanCantSub;

  /// No description provided for @scanCodeHint.
  ///
  /// In en, this message translates to:
  /// **'XXXX-XXXX'**
  String get scanCodeHint;

  /// No description provided for @scanContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get scanContinue;

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

  /// No description provided for @parentStatusWaitingPickup.
  ///
  /// In en, this message translates to:
  /// **'Bus on the way'**
  String get parentStatusWaitingPickup;

  /// No description provided for @assistantStartAllAbsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to do'**
  String get assistantStartAllAbsentTitle;

  /// No description provided for @assistantStartAllAbsentBody.
  ///
  /// In en, this message translates to:
  /// **'Every student on this trip is marked absent — there\'s nothing to drive.'**
  String get assistantStartAllAbsentBody;

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

  /// No description provided for @studentInfoSchoolAddress.
  ///
  /// In en, this message translates to:
  /// **'School Address'**
  String get studentInfoSchoolAddress;

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
  /// **'Notes'**
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

  /// No description provided for @absenceSectionRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested absences'**
  String get absenceSectionRequested;

  /// No description provided for @absenceSummaryTotal.
  ///
  /// In en, this message translates to:
  /// **'Total absences'**
  String get absenceSummaryTotal;

  /// No description provided for @absenceSummaryMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning absences'**
  String get absenceSummaryMorning;

  /// No description provided for @absenceSummaryReturn.
  ///
  /// In en, this message translates to:
  /// **'Return absences'**
  String get absenceSummaryReturn;

  /// No description provided for @absenceCancelWindowNote.
  ///
  /// In en, this message translates to:
  /// **'You can cancel this absence anytime before the trip starts. Once the trip is in progress, it can\'t be cancelled.'**
  String get absenceCancelWindowNote;

  /// No description provided for @absenceNoRequests.
  ///
  /// In en, this message translates to:
  /// **'No absence requests for this week yet.'**
  String get absenceNoRequests;

  /// No description provided for @absenceCreateRequest.
  ///
  /// In en, this message translates to:
  /// **'Create absence request'**
  String get absenceCreateRequest;

  /// No description provided for @absenceCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New absence request'**
  String get absenceCreateTitle;

  /// No description provided for @absenceCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Submit a one-off absence for this student'**
  String get absenceCreateSubtitle;

  /// No description provided for @absenceStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get absenceStatusPending;

  /// No description provided for @absenceStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get absenceStatusApproved;

  /// No description provided for @absenceStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get absenceStatusRejected;

  /// No description provided for @absenceCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel absence?'**
  String get absenceCancelTitle;

  /// No description provided for @absenceCancelBody.
  ///
  /// In en, this message translates to:
  /// **'The driver and school will be notified that the absence was cancelled.'**
  String get absenceCancelBody;

  /// No description provided for @absenceCancelYes.
  ///
  /// In en, this message translates to:
  /// **'Cancel absence'**
  String get absenceCancelYes;

  /// No description provided for @absenceCancelled.
  ///
  /// In en, this message translates to:
  /// **'Absence cancelled.'**
  String get absenceCancelled;

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

  /// No description provided for @parentTrackLive.
  ///
  /// In en, this message translates to:
  /// **'Track Live'**
  String get parentTrackLive;

  /// No description provided for @liveTrackingLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get liveTrackingLive;

  /// No description provided for @liveTrackingMin.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get liveTrackingMin;

  /// No description provided for @liveTrackingOnTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get liveTrackingOnTime;

  /// No description provided for @liveTrackingOnTheWaySchool.
  ///
  /// In en, this message translates to:
  /// **'On the way to school'**
  String get liveTrackingOnTheWaySchool;

  /// No description provided for @liveTrackingOnTheWayHome.
  ///
  /// In en, this message translates to:
  /// **'On the way home'**
  String get liveTrackingOnTheWayHome;

  /// No description provided for @liveTrackingHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get liveTrackingHome;

  /// No description provided for @liveTrackingBoarded.
  ///
  /// In en, this message translates to:
  /// **'Boarded'**
  String get liveTrackingBoarded;

  /// No description provided for @liveTrackingDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get liveTrackingDistance;

  /// No description provided for @liveTrackingSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get liveTrackingSpeed;

  /// No description provided for @liveTrackingArrives.
  ///
  /// In en, this message translates to:
  /// **'Arrives'**
  String get liveTrackingArrives;

  /// No description provided for @liveTrackingDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get liveTrackingDriver;

  /// No description provided for @liveTrackingCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get liveTrackingCall;

  /// No description provided for @liveTrackingAssistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get liveTrackingAssistant;

  /// No description provided for @liveTrackingNoCrew.
  ///
  /// In en, this message translates to:
  /// **'Crew not assigned yet'**
  String get liveTrackingNoCrew;

  /// No description provided for @liveTrackingLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {when}'**
  String liveTrackingLastUpdated(String when);

  /// No description provided for @liveTrackingJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get liveTrackingJustNow;

  /// No description provided for @liveTrackingNever.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get liveTrackingNever;

  /// No description provided for @liveTrackingTripEndedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip ended'**
  String get liveTrackingTripEndedTitle;

  /// No description provided for @liveTrackingTripEndedBody.
  ///
  /// In en, this message translates to:
  /// **'The assistant has ended this trip.'**
  String get liveTrackingTripEndedBody;

  /// No description provided for @liveTrackingTripEndedClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get liveTrackingTripEndedClose;

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

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingHasAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get onboardingHasAccount;

  /// No description provided for @onboardingLangSwitch.
  ///
  /// In en, this message translates to:
  /// **'عربي'**
  String get onboardingLangSwitch;

  /// No description provided for @onboardingStep.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String onboardingStep(int step, int total);

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Track every ride <b>in real time</b>'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDescription1.
  ///
  /// In en, this message translates to:
  /// **'See exactly where your child\'s bus is — from the first pickup to the school gate, on a live map.'**
  String get onboardingDescription1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Get notified <b>the moment</b> it matters'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDescription2.
  ///
  /// In en, this message translates to:
  /// **'Pickup, drop-off, delays, arrivals — instant alerts so you\'re never left wondering.'**
  String get onboardingDescription2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Verified drivers, <b>safer rides</b>'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDescription3.
  ///
  /// In en, this message translates to:
  /// **'Every driver is screened, every trip is logged. Peace of mind from morning bell to home.'**
  String get onboardingDescription3;

  /// No description provided for @onboardingFooter1.
  ///
  /// In en, this message translates to:
  /// **'Trusted by thousands of families across Jordan'**
  String get onboardingFooter1;

  /// No description provided for @onboardingFooter2.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications anytime in Settings'**
  String get onboardingFooter2;

  /// No description provided for @onboardingFooterTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get onboardingFooterTermsPrefix;

  /// No description provided for @onboardingFooterTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get onboardingFooterTerms;

  /// No description provided for @onboardingFooterAnd.
  ///
  /// In en, this message translates to:
  /// **' & '**
  String get onboardingFooterAnd;

  /// No description provided for @onboardingFooterPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get onboardingFooterPrivacy;

  /// No description provided for @onboardingMiniCardPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Picked up'**
  String get onboardingMiniCardPickedUp;

  /// No description provided for @onboardingMiniCardPickedUpSub.
  ///
  /// In en, this message translates to:
  /// **'7:42 AM'**
  String get onboardingMiniCardPickedUpSub;

  /// No description provided for @onboardingMiniCardEta.
  ///
  /// In en, this message translates to:
  /// **'5 min away'**
  String get onboardingMiniCardEta;

  /// No description provided for @onboardingMiniCardEtaSub.
  ///
  /// In en, this message translates to:
  /// **'From school'**
  String get onboardingMiniCardEtaSub;

  /// No description provided for @onboardingMiniCardOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get onboardingMiniCardOnTheWay;

  /// No description provided for @onboardingMiniCardOnTheWaySub.
  ///
  /// In en, this message translates to:
  /// **'Driver: Ahmad'**
  String get onboardingMiniCardOnTheWaySub;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get notificationsEyebrow;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsCountSummary.
  ///
  /// In en, this message translates to:
  /// **'{newCount} new · {total} total'**
  String notificationsCountSummary(int newCount, int total);

  /// No description provided for @notificationsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notificationsToday;

  /// No description provided for @notificationsYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notificationsYesterday;

  /// No description provided for @notificationsDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String notificationsDaysAgo(int days);

  /// No description provided for @notificationsCountNew.
  ///
  /// In en, this message translates to:
  /// **'{count} new'**
  String notificationsCountNew(int count);

  /// No description provided for @notificationsCountItems.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String notificationsCountItems(int count);

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptySub.
  ///
  /// In en, this message translates to:
  /// **'Updates about your child\'s trip will appear here.'**
  String get notificationsEmptySub;

  /// No description provided for @assistantGreetMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get assistantGreetMorning;

  /// No description provided for @assistantGreetAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get assistantGreetAfternoon;

  /// No description provided for @assistantGreetEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get assistantGreetEvening;

  /// No description provided for @assistantTodaysTrips.
  ///
  /// In en, this message translates to:
  /// **'Today\'s trips'**
  String get assistantTodaysTrips;

  /// No description provided for @assistantScanBusQr.
  ///
  /// In en, this message translates to:
  /// **'Scan Bus QR'**
  String get assistantScanBusQr;

  /// No description provided for @assistantScanBusQrSub.
  ///
  /// In en, this message translates to:
  /// **'Scan to start a new trip'**
  String get assistantScanBusQrSub;

  /// No description provided for @assistantManualSetupCta.
  ///
  /// In en, this message translates to:
  /// **'Or set up manually'**
  String get assistantManualSetupCta;

  /// No description provided for @assistantMorningPickup.
  ///
  /// In en, this message translates to:
  /// **'Morning Pickup'**
  String get assistantMorningPickup;

  /// No description provided for @assistantAfternoonDropoff.
  ///
  /// In en, this message translates to:
  /// **'Afternoon Drop-off'**
  String get assistantAfternoonDropoff;

  /// No description provided for @assistantStartedAt.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get assistantStartedAt;

  /// No description provided for @assistantCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get assistantCreatedAt;

  /// No description provided for @assistantBoarded.
  ///
  /// In en, this message translates to:
  /// **'boarded'**
  String get assistantBoarded;

  /// No description provided for @assistantStudents.
  ///
  /// In en, this message translates to:
  /// **'students'**
  String get assistantStudents;

  /// No description provided for @assistantStatusLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get assistantStatusLive;

  /// No description provided for @assistantStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get assistantStatusDone;

  /// No description provided for @assistantStatusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get assistantStatusScheduled;

  /// No description provided for @assistantNoTripsToday.
  ///
  /// In en, this message translates to:
  /// **'No trips assigned for today.\nScan a bus QR to get started.'**
  String get assistantNoTripsToday;

  /// No description provided for @assistantTripSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'New Trip'**
  String get assistantTripSetupTitle;

  /// No description provided for @assistantBusFromQr.
  ///
  /// In en, this message translates to:
  /// **'From QR'**
  String get assistantBusFromQr;

  /// No description provided for @assistantTripTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Trip type'**
  String get assistantTripTypeLabel;

  /// No description provided for @assistantTripTypeMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get assistantTripTypeMorning;

  /// No description provided for @assistantTripTypeMorningSub.
  ///
  /// In en, this message translates to:
  /// **'Home → School'**
  String get assistantTripTypeMorningSub;

  /// No description provided for @assistantTripTypeAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get assistantTripTypeAfternoon;

  /// No description provided for @assistantTripTypeAfternoonSub.
  ///
  /// In en, this message translates to:
  /// **'School → Home'**
  String get assistantTripTypeAfternoonSub;

  /// No description provided for @assistantStudentsAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto-loaded from last trip'**
  String get assistantStudentsAuto;

  /// No description provided for @assistantSkipRoster.
  ///
  /// In en, this message translates to:
  /// **'Skip auto-roster'**
  String get assistantSkipRoster;

  /// No description provided for @assistantSkipRosterHint.
  ///
  /// In en, this message translates to:
  /// **'Start empty — students join when their QR/NFC is scanned.'**
  String get assistantSkipRosterHint;

  /// No description provided for @assistantRosterSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-loaded students'**
  String get assistantRosterSheetTitle;

  /// No description provided for @assistantStartTrip.
  ///
  /// In en, this message translates to:
  /// **'Start trip'**
  String get assistantStartTrip;

  /// No description provided for @assistantBusLabel.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get assistantBusLabel;

  /// No description provided for @assistantDriverLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get assistantDriverLabel;

  /// No description provided for @assistantQrEntryHint.
  ///
  /// In en, this message translates to:
  /// **'Paste or type QR token'**
  String get assistantQrEntryHint;

  /// No description provided for @assistantQrEntryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Use this token'**
  String get assistantQrEntryConfirm;

  /// No description provided for @assistantQrSimulatorTitle.
  ///
  /// In en, this message translates to:
  /// **'QR scanner unavailable in simulator'**
  String get assistantQrSimulatorTitle;

  /// No description provided for @assistantQrSimulatorBody.
  ///
  /// In en, this message translates to:
  /// **'Type or paste the bus QR token below to continue.'**
  String get assistantQrSimulatorBody;

  /// No description provided for @loginRoleParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get loginRoleParent;

  /// No description provided for @loginRoleDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get loginRoleDriver;

  /// No description provided for @loginRoleAssistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get loginRoleAssistant;

  /// No description provided for @assistantSelectBus.
  ///
  /// In en, this message translates to:
  /// **'Select a bus'**
  String get assistantSelectBus;

  /// No description provided for @assistantSelectDriver.
  ///
  /// In en, this message translates to:
  /// **'Select a driver'**
  String get assistantSelectDriver;

  /// No description provided for @assistantNoLastRoster.
  ///
  /// In en, this message translates to:
  /// **'No prior trip on this bus + type. Trip will start with an empty roster.'**
  String get assistantNoLastRoster;

  /// No description provided for @assistantScanStudentTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan student QR'**
  String get assistantScanStudentTitle;

  /// No description provided for @assistantScanStudentOk.
  ///
  /// In en, this message translates to:
  /// **'Student boarded.'**
  String get assistantScanStudentOk;

  /// No description provided for @assistantNfcUnavailable.
  ///
  /// In en, this message translates to:
  /// **'NFC isn\'t available on this device.'**
  String get assistantNfcUnavailable;

  /// No description provided for @assistantScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get assistantScanQr;

  /// No description provided for @assistantScanNfc.
  ///
  /// In en, this message translates to:
  /// **'Scan NFC'**
  String get assistantScanNfc;

  /// No description provided for @assistantSearchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get assistantSearchByName;

  /// No description provided for @assistantRosterHeader.
  ///
  /// In en, this message translates to:
  /// **'Students on this trip'**
  String get assistantRosterHeader;

  /// No description provided for @assistantRosterEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add at least one student before starting'**
  String get assistantRosterEmpty;

  /// No description provided for @assistantNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get assistantNoResults;

  /// No description provided for @assistantBoardedLabel.
  ///
  /// In en, this message translates to:
  /// **'Boarded'**
  String get assistantBoardedLabel;

  /// No description provided for @assistantOf.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get assistantOf;

  /// No description provided for @assistantScanQrShort.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get assistantScanQrShort;

  /// No description provided for @assistantScanQrSubShort.
  ///
  /// In en, this message translates to:
  /// **'Use camera'**
  String get assistantScanQrSubShort;

  /// No description provided for @assistantTapNfc.
  ///
  /// In en, this message translates to:
  /// **'Tap NFC'**
  String get assistantTapNfc;

  /// No description provided for @assistantTapNfcSub.
  ///
  /// In en, this message translates to:
  /// **'Hold to phone'**
  String get assistantTapNfcSub;

  /// No description provided for @assistantStudentsByStop.
  ///
  /// In en, this message translates to:
  /// **'Students · sorted by stop'**
  String get assistantStudentsByStop;

  /// No description provided for @assistantRouteOrder.
  ///
  /// In en, this message translates to:
  /// **'Route order'**
  String get assistantRouteOrder;

  /// No description provided for @assistantAbsenceReported.
  ///
  /// In en, this message translates to:
  /// **'Parent reported absence'**
  String get assistantAbsenceReported;

  /// No description provided for @assistantBoardedAt.
  ///
  /// In en, this message translates to:
  /// **'Boarded'**
  String get assistantBoardedAt;

  /// No description provided for @assistantWaitingForPickup.
  ///
  /// In en, this message translates to:
  /// **'Waiting for pickup'**
  String get assistantWaitingForPickup;

  /// No description provided for @assistantAbsentBadge.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get assistantAbsentBadge;

  /// No description provided for @assistantNotifyArrivedOk.
  ///
  /// In en, this message translates to:
  /// **'Parent notified.'**
  String get assistantNotifyArrivedOk;

  /// No description provided for @assistantNoParentPhone.
  ///
  /// In en, this message translates to:
  /// **'No parent phone on file.'**
  String get assistantNoParentPhone;

  /// No description provided for @assistantOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the app.'**
  String get assistantOpenFailed;

  /// No description provided for @assistantStartTripBody.
  ///
  /// In en, this message translates to:
  /// **'Start trip with {count} students now?'**
  String assistantStartTripBody(int count);

  /// No description provided for @assistantStartTripYes.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get assistantStartTripYes;

  /// No description provided for @assistantDeleteScheduledTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete trip'**
  String get assistantDeleteScheduledTitle;

  /// No description provided for @assistantDeleteScheduledBody.
  ///
  /// In en, this message translates to:
  /// **'Delete this scheduled trip? This cannot be undone.'**
  String get assistantDeleteScheduledBody;

  /// No description provided for @assistantDeleteScheduledYes.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get assistantDeleteScheduledYes;

  /// No description provided for @assistantSaveTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Save trip'**
  String get assistantSaveTripTitle;

  /// No description provided for @assistantSaveTripBody.
  ///
  /// In en, this message translates to:
  /// **'Save trip with {count} students? You can start the trip later from the details screen.'**
  String assistantSaveTripBody(int count);

  /// No description provided for @assistantSaveTripCta.
  ///
  /// In en, this message translates to:
  /// **'Save trip'**
  String get assistantSaveTripCta;

  /// No description provided for @assistantEndTrip.
  ///
  /// In en, this message translates to:
  /// **'End trip'**
  String get assistantEndTrip;

  /// No description provided for @assistantEndTripConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'End this trip?'**
  String get assistantEndTripConfirmTitle;

  /// No description provided for @assistantEndTripConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'All boarding actions will be saved and the trip will be marked as completed.'**
  String get assistantEndTripConfirmBody;

  /// No description provided for @assistantEndTripConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'End trip'**
  String get assistantEndTripConfirmYes;

  /// No description provided for @assistantDeleteTrip.
  ///
  /// In en, this message translates to:
  /// **'Delete trip'**
  String get assistantDeleteTrip;

  /// No description provided for @assistantDeleteTripConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this trip?'**
  String get assistantDeleteTripConfirmTitle;

  /// No description provided for @assistantDeleteTripConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'No students are on this trip yet. Deleting cancels it without leaving a history entry.'**
  String get assistantDeleteTripConfirmBody;

  /// No description provided for @assistantDeleteTripConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get assistantDeleteTripConfirmYes;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSchoolInfo.
  ///
  /// In en, this message translates to:
  /// **'School info'**
  String get settingsSchoolInfo;

  /// No description provided for @settingsSchoolName.
  ///
  /// In en, this message translates to:
  /// **'School name'**
  String get settingsSchoolName;

  /// No description provided for @settingsSchoolCity.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get settingsSchoolCity;

  /// No description provided for @settingsSchoolPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get settingsSchoolPhone;

  /// No description provided for @settingsSchoolMissing.
  ///
  /// In en, this message translates to:
  /// **'No school linked yet.'**
  String get settingsSchoolMissing;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @settingsFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get settingsFullName;

  /// No description provided for @settingsFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get settingsFullNameHint;

  /// No description provided for @settingsPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get settingsPhoneNumber;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get settingsSave;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get settingsSaved;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get settingsLogoutTitle;

  /// No description provided for @settingsLogoutBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again with your phone number.'**
  String get settingsLogoutBody;

  /// No description provided for @assistantEndedAt.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get assistantEndedAt;

  /// No description provided for @assistantNotBoarded.
  ///
  /// In en, this message translates to:
  /// **'Did not board'**
  String get assistantNotBoarded;

  /// No description provided for @assistantNotBoardedShort.
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get assistantNotBoardedShort;

  /// No description provided for @assistantTripCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip completed'**
  String get assistantTripCompletedTitle;

  /// No description provided for @assistantAbsenceSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Absence details'**
  String get assistantAbsenceSheetTitle;

  /// No description provided for @assistantAbsenceCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this absence?'**
  String get assistantAbsenceCancelTitle;

  /// No description provided for @assistantAbsenceCancelBody.
  ///
  /// In en, this message translates to:
  /// **'The student will rejoin the trip and the parent will be notified that the absence was cancelled.'**
  String get assistantAbsenceCancelBody;

  /// No description provided for @assistantAbsenceCancelYes.
  ///
  /// In en, this message translates to:
  /// **'Cancel absence'**
  String get assistantAbsenceCancelYes;

  /// No description provided for @assistantAbsenceCancelled.
  ///
  /// In en, this message translates to:
  /// **'Absence cancelled.'**
  String get assistantAbsenceCancelled;

  /// No description provided for @assistantAbsenceReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get assistantAbsenceReasonLabel;

  /// No description provided for @assistantAbsencePickupBy.
  ///
  /// In en, this message translates to:
  /// **'Picked up by'**
  String get assistantAbsencePickupBy;

  /// No description provided for @assistantAbsenceNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent\'s note'**
  String get assistantAbsenceNoteLabel;

  /// No description provided for @assistantAbsenceReasonIllness.
  ///
  /// In en, this message translates to:
  /// **'Illness'**
  String get assistantAbsenceReasonIllness;

  /// No description provided for @assistantAbsenceReasonMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical appointment'**
  String get assistantAbsenceReasonMedical;

  /// No description provided for @assistantAbsenceReasonFamily.
  ///
  /// In en, this message translates to:
  /// **'Family matter'**
  String get assistantAbsenceReasonFamily;

  /// No description provided for @assistantAbsenceReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get assistantAbsenceReasonOther;

  /// No description provided for @driverActiveTrips.
  ///
  /// In en, this message translates to:
  /// **'Active trips'**
  String get driverActiveTrips;

  /// No description provided for @driverNoActiveTrip.
  ///
  /// In en, this message translates to:
  /// **'No active trip'**
  String get driverNoActiveTrip;

  /// No description provided for @driverNoActiveTripBody.
  ///
  /// In en, this message translates to:
  /// **'Once the assistant starts a trip, it\'ll show up here so you can open the route map.'**
  String get driverNoActiveTripBody;

  /// No description provided for @driverOpenRouteMap.
  ///
  /// In en, this message translates to:
  /// **'Open route map'**
  String get driverOpenRouteMap;

  /// No description provided for @driverRouteOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Route order'**
  String get driverRouteOrderTitle;

  /// No description provided for @driverSchoolPin.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get driverSchoolPin;

  /// No description provided for @driverNoBoardedStopsTitle.
  ///
  /// In en, this message translates to:
  /// **'No stops to route yet'**
  String get driverNoBoardedStopsTitle;

  /// No description provided for @driverNeedMoreStopsTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough stops to route'**
  String get driverNeedMoreStopsTitle;

  /// No description provided for @driverNoBoardedStopsBody.
  ///
  /// In en, this message translates to:
  /// **'The route appears once at least one student has been boarded with a known location.'**
  String get driverNoBoardedStopsBody;

  /// No description provided for @driverRouteFallback.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t fetch driving route — showing direct lines.'**
  String get driverRouteFallback;

  /// No description provided for @driverStopsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 stop} other{{count} stops}}'**
  String driverStopsCount(int count);

  /// No description provided for @assistantDroppedAt.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get assistantDroppedAt;

  /// No description provided for @assistantStatusDropped.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get assistantStatusDropped;

  /// No description provided for @assistantArrivedSchool.
  ///
  /// In en, this message translates to:
  /// **'Arrived at school'**
  String get assistantArrivedSchool;

  /// No description provided for @assistantArrivedHome.
  ///
  /// In en, this message translates to:
  /// **'Arrived home'**
  String get assistantArrivedHome;

  /// No description provided for @assistantOnBus.
  ///
  /// In en, this message translates to:
  /// **'On bus'**
  String get assistantOnBus;

  /// No description provided for @assistantMarkAbsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as absent?'**
  String get assistantMarkAbsentTitle;

  /// No description provided for @assistantMarkAbsentBody.
  ///
  /// In en, this message translates to:
  /// **'Mark {name} as absent for this trip. The student will be removed from the route and counts.'**
  String assistantMarkAbsentBody(String name);

  /// No description provided for @assistantMarkAbsentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Mark absent'**
  String get assistantMarkAbsentConfirm;

  /// No description provided for @assistantContactParent.
  ///
  /// In en, this message translates to:
  /// **'Contact parent'**
  String get assistantContactParent;

  /// No description provided for @assistantNotifyArrivedMenu.
  ///
  /// In en, this message translates to:
  /// **'Notify arrived'**
  String get assistantNotifyArrivedMenu;

  /// No description provided for @assistantCallMenu.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get assistantCallMenu;

  /// No description provided for @driverProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Drop-offs'**
  String get driverProgressLabel;

  /// No description provided for @driverProgressLabelReturn.
  ///
  /// In en, this message translates to:
  /// **'At home'**
  String get driverProgressLabelReturn;

  /// No description provided for @driverPinArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get driverPinArrived;

  /// No description provided for @driverPinAtHome.
  ///
  /// In en, this message translates to:
  /// **'At home'**
  String get driverPinAtHome;
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
