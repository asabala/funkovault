import 'package:flutter/material.dart';

import '../premium/premium_gate.dart';

class AdvancedVaultHealthPreview extends StatelessWidget {
  const AdvancedVaultHealthPreview({
    super.key,
    required this.isPremium,
    required this.child,
    this.onUpgrade,
  });

  final bool isPremium;
  final Widget child;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    return PremiumGate(
      isPremium: isPremium,
      lockedTitle: 'Advanced Vault Health',
      lockedDescription:
          'Unlock deeper vault scoring, duplicate intelligence, value cleanup priority, and collection risk insights.',
      lockedIcon: Icons.health_and_safety_rounded,
      onUpgrade: onUpgrade,
      child: child,
    );
  }
}
