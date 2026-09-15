import 'package:flutter/material.dart';

import 'premium_feature_card.dart';

class PremiumGate extends StatelessWidget {
  const PremiumGate({
    super.key,
    required this.isPremium,
    required this.child,
    required this.lockedTitle,
    required this.lockedDescription,
    this.lockedActionLabel = 'Upgrade to Premium',
    this.lockedIcon = Icons.workspace_premium_rounded,
    this.onUpgrade,
  });

  final bool isPremium;
  final Widget child;
  final String lockedTitle;
  final String lockedDescription;
  final String lockedActionLabel;
  final IconData lockedIcon;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    if (isPremium) {
      return child;
    }

    return PremiumFeatureCard(
      title: lockedTitle,
      description: lockedDescription,
      actionLabel: lockedActionLabel,
      icon: lockedIcon,
      onAction: onUpgrade,
    );
  }
}
