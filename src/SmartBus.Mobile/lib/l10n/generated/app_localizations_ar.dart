// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'سمارت باص';

  @override
  String get loginAppName => 'متعقّب الباص المدرسي';

  @override
  String get loginAppSubtitle => 'حافظ على سلامة طفلك في كل رحلة';

  @override
  String get loginBadgeSecure => 'آمن';

  @override
  String get loginBadgeLiveGps => 'تتبّع حي';

  @override
  String get loginBadgeTrusted => 'موثوق';

  @override
  String get loginEyebrow => 'أهلاً بعودتك';

  @override
  String get loginCardTitle => 'سجّل الدخول للمتابعة';

  @override
  String get loginCardDesc => 'اختر طريقة الدخول إلى حسابك';

  @override
  String get loginTabPhone => 'الهاتف';

  @override
  String get loginTabScan => 'مسح البطاقة';

  @override
  String get loginPhoneLabel => 'رقم الهاتف';

  @override
  String get loginPhonePlaceholder => '7X XXX XXXX';

  @override
  String get loginPhoneHelp => 'سنرسل لك رمز تحقق من 4 أرقام';

  @override
  String get loginSendOtp => 'إرسال رمز التحقق';

  @override
  String get loginTerms => 'بمتابعتك فإنك توافق على الشروط وسياسة الخصوصية';

  @override
  String get loginScanComingSoon => 'تسجيل الدخول بالبطاقة قريباً';

  @override
  String get loginInvalidPhone => 'أدخل رقم هاتف صحيحاً';

  @override
  String get loginPhoneNotRegistered =>
      'هذا الرقم غير مسجّل لدينا. يرجى التواصل مع إدارة المدرسة.';

  @override
  String get loginNetworkError =>
      'خطأ في الشبكة. تحقّق من الاتصال وحاول مرة أخرى.';

  @override
  String get loginUnknownError => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get otpHeroTitle => 'تأكيد رقمك';

  @override
  String get otpHeroSubtitle => 'تم إرسال رمز إلى جهازك';

  @override
  String get otpEyebrow => 'التحقق';

  @override
  String get otpTitle => 'أدخل الرمز المكوّن من 4 أرقام';

  @override
  String get otpSentTo => 'أُرسل إلى';

  @override
  String get otpConfirm => 'تأكيد وتسجيل الدخول';

  @override
  String get otpResendPrefix => 'لم تستلم الرمز؟';

  @override
  String get otpResend => 'إعادة الإرسال';

  @override
  String get otpInvalid => 'الرمز غير صحيح أو منتهي الصلاحية';

  @override
  String get otpFooter =>
      'لا تشارك هذا الرمز — لن يطلبه منك متعقّب الباص المدرسي أبداً';

  @override
  String get navDashboard => 'لوحة التحكم';

  @override
  String get navTrips => 'الرحلات';

  @override
  String get navStudents => 'الطلاب';

  @override
  String get navDrivers => 'السائقون';

  @override
  String get navBuses => 'الحافلات';

  @override
  String get navAlerts => 'التنبيهات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navLogout => 'تسجيل الخروج';

  @override
  String get validationRequired => 'هذا الحقل مطلوب';

  @override
  String get validationEmail => 'أدخل بريداً إلكترونياً صحيحاً';

  @override
  String get validationPhone => 'أدخل رقم هاتف صحيحاً';

  @override
  String get validationNationalNumber => 'أدخل رقماً وطنياً صحيحاً';

  @override
  String validationMinLength(int n) {
    return 'يجب أن يحتوي على $n أحرف على الأقل';
  }

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonOk => 'موافق';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonLoading => 'جارٍ التحميل…';

  @override
  String homeWelcome(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get homeParentTitle => 'لوحة ولي الأمر';

  @override
  String get homeDriverTitle => 'لوحة السائق';

  @override
  String get homeAssistantTitle => 'لوحة المساعد';

  @override
  String get homeParentTrack => 'تتبّع الباص';

  @override
  String get homeParentTrips => 'رحلة اليوم';

  @override
  String get homeParentAbsence => 'الإبلاغ عن غياب';

  @override
  String get homeDriverStartTrip => 'بدء رحلة';

  @override
  String get homeDriverActiveTrip => 'الرحلة الحالية';

  @override
  String get homeDriverHistory => 'سجلّ الرحلات';

  @override
  String get homeDriverAttendance => 'الحضور';

  @override
  String get homeAssistantBoarding => 'تسجيل الصعود';

  @override
  String get homeAssistantScan => 'مسح البطاقة';

  @override
  String get homeAssistantRoster => 'كشف اليوم';

  @override
  String get parentGreetingEyebrow => 'صباح الخير';

  @override
  String get parentNoChildren => 'لا يوجد أطفال مرتبطون بحسابك حتى الآن.';

  @override
  String get parentNoTrips => 'لا توجد رحلات بعد.';

  @override
  String get parentTripEyebrow => 'آخر رحلة';

  @override
  String get parentTripPickup => 'الاستلام';

  @override
  String get parentTripDropoff => 'التوصيل';

  @override
  String get parentMetaBus => 'الحافلة';

  @override
  String get parentMetaDriver => 'السائق';

  @override
  String get parentMetaDuration => 'المدة';

  @override
  String get parentDayToday => 'اليوم';

  @override
  String get parentDayYesterday => 'أمس';

  @override
  String get parentStatusArrived => 'وصل بأمان';

  @override
  String get parentStatusOnBus => 'في الحافلة';

  @override
  String get parentStatusAwaiting => 'بانتظار اليوم';

  @override
  String get parentSectionQuickActions => 'إجراءات سريعة';

  @override
  String get parentSectionRecentTrips => 'آخر الرحلات';

  @override
  String get parentViewAll => 'عرض الكل';

  @override
  String get parentActionStudentInfo => 'معلومات الطالب';

  @override
  String get parentActionStudentInfoSub => 'عرض التفاصيل';

  @override
  String get parentActionTripHistory => 'سجل الرحلات';

  @override
  String get parentActionTripHistorySub => 'الرحلات السابقة';

  @override
  String get parentActionAbsence => 'الإبلاغ عن غياب';

  @override
  String get parentActionAbsenceSub => 'إعلام السائق';

  @override
  String get parentTagOnTime => 'في الموعد';

  @override
  String get parentTagAbsent => 'غائب';

  @override
  String get parentTagPending => 'قيد الانتظار';

  @override
  String get studentInfoTitle => 'معلومات الطالب';

  @override
  String get studentInfoIdLabel => 'رقم الطالب';

  @override
  String get studentInfoClassPrefix => 'فصل';

  @override
  String get studentInfoGeneral => 'المعلومات الأساسية';

  @override
  String get studentInfoDob => 'تاريخ الميلاد';

  @override
  String get studentInfoSchool => 'المدرسة';

  @override
  String get studentInfoHomeAddress => 'عنوان المنزل';

  @override
  String get studentInfoRoute => 'المسار';

  @override
  String get studentInfoNotes => 'ملاحظات الوالدين';

  @override
  String get studentInfoEmergency => 'جهة الطوارئ';

  @override
  String get studentInfoParentContact => 'جهة الاتصال — ولي الأمر';

  @override
  String get studentInfoNoContacts => 'لا توجد جهة اتصال مسجّلة.';

  @override
  String get studentEditEyebrow => 'تعديل البيانات';

  @override
  String get studentEditBasicInfo => 'المعلومات الأساسية';

  @override
  String get studentEditFullName => 'الاسم الكامل';

  @override
  String get studentEditFullNameHint => 'الاسم الكامل للطالب';

  @override
  String get studentEditStudentId => 'رقم الطالب';

  @override
  String get studentEditAuto => 'تلقائي';

  @override
  String get studentEditGrade => 'الصف';

  @override
  String get studentEditClass => 'الفصل';

  @override
  String get studentEditClassHint => 'مثال: أ';

  @override
  String get studentEditNotes => 'ملاحظات الوالدين';

  @override
  String get studentEditDriverNote => 'ملاحظة للسائق';

  @override
  String get studentEditNotesHint => 'هل هناك شيء يجب أن يعرفه السائق؟';

  @override
  String get studentEditParentInfo => 'معلومات ولي الأمر';

  @override
  String get studentEditVerified => 'موثّق';

  @override
  String get studentEditParentNameHint => 'الاسم الكامل لولي الأمر';

  @override
  String get studentEditMobile => 'رقم الجوال';

  @override
  String get studentEditSave => 'حفظ التغييرات';

  @override
  String get studentEditSaved => 'تم الحفظ';

  @override
  String get studentEditFailed => 'تعذّر الحفظ. يرجى المحاولة مرة أخرى.';

  @override
  String get studentEditMissingFields => 'يرجى تعبئة الحقول المطلوبة.';

  @override
  String get tripHistoryTitle => 'سجل الرحلات';

  @override
  String get tripHistoryLast7 => 'آخر 7 أيام';

  @override
  String get tripHistoryThisWeek => 'هذا الأسبوع';

  @override
  String get tripHistoryToday => 'اليوم';

  @override
  String get tripHistoryYesterday => 'أمس';

  @override
  String get tripHistoryMorningPickup => 'رحلة الصباح';

  @override
  String get tripHistoryAfternoonDropoff => 'رحلة العودة';

  @override
  String get tripHistoryOnTime => 'في الموعد';

  @override
  String tripHistoryLateMinutes(int n) {
    return 'تأخير $n دقيقة';
  }

  @override
  String get tripHistoryAbsent => 'غائب';

  @override
  String get tripHistoryPending => 'قيد الانتظار';

  @override
  String get tripHistoryDriver => 'السائق';

  @override
  String get tripHistoryAssistant => 'المساعد';

  @override
  String get tripHistoryReportedAbsent => 'تم الإبلاغ عن الغياب';

  @override
  String get tripHistoryEmpty => 'لا توجد رحلات لهذا الطفل بعد.';

  @override
  String get absenceEyebrow => 'طلب جديد';

  @override
  String get absenceTitle => 'تسجيل غياب';

  @override
  String get absenceSubtitle => 'سيتم إبلاغ السائق والمدرسة فوراً';

  @override
  String get absenceSectionStudent => 'الطالب';

  @override
  String get absenceSectionDate => 'تاريخ الغياب';

  @override
  String get absenceSectionService => 'خدمة الحافلة';

  @override
  String get absenceSectionReason => 'السبب';

  @override
  String get absenceSectionNote => 'ملاحظة للسائق';

  @override
  String get absenceOptional => '(اختياري)';

  @override
  String get absenceOptionFullTitle => 'غياب يوم كامل';

  @override
  String get absenceOptionFullDesc => 'لن يحضر الطالب إلى المدرسة اليوم';

  @override
  String get absenceFullNote =>
      'لا توجد خدمة حافلة اليوم. سيتم إبلاغ السائق والمدرسة.';

  @override
  String get absenceOptionMorningTitle => 'إلغاء حافلة الصباح';

  @override
  String get absenceOptionMorningDesc => 'ولي الأمر سيوصل الطالب إلى المدرسة';

  @override
  String get absenceOptionReturnTitle => 'إلغاء حافلة العودة';

  @override
  String get absenceOptionReturnDesc => 'ولي الأمر سيستلم الطالب من المدرسة';

  @override
  String get absenceReasonIllness => 'مرض';

  @override
  String get absenceReasonAppointment => 'موعد طبي';

  @override
  String get absenceReasonFamily => 'ظرف عائلي';

  @override
  String get absenceReasonOther => 'أخرى';

  @override
  String get absenceNoteHint => 'هل هناك شيء آخر يجب أن يعرفه السائق؟';

  @override
  String get absenceInfoBox =>
      'يمكنك إلغاء هذا الطلب حتى 30 دقيقة قبل انطلاق الحافلة';

  @override
  String get absenceSubmit => 'إرسال طلب الغياب';

  @override
  String get absenceSubmitted => 'تم تسجيل الغياب';

  @override
  String get absenceFailed => 'تعذّر الإرسال. يرجى المحاولة مرة أخرى.';

  @override
  String get parentTrackLive => 'التتبّع المباشر';

  @override
  String get liveTrackingLive => 'مباشر';

  @override
  String get liveTrackingMin => 'د';

  @override
  String get liveTrackingOnTime => 'في الموعد';

  @override
  String get liveTrackingOnTheWaySchool => 'في الطريق إلى المدرسة';

  @override
  String get liveTrackingOnTheWayHome => 'في الطريق إلى المنزل';

  @override
  String get liveTrackingHome => 'المنزل';

  @override
  String get liveTrackingBoarded => 'الصعود';

  @override
  String get liveTrackingDistance => 'المسافة';

  @override
  String get liveTrackingSpeed => 'السرعة';

  @override
  String get liveTrackingArrives => 'الوصول';

  @override
  String get liveTrackingDriver => 'السائق';

  @override
  String get liveTrackingAssistant => 'المساعد';

  @override
  String get liveTrackingNoCrew => 'لم يُعيّن طاقم بعد';

  @override
  String liveTrackingLastUpdated(String when) {
    return 'آخر تحديث $when';
  }

  @override
  String get liveTrackingJustNow => 'الآن';

  @override
  String get liveTrackingNever => '—';

  @override
  String get onboardingSkip => 'تخطّي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String get onboardingTitle1 => 'تتبّع الحافلات لحظة بلحظة';

  @override
  String get onboardingDescription1 =>
      'اعرف موقع حافلة طفلك في كل خطوة من الرحلة.';

  @override
  String get onboardingTitle2 => 'تنبيهات الوصول';

  @override
  String get onboardingDescription2 =>
      'إشعارات للاستلام والتوصيل وأي تأخير غير متوقع.';

  @override
  String get onboardingTitle3 => 'ابقَ على تواصل';

  @override
  String get onboardingDescription3 =>
      'خط مباشر مع السائقين وطاقم المدرسة وقت الحاجة.';
}
