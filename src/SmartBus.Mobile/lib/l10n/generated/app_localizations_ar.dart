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
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginAppName => 'متعقّب الباص المدرسي';

  @override
  String get loginAppSubtitle => 'حافظ على سلامة طفلك في الطريق';

  @override
  String get loginFeatureSafety => 'الأمان';

  @override
  String get loginFeatureLiveTrack => 'تتبّع مباشر';

  @override
  String get loginFeaturePeace => 'راحة بال';

  @override
  String get loginPhonePlaceholder => '7X XXX XXXX';

  @override
  String get loginSendOtp => 'إرسال رمز التحقق';

  @override
  String get loginSendOtpHint => 'ستصلك رسالة برمز من 4 أرقام';

  @override
  String get loginTerms => 'الموافقة على الشروط وسياسة الخصوصية';

  @override
  String get loginInvalidPhone => 'أدخل رقم هاتف صحيحاً';

  @override
  String get loginUnknownError => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get otpTitle => 'أدخل رمز التحقق';

  @override
  String get otpConfirm => 'تأكيد وتسجيل الدخول';

  @override
  String get otpResendPrefix => 'لم تستلم الرمز؟';

  @override
  String get otpResend => 'إعادة الإرسال';

  @override
  String otpExpires(String time) {
    return 'ينتهي بعد $time';
  }

  @override
  String get otpInvalid => 'الرمز غير صحيح أو منتهي الصلاحية';

  @override
  String get otpFooter => 'رمزك خاص بك، لا تشاركه مع أي شخص';

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
