class AtlasConfig {
  const AtlasConfig._();

  /// Supabase Project URL
  static const String supabaseUrl =
      'https://qzwvzkzryzzlolcqkrfq.supabase.co';

  /// Supabase Publishable Key
  static const String supabasePublishableKey =
      'sb_publishable_Ymzz4Xcvb7MOycp0EZfNxw_jKN1pbDt';

  /// RevenueCat public SDK keys.
  /// Supply these with --dart-define when running/building Atlas.
  static const String revenueCatAndroidApiKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_API_KEY',
  );

  static const String revenueCatIosApiKey = String.fromEnvironment(
    'REVENUECAT_IOS_API_KEY',
  );

  static const String revenueCatWebApiKey = String.fromEnvironment(
    'REVENUECAT_WEB_API_KEY',
  );

  static const String appName = 'Atlas';

  static const String appVersion = '2.0.0 Alpha';
}