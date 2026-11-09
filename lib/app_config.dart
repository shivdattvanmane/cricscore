import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized configuration provider reading from .env file
class AppConfig {
  static bool _isLoaded = false;

  /// Loads environment variables from `.env` file
  static Future<void> init() async {
    if (_isLoaded) return;
    try {
      await dotenv.load(fileName: ".env");
      _isLoaded = true;
    } catch (_) {
      // In case .env is missing or cannot be bundled, safe fallback constants are used
      _isLoaded = true;
    }
  }

  // --- CricAPI Keys ---
  static String get cricApiMatchKey =>
      dotenv.maybeGet('CRICAPI_MATCH_KEY') ?? '27dfcd8c-bcbe-4608-87c7-c998839ab680';

  static String get cricApiSeriesKey =>
      dotenv.maybeGet('CRICAPI_SERIES_KEY') ?? '837ed22d-4bcd-463b-a78a-a617ac7d20c2';

  // --- Firebase Project & Senders ---
  static String get firebaseProjectId =>
      dotenv.maybeGet('FIREBASE_PROJECT_ID') ?? 'cricket-5f6d2';

  static String get firebaseSenderId =>
      dotenv.maybeGet('FIREBASE_SENDER_ID') ?? '887568158594';

  static String get firebaseStorageBucket =>
      dotenv.maybeGet('FIREBASE_STORAGE_BUCKET') ?? 'cricket-5f6d2.appspot.com';

  // --- Firebase Web ---
  static String get firebaseWebApiKey =>
      dotenv.maybeGet('FIREBASE_WEB_API_KEY') ?? 'AIzaSyBYyPdx85Dm90LyTSBACaKRlrDf-JoUi-A';

  static String get firebaseWebAppId =>
      dotenv.maybeGet('FIREBASE_WEB_APP_ID') ?? '1:887568158594:web:9f6e0173854ec19936899b';

  static String get firebaseWebMeasurementId =>
      dotenv.maybeGet('FIREBASE_WEB_MEASUREMENT_ID') ?? 'G-CY9JVCJ6GS';

  // --- Firebase Android ---
  static String get firebaseAndroidApiKey =>
      dotenv.maybeGet('FIREBASE_ANDROID_API_KEY') ?? 'AIzaSyB0JvUMAf-ahgQ-rJLZLZzWNpr-ze8g51M';

  static String get firebaseAndroidAppId =>
      dotenv.maybeGet('FIREBASE_ANDROID_APP_ID') ?? '1:887568158594:android:fb0415d8b8f6651a36899b';

  // --- Firebase iOS ---
  static String get firebaseIosApiKey =>
      dotenv.maybeGet('FIREBASE_IOS_API_KEY') ?? 'AIzaSyCZa2ycyju8zRJxxCOil6AndpikXCKUnV8';

  static String get firebaseIosAppId =>
      dotenv.maybeGet('FIREBASE_IOS_APP_ID') ?? '1:887568158594:ios:10c98893067589cb36899b';

  static String get firebaseIosBundleId =>
      dotenv.maybeGet('FIREBASE_IOS_BUNDLE_ID') ?? 'com.example.cricketscore';

  // --- Firebase Windows ---
  static String get firebaseWindowsApiKey =>
      dotenv.maybeGet('FIREBASE_WINDOWS_API_KEY') ?? 'AIzaSyBYyPdx85Dm90LyTSBACaKRlrDf-JoUi-A';

  static String get firebaseWindowsAppId =>
      dotenv.maybeGet('FIREBASE_WINDOWS_APP_ID') ?? '1:887568158594:web:e07deb203e9c264336899b';

  static String get firebaseWindowsMeasurementId =>
      dotenv.maybeGet('FIREBASE_WINDOWS_MEASUREMENT_ID') ?? 'G-K0LDK70L90';
}

