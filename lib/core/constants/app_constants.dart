class AppConstants {
  AppConstants._();

  // --- API ---
  static const String baseUrl = 'https://your-api.com/api/v1';
  static const int connectTimeout = 30000; // ms
  static const int receiveTimeout = 30000;

  // --- SharedPreferences Keys ---
  static const String keyAuthToken = 'auth_token';
  static const String keyOnboardingSeen = 'onboarding_seen';
  static const String keyUserId = 'user_id';

  // --- Misc ---
  static const String appName = 'TaskManager';
}
