// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'باص التلميذ';

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
  String get loginTagline => 'تابع كل رحلة. كل طفل. كل لحظة.';

  @override
  String get loginCardTitle => 'تسجيل الدخول';

  @override
  String get loginCardDesc => 'أدخل رقم هاتفك، سنرسل رمز تحقق من 4 أرقام.';

  @override
  String get loginTabPhone => 'الهاتف';

  @override
  String get loginTabScan => 'مسح البطاقة';

  @override
  String get loginPhoneLabel => 'رقم الهاتف';

  @override
  String get loginPhonePlaceholder => '7X XXX XXXX';

  @override
  String get loginSendOtp => 'إرسال الرمز';

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
  String get otpTitle => 'تأكيد رقمك';

  @override
  String get otpSentTo => 'أُرسل إلى';

  @override
  String get otpConfirm => 'تأكيد';

  @override
  String get otpResendPrefix => 'لم تستلم الرمز؟';

  @override
  String get otpResend => 'إعادة الإرسال';

  @override
  String otpResendWait(String time) {
    return 'الرجاء الانتظار $time قبل إعادة الإرسال';
  }

  @override
  String get otpInvalid => 'الرمز غير صحيح أو منتهي الصلاحية';

  @override
  String get otpFooter => 'لا تشارك هذا الرمز — لن يطلبه منك باص التلميذ أبداً';

  @override
  String get otpBack => 'رجوع';

  @override
  String get scanTitle => 'التسجيل';

  @override
  String get scanSubtitle => 'امسح بطاقة الطالب';

  @override
  String get scanTip => 'ضع البطاقة داخل الإطار';

  @override
  String get scanCantTitle => 'لا يمكنك المسح؟';

  @override
  String get scanCantSub => 'أدخل الرمز المكوّن من 8 خانات المطبوع على البطاقة';

  @override
  String get scanCodeHint => 'XXXX-XXXX';

  @override
  String get scanContinue => 'متابعة';

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
  String get parentStatusWaitingPickup => 'الحافلة في الطريق';

  @override
  String get assistantStartAllAbsentTitle => 'لا حاجة لبدء الرحلة';

  @override
  String get assistantStartAllAbsentBody =>
      'جميع الطلاب في هذه الرحلة مُعلَّمون كغائبين — لا يوجد ما يستدعي القيادة.';

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
  String get studentInfoSchoolAddress => 'عنوان المدرسة';

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
  String get studentEditNotes => 'ملاحظات';

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
  String get absenceSectionRequested => 'طلبات الغياب';

  @override
  String get absenceSummaryTotal => 'إجمالي الغيابات';

  @override
  String get absenceSummaryMorning => 'غيابات الذهاب';

  @override
  String get absenceSummaryReturn => 'غيابات الإياب';

  @override
  String get absenceCancelWindowNote =>
      'يمكنك إلغاء طلب الغياب في أي وقت قبل بدء الرحلة. لا يمكن الإلغاء بعد بدء الرحلة.';

  @override
  String get absenceNoRequests => 'لا توجد طلبات غياب لهذا الأسبوع بعد.';

  @override
  String get absenceCreateRequest => 'إنشاء طلب غياب';

  @override
  String get absenceCreateTitle => 'طلب غياب جديد';

  @override
  String get absenceCreateSubtitle => 'أرسل طلب غياب لمرة واحدة للطالب';

  @override
  String get absenceStatusPending => 'قيد المراجعة';

  @override
  String get absenceStatusApproved => 'مقبول';

  @override
  String get absenceStatusRejected => 'مرفوض';

  @override
  String get absenceCancelTitle => 'إلغاء الغياب؟';

  @override
  String get absenceCancelBody =>
      'سيتم إبلاغ السائق والمدرسة بإلغاء طلب الغياب.';

  @override
  String get absenceCancelYes => 'إلغاء الغياب';

  @override
  String get absenceCancelled => 'تم إلغاء طلب الغياب.';

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
  String get liveTrackingTripEndedTitle => 'انتهت الرحلة';

  @override
  String get liveTrackingTripEndedBody => 'قام المساعد بإنهاء هذه الرحلة.';

  @override
  String get liveTrackingTripEndedClose => 'إغلاق';

  @override
  String get onboardingSkip => 'تخطّي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingContinue => 'متابعة';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String get onboardingHasAccount => 'لديّ حساب بالفعل';

  @override
  String get onboardingLangSwitch => 'English';

  @override
  String onboardingStep(int step, int total) {
    return 'الخطوة $step من $total';
  }

  @override
  String get onboardingTitle1 => 'تتبّع كل رحلة <b>لحظة بلحظة</b>';

  @override
  String get onboardingDescription1 =>
      'اعرف موقع حافلة طفلك بدقة — من أول محطة حتى باب المدرسة، على خريطة حيّة.';

  @override
  String get onboardingTitle2 => 'نُنبّهك <b>في اللحظة</b> المناسبة';

  @override
  String get onboardingDescription2 =>
      'صعود، نزول، تأخير، وصول — إشعارات فورية كي لا تبقى في انتظار.';

  @override
  String get onboardingTitle3 => 'سائقون موثّقون، <b>رحلات أأمن</b>';

  @override
  String get onboardingDescription3 =>
      'كل سائق مفحوص وكل رحلة مسجّلة. راحة بال من جرس الصباح حتى عودة طفلك إلى البيت.';

  @override
  String get onboardingFooter1 => 'موثوق به من قبل آلاف العائلات في الأردن';

  @override
  String get onboardingFooter2 => 'يمكنك تفعيل الإشعارات لاحقًا من الإعدادات';

  @override
  String get onboardingFooterTermsPrefix => 'بمتابعتك توافق على ';

  @override
  String get onboardingFooterTerms => 'الشروط';

  @override
  String get onboardingFooterAnd => ' و ';

  @override
  String get onboardingFooterPrivacy => 'الخصوصية';

  @override
  String get onboardingMiniCardPickedUp => 'تم الصعود';

  @override
  String get onboardingMiniCardPickedUpSub => '7:42 ص';

  @override
  String get onboardingMiniCardEta => 'بعد ٥ دقائق';

  @override
  String get onboardingMiniCardEtaSub => 'من المدرسة';

  @override
  String get onboardingMiniCardOnTheWay => 'في الطريق';

  @override
  String get onboardingMiniCardOnTheWaySub => 'السائق: أحمد';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsEyebrow => 'النشاط';

  @override
  String get notificationsMarkAllRead => 'تعيين الكل كمقروء';

  @override
  String notificationsCountSummary(int newCount, int total) {
    return '$newCount جديد · $total إجمالاً';
  }

  @override
  String get notificationsToday => 'اليوم';

  @override
  String get notificationsYesterday => 'الأمس';

  @override
  String notificationsDaysAgo(int days) {
    return 'منذ $days أيام';
  }

  @override
  String notificationsCountNew(int count) {
    return '$count جديدة';
  }

  @override
  String notificationsCountItems(int count) {
    return '$count عنصر';
  }

  @override
  String get notificationsEmptyTitle => 'لا توجد إشعارات بعد';

  @override
  String get notificationsEmptySub => 'ستظهر هنا أي تحديثات عن رحلة طفلك.';

  @override
  String get assistantGreetMorning => 'صباح الخير';

  @override
  String get assistantGreetAfternoon => 'مساء الخير';

  @override
  String get assistantGreetEvening => 'مساء النور';

  @override
  String get assistantTodaysTrips => 'رحلات اليوم';

  @override
  String get assistantScanBusQr => 'مسح رمز الحافلة';

  @override
  String get assistantScanBusQrSub => 'امسح لبدء رحلة جديدة';

  @override
  String get assistantManualSetupCta => 'أو الإعداد يدويًا';

  @override
  String get assistantMorningPickup => 'رحلة الصباح';

  @override
  String get assistantAfternoonDropoff => 'رحلة العودة';

  @override
  String get assistantStartedAt => 'بدأت';

  @override
  String get assistantCreatedAt => 'أُنشئت';

  @override
  String get assistantBoarded => 'صعدوا';

  @override
  String get assistantStudents => 'طلاب';

  @override
  String get assistantStatusLive => 'مباشر';

  @override
  String get assistantStatusDone => 'اكتملت';

  @override
  String get assistantStatusScheduled => 'مجدولة';

  @override
  String get assistantNoTripsToday =>
      'لا توجد رحلات لهذا اليوم.\nامسح رمز الحافلة للبدء.';

  @override
  String get assistantTripSetupTitle => 'رحلة جديدة';

  @override
  String get assistantBusFromQr => 'من الرمز';

  @override
  String get assistantTripTypeLabel => 'نوع الرحلة';

  @override
  String get assistantTripTypeMorning => 'ذهاب';

  @override
  String get assistantTripTypeMorningSub => 'البيت → المدرسة';

  @override
  String get assistantTripTypeAfternoon => 'إياب';

  @override
  String get assistantTripTypeAfternoonSub => 'المدرسة → البيت';

  @override
  String get assistantStudentsAuto => 'تم تحميلهم تلقائيًا من آخر رحلة';

  @override
  String get assistantSkipRoster => 'تخطّي القائمة التلقائية';

  @override
  String get assistantSkipRosterHint =>
      'ابدأ بقائمة فارغة، يُضاف الطلاب عند مسح QR/NFC.';

  @override
  String get assistantRosterSheetTitle => 'الطلاب المُحمَّلون تلقائيًا';

  @override
  String get assistantStartTrip => 'بدء الرحلة';

  @override
  String get assistantBusLabel => 'الحافلة';

  @override
  String get assistantDriverLabel => 'السائق';

  @override
  String get assistantQrEntryHint => 'ألصق أو اكتب رمز الحافلة';

  @override
  String get assistantQrEntryConfirm => 'استخدم هذا الرمز';

  @override
  String get assistantQrSimulatorTitle => 'الكاميرا غير متاحة في المحاكي';

  @override
  String get assistantQrSimulatorBody =>
      'اكتب أو ألصق رمز الحافلة بالأسفل للمتابعة.';

  @override
  String get loginRoleParent => 'ولي أمر';

  @override
  String get loginRoleDriver => 'سائق';

  @override
  String get loginRoleAssistant => 'مرافق';

  @override
  String get assistantSelectBus => 'اختر الحافلة';

  @override
  String get assistantSelectDriver => 'اختر السائق';

  @override
  String get assistantNoLastRoster =>
      'لا توجد رحلة سابقة لهذه الحافلة + النوع. ستبدأ الرحلة بقائمة فارغة.';

  @override
  String get assistantScanStudentTitle => 'مسح رمز الطالب';

  @override
  String get assistantScanStudentOk => 'تم تسجيل الطالب.';

  @override
  String get assistantNfcUnavailable => 'الـ NFC غير متاح على هذا الجهاز.';

  @override
  String get assistantScanQr => 'مسح QR';

  @override
  String get assistantScanNfc => 'مسح NFC';

  @override
  String get assistantSearchByName => 'ابحث بالاسم';

  @override
  String get assistantRosterHeader => 'طلاب الرحلة';

  @override
  String get assistantRosterEmpty =>
      'أضف طالبًا واحدًا على الأقل قبل بدء الرحلة';

  @override
  String get assistantNoResults => 'لا توجد نتائج';

  @override
  String get assistantBoardedLabel => 'صعدوا';

  @override
  String get assistantOf => 'من';

  @override
  String get assistantScanQrShort => 'مسح QR';

  @override
  String get assistantScanQrSubShort => 'بالكاميرا';

  @override
  String get assistantTapNfc => 'بطاقة NFC';

  @override
  String get assistantTapNfcSub => 'قرّب من الهاتف';

  @override
  String get assistantStudentsByStop => 'الطلاب · مرتبون حسب الموقع';

  @override
  String get assistantRouteOrder => 'ترتيب الموقع';

  @override
  String get assistantAbsenceReported => 'تم الإبلاغ عن الغياب';

  @override
  String get assistantBoardedAt => 'صعد الساعة';

  @override
  String get assistantWaitingForPickup => 'بانتظار الصعود';

  @override
  String get assistantAbsentBadge => 'غائب';

  @override
  String get assistantNotifyArrivedOk => 'تم تنبيه ولي الأمر.';

  @override
  String get assistantNoParentPhone => 'لا يوجد رقم لولي الأمر.';

  @override
  String get assistantOpenFailed => 'تعذّر فتح التطبيق.';

  @override
  String assistantStartTripBody(int count) {
    return 'بدء الرحلة بـ $count طالب الآن؟';
  }

  @override
  String get assistantStartTripYes => 'ابدأ';

  @override
  String get assistantDeleteScheduledTitle => 'حذف الرحلة';

  @override
  String get assistantDeleteScheduledBody =>
      'هل تريد حذف هذه الرحلة المجدولة؟ لا يمكن التراجع.';

  @override
  String get assistantDeleteScheduledYes => 'حذف';

  @override
  String get assistantSaveTripTitle => 'حفظ الرحلة';

  @override
  String assistantSaveTripBody(int count) {
    return 'حفظ الرحلة مع $count طالب؟ ستبدأ الرحلة لاحقاً من شاشة التفاصيل.';
  }

  @override
  String get assistantSaveTripCta => 'حفظ الرحلة';

  @override
  String get assistantEndTrip => 'إنهاء الرحلة';

  @override
  String get assistantEndTripConfirmTitle => 'هل تريد إنهاء الرحلة؟';

  @override
  String get assistantEndTripConfirmBody =>
      'سيتم حفظ جميع عمليات الصعود ووضع الرحلة كمكتملة.';

  @override
  String get assistantEndTripConfirmYes => 'إنهاء الرحلة';

  @override
  String get assistantDeleteTrip => 'حذف الرحلة';

  @override
  String get assistantDeleteTripConfirmTitle => 'حذف هذه الرحلة؟';

  @override
  String get assistantDeleteTripConfirmBody =>
      'لا يوجد طلاب في هذه الرحلة بعد. الحذف يلغيها دون تسجيل في السجل.';

  @override
  String get assistantDeleteTripConfirmYes => 'حذف';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsProfile => 'الملف الشخصي';

  @override
  String get settingsFullName => 'الاسم الكامل';

  @override
  String get settingsFullNameHint => 'اكتب اسمك الكامل';

  @override
  String get settingsPhoneNumber => 'رقم الجوال';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsSave => 'حفظ التغييرات';

  @override
  String get settingsSaved => 'تم تحديث البيانات.';

  @override
  String get settingsCancel => 'إلغاء';

  @override
  String get settingsLogout => 'تسجيل الخروج';

  @override
  String get settingsLogoutTitle => 'تسجيل الخروج؟';

  @override
  String get settingsLogoutBody =>
      'سيتعين عليك تسجيل الدخول مجددًا برقم جوالك.';

  @override
  String get assistantEndedAt => 'انتهت';

  @override
  String get assistantNotBoarded => 'لم يصعد';

  @override
  String get assistantNotBoardedShort => 'لم يصعد';

  @override
  String get assistantTripCompletedTitle => 'اكتملت الرحلة';

  @override
  String get assistantAbsenceSheetTitle => 'تفاصيل الغياب';

  @override
  String get assistantAbsenceCancelTitle => 'إلغاء طلب الغياب؟';

  @override
  String get assistantAbsenceCancelBody =>
      'سيعود الطالب إلى الرحلة وسيتم إبلاغ ولي الأمر بإلغاء الغياب.';

  @override
  String get assistantAbsenceCancelYes => 'إلغاء الغياب';

  @override
  String get assistantAbsenceCancelled => 'تم إلغاء طلب الغياب.';

  @override
  String get assistantAbsenceReasonLabel => 'السبب';

  @override
  String get assistantAbsencePickupBy => 'تم الاستلام بواسطة';

  @override
  String get assistantAbsenceNoteLabel => 'ملاحظة ولي الأمر';

  @override
  String get assistantAbsenceReasonIllness => 'مرض';

  @override
  String get assistantAbsenceReasonMedical => 'موعد طبي';

  @override
  String get assistantAbsenceReasonFamily => 'أمر عائلي';

  @override
  String get assistantAbsenceReasonOther => 'أخرى';

  @override
  String get driverActiveTrips => 'الرحلات النشطة';

  @override
  String get driverNoActiveTrip => 'لا توجد رحلة نشطة';

  @override
  String get driverNoActiveTripBody =>
      'بمجرد أن يبدأ المرافق الرحلة، ستظهر هنا لتتمكن من فتح خريطة المسار.';

  @override
  String get driverOpenRouteMap => 'افتح خريطة المسار';

  @override
  String get driverRouteOrderTitle => 'ترتيب المسار';

  @override
  String get driverSchoolPin => 'المدرسة';

  @override
  String get driverNoBoardedStopsTitle => 'لا توجد محطات للتوجيه بعد';

  @override
  String get driverNeedMoreStopsTitle => 'لا توجد محطات كافية للتوجيه';

  @override
  String get driverNoBoardedStopsBody =>
      'سيظهر المسار بمجرد إركاب طالب واحد على الأقل بموقع معروف.';

  @override
  String get driverRouteFallback =>
      'تعذّر جلب مسار القيادة — يتم عرض خطوط مباشرة.';

  @override
  String driverStopsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محطة',
      many: '$count محطة',
      few: '$count محطات',
      two: 'محطتان',
      one: 'محطة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get assistantDroppedAt => 'تم التوصيل';

  @override
  String get assistantStatusDropped => 'وصل';

  @override
  String get assistantArrivedSchool => 'وصل إلى المدرسة';

  @override
  String get assistantArrivedHome => 'وصل إلى المنزل';

  @override
  String get assistantOnBus => 'على متن الحافلة';

  @override
  String get assistantMarkAbsentTitle => 'تسجيل غياب الطالب؟';

  @override
  String assistantMarkAbsentBody(String name) {
    return 'تسجيل $name غائبًا في هذه الرحلة. سيتم إزالته من المسار والإحصاءات.';
  }

  @override
  String get assistantMarkAbsentConfirm => 'تسجيل غياب';

  @override
  String get assistantContactParent => 'تواصل مع ولي الأمر';

  @override
  String get assistantNotifyArrivedMenu => 'تنبيه الوصول';

  @override
  String get assistantCallMenu => 'اتصال';

  @override
  String get driverProgressLabel => 'التوصيل';

  @override
  String get driverProgressLabelReturn => 'في المنزل';

  @override
  String get driverPinArrived => 'وصل';

  @override
  String get driverPinAtHome => 'في المنزل';
}
