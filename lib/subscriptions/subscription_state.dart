import 'subscription_status.dart';
import 'subscription_tier.dart';

class SubscriptionState {
  const SubscriptionState({
    required this.tier,
    required this.status,
    this.billingPeriod,
    this.currentPeriodEnd,
    this.willCancelAtPeriodEnd = false,
  });

  final SubscriptionTier tier;
  final SubscriptionStatus status;

  /// Provider-independent value such as:
  /// monthly, yearly, or null for the Basic tier.
  final String? billingPeriod;

  final DateTime? currentPeriodEnd;
  final bool willCancelAtPeriodEnd;

  bool get isPremium {
    return tier == SubscriptionTier.premium &&
        (status == SubscriptionStatus.active ||
            status == SubscriptionStatus.trialing);
  }

  bool get isActive {
    return status == SubscriptionStatus.active ||
        status == SubscriptionStatus.trialing;
  }

  factory SubscriptionState.basic() {
    return const SubscriptionState(
      tier: SubscriptionTier.basic,
      status: SubscriptionStatus.inactive,
    );
  }

  SubscriptionState copyWith({
    SubscriptionTier? tier,
    SubscriptionStatus? status,
    String? billingPeriod,
    DateTime? currentPeriodEnd,
    bool? willCancelAtPeriodEnd,
  }) {
    return SubscriptionState(
      tier: tier ?? this.tier,
      status: status ?? this.status,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      willCancelAtPeriodEnd:
          willCancelAtPeriodEnd ?? this.willCancelAtPeriodEnd,
    );
  }
}
