class SecurityConstants {
  const SecurityConstants._();

  static const int minPasswordLength = 8;

  static const int maxLoginAttempts = 5;

  static const Duration sessionWarningDuration =
  Duration(minutes: 5);

  static const Duration defaultSessionDuration =
  Duration(days: 30);

  static const String basicTier = 'basic';

  static const String premiumTier = 'premium';
}