/// Barcha sozlamalar build vaqtida --dart-define orqali beriladi.
/// Masalan: flutter run --dart-define=API_BASE_URL=https://api.example.com/api/v1
class AppConfig {
  AppConfig._();

  static const String appName = 'Shirinliklar';
  static const String applicationId = 'uz.shirinliklar.app';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000/api/v1',
  );

  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const bool isProduction = environment == 'production';

  /// Production'da faqat HTTPS API ishlatiladi; noto'g'ri sozlama ilova ishga tushishidayoq aniqlanadi.
  static void ensureValid() {
    if (isProduction && !apiBaseUrl.startsWith('https://')) {
      throw StateError('Production uchun API_BASE_URL https:// bilan boshlanishi shart.');
    }
  }

  // Firebase (kalitlar kodda yozilmaydi, faqat dart-define orqali beriladi)
  static const String firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const String firebaseMessagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const String firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

  /// Mijozlar murojaat qiladigan email (maxfiylik va qaytarish sahifalarida ko'rinadi).
  static const String supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'support@shirinliklar.uz',
  );

  /// Onlayn to'lovni qaytarish muddati (ish kuni), qaytarish qoidalarida ko'rinadi.
  static const int refundDays = int.fromEnvironment('REFUND_DAYS', defaultValue: 5);

  /// Google Web client ID (Firebase ID token olish uchun).
  static const String googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
}