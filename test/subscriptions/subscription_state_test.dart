import 'package:flutter_test/flutter_test.dart';
import 'package:funkovault2/subscriptions/subscription_state.dart';
import 'package:funkovault2/subscriptions/subscription_status.dart';
import 'package:funkovault2/subscriptions/subscription_tier.dart';

void main() {
  test('basic subscription is not premium or active', () {
    final state = SubscriptionState.basic();

    expect(state.tier, SubscriptionTier.basic);

    expect(state.status, SubscriptionStatus.inactive);

    expect(state.isPremium, isFalse);

    expect(state.isActive, isFalse);
  });

  test('active premium subscription grants premium access', () {
    const state = SubscriptionState(
      tier: SubscriptionTier.premium,
      status: SubscriptionStatus.active,
      billingPeriod: 'monthly',
    );

    expect(state.isPremium, isTrue);

    expect(state.isActive, isTrue);
  });

  test('trialing premium subscription grants premium access', () {
    const state = SubscriptionState(
      tier: SubscriptionTier.premium,
      status: SubscriptionStatus.trialing,
      billingPeriod: 'yearly',
    );

    expect(state.isPremium, isTrue);
  });

  test('canceled premium subscription does not grant premium access', () {
    const state = SubscriptionState(
      tier: SubscriptionTier.premium,
      status: SubscriptionStatus.canceled,
    );

    expect(state.isPremium, isFalse);

    expect(state.isActive, isFalse);
  });

  test('past due premium subscription does not grant premium access', () {
    const state = SubscriptionState(
      tier: SubscriptionTier.premium,
      status: SubscriptionStatus.pastDue,
    );

    expect(state.isPremium, isFalse);
  });
}
