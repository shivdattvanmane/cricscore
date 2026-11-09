import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized configuration provider reading from .env file
/// No API keys are hardcoded in source code; all values are read strictly from .env.
class AppConfig {
  static bool _isLoaded = false;

  /// Loads environment variables from `.env` file
  static Future<void> init() async {
    if (_isLoaded) return;
    try {
      await dotenv.load(fileName: ".env");
      _isLoaded = true;
    } catch (_) {
      _isLoaded = true;
    }
  }

  // --- CricAPI Keys ---
  static String get cricApiMatchKey =>
      dotenv.maybeGet('CRICAPI_MATCH_KEY') ?? '';

  static String get cricApiSeriesKey =>
      dotenv.maybeGet('CRICAPI_SERIES_KEY') ?? '';

  // --- Firebase Project & Senders ---
  static String get firebaseProjectId =>
      dotenv.maybeGet('FIREBASE_PROJECT_ID') ?? '';

  static String get firebaseSenderId =>
      dotenv.maybeGet('FIREBASE_SENDER_ID') ?? '';

  static String get firebaseStorageBucket =>
      dotenv.maybeGet('FIREBASE_STORAGE_BUCKET') ?? '';

  // --- Firebase Web ---
  static String get firebaseWebApiKey =>
      dotenv.maybeGet('FIREBASE_WEB_API_KEY') ?? '';

  static String get firebaseWebAppId =>
      dotenv.maybeGet('FIREBASE_WEB_APP_ID') ?? '';

  static String get firebaseWebMeasurementId =>
      dotenv.maybeGet('FIREBASE_WEB_MEASUREMENT_ID') ?? '';

  // --- Firebase Android ---
  static String get firebaseAndroidApiKey =>
      dotenv.maybeGet('FIREBASE_ANDROID_API_KEY') ?? '';

  static String get firebaseAndroidAppId =>
      dotenv.maybeGet('FIREBASE_ANDROID_APP_ID') ?? '';

  // --- Firebase iOS ---
  static String get firebaseIosApiKey =>
      dotenv.maybeGet('FIREBASE_IOS_API_KEY') ?? '';

  static String get firebaseIosAppId =>
      dotenv.maybeGet('FIREBASE_IOS_APP_ID') ?? '';

  static String get firebaseIosBundleId =>
      dotenv.maybeGet('FIREBASE_IOS_BUNDLE_ID') ?? 'com.example.cricketscore';

  // --- Firebase Windows ---
  static String get firebaseWindowsApiKey =>
      dotenv.maybeGet('FIREBASE_WINDOWS_API_KEY') ?? '';

  static String get firebaseWindowsAppId =>
      dotenv.maybeGet('FIREBASE_WINDOWS_APP_ID') ?? '';

  static String get firebaseWindowsMeasurementId =>
      dotenv.maybeGet('FIREBASE_WINDOWS_MEASUREMENT_ID') ?? '';
}
