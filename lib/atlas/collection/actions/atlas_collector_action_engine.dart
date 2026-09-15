import 'package:flutter/material.dart';

import 'atlas_collector_action.dart';

class AtlasCollectorActionContext {
  const AtlasCollectorActionContext({
    required this.isOwned,
    required this.isWishlisted,
    required this.canViewExistingItem,
    this.includeScanAnother = true,
  });

  final bool isOwned;
  final bool isWishlisted;
  final bool canViewExistingItem;
  final bool includeScanAnother;
}

class AtlasCollectorActionEngine {
  const AtlasCollectorActionEngine();

  List<AtlasCollectorAction> buildActions(AtlasCollectorActionContext context) {
    final List<AtlasCollectorAction> actions = <AtlasCollectorAction>[];

    if (context.isOwned && context.canViewExistingItem) {
      actions.add(
        const AtlasCollectorAction(
          type: AtlasCollectorActionType.viewExistingItem,
          label: 'View Existing Item',
          icon: Icons.visibility_outlined,
          priority: 10,
          isPrimary: true,
        ),
      );

      actions.add(
        const AtlasCollectorAction(
          type: AtlasCollectorActionType.addAnotherCopy,
          label: 'Add Another Copy',
          icon: Icons.add_circle_outline_rounded,
          priority: 20,
        ),
      );

      actions.add(
        const AtlasCollectorAction(
          type: AtlasCollectorActionType.reviewVariantSticker,
          label: 'Review Variant / Sticker',
          icon: Icons.verified_outlined,
          priority: 30,
        ),
      );

      actions.add(
        const AtlasCollectorAction(
          type: AtlasCollectorActionType.updateCondition,
          label: 'Update Condition',
          icon: Icons.inventory_2_outlined,
          priority: 40,
        ),
      );
    } else {
      actions.add(
        const AtlasCollectorAction(
          type: AtlasCollectorActionType.addToVault,
          label: 'Add to Vault',
          icon: Icons.add_circle_rounded,
          priority: 10,
          isPrimary: true,
        ),
      );
    }

    if (context.isWishlisted) {
      actions.add(
        const AtlasCollectorAction(
          type: AtlasCollectorActionType.removeFromWishlist,
          label: 'Remove from Wishlist',
          icon: Icons.heart_broken_rounded,
          priority: 50,
        ),
      );
    } else {
      actions.add(
        const AtlasCollectorAction(
          type: AtlasCollectorActionType.addToWishlist,
          label: 'Add to Wishlist',
          icon: Icons.favorite_border_rounded,
          priority: 50,
        ),
      );
    }

    if (context.includeScanAnother) {
      actions.add(
        const AtlasCollectorAction(
          type: AtlasCollectorActionType.scanAnother,
          label: 'Scan Another',
          icon: Icons.qr_code_scanner_rounded,
          priority: 100,
        ),
      );
    }

    actions.sort((AtlasCollectorAction first, AtlasCollectorAction second) {
      return first.priority.compareTo(second.priority);
    });

    return List<AtlasCollectorAction>.unmodifiable(actions);
  }
}
