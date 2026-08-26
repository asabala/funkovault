import 'subscription_state.dart';

abstract interface class SubscriptionService {
  Future<SubscriptionState> currentSubscription();

  Future<SubscriptionState> refreshSubscription();
}