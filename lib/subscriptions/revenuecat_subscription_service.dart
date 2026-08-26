import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/atlas_config.dart';
import 'subscription_service.dart';
import 'subscription_state.dart';
import 'subscription_status.dart';
import 'subscription_tier.dart';

class RevenueCatSubscriptionService implements SubscriptionService {
  const RevenueCatSubscriptionService();

  static bool _isConfigured = false;

  static Future<void> initialize() async {
    final apiKey = _apiKeyForPlatform();

    if (apiKey.isEmpty) {
      _isConfigured = false;
      return;
    }

    await Purchases.configure(
      PurchasesConfiguration(
        apiKey,
      ),
    );

    _isConfigured = true;
  }

  static Future<void> logIn(
      String userId,
      ) async {
    final cleanedUserId = userId.trim();

    if (!_isConfigured || cleanedUserId.isEmpty) {
      return;
    }

    await Purchases.logIn(
      cleanedUserId,
    );
  }

  static Future<void> logOut() async {
    if (!_isConfigured) {
      return;
    }

    await Purchases.logOut();
  }

  static String _apiKeyForPlatform() {
    if (kIsWeb) {
      return AtlasConfig.revenueCatWebApiKey;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AtlasConfig.revenueCatAndroidApiKey;

      case TargetPlatform.iOS:
        return AtlasConfig.revenueCatIosApiKey;

      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return '';
    }
  }

  @override
  Future<SubscriptionState> currentSubscription() async {
    if (!_isConfigured) {
      return SubscriptionState.basic();
    }

    final customerInfo = await Purchases.getCustomerInfo();

    return _mapCustomerInfo(customerInfo);
  }

  @override
  Future<SubscriptionState> refreshSubscription() async {
    if (!_isConfigured) {
      return SubscriptionState.basic();
    }

    final customerInfo = await Purchases.getCustomerInfo();

    return _mapCustomerInfo(customerInfo);
  }

  SubscriptionState _mapCustomerInfo(
      CustomerInfo customerInfo,
      ) {
    final premiumEntitlement =
    customerInfo.entitlements.all['premium'];

    if (premiumEntitlement?.isActive != true) {
      return SubscriptionState.basic();
    }

    return const SubscriptionState(
      tier: SubscriptionTier.premium,
      status: SubscriptionStatus.active,
    );
  }
}