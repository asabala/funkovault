import 'package:flutter/material.dart';

import 'package:funkovault2/atlas/collection/actions/atlas_collector_action.dart';
import 'package:funkovault2/theme/atlas_colors.dart';
import 'package:funkovault2/theme/atlas_spacing.dart';
import 'package:funkovault2/widgets/atlas/atlas_glass_card.dart';
import 'package:funkovault2/widgets/atlas/components/atlas_action_row.dart';
import 'package:funkovault2/widgets/atlas/components/atlas_section_header.dart';
import 'package:funkovault2/widgets/atlas/components/atlas_status_chip.dart';

class AtlasCollectorActionBar extends StatelessWidget {
  const AtlasCollectorActionBar({
    required this.actions,
    required this.onActionPressed,
    super.key,
  });

  final List<AtlasCollectorAction> actions;
  final ValueChanged<AtlasCollectorActionType> onActionPressed;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<AtlasCollectorAction> sortedActions =
        List<AtlasCollectorAction>.from(actions)
          ..sort((AtlasCollectorAction first, AtlasCollectorAction second) {
            return first.priority.compareTo(second.priority);
          });

    final AtlasCollectorAction? primaryAction = _findPrimaryAction(
      sortedActions,
    );

    return AtlasGlassCard(
      accentColor: AtlasColors.intelligenceBlue,
      padding: const EdgeInsets.all(AtlasSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtlasSectionHeader(
            title: 'Quick Actions',
            subtitle:
                'Recommended actions based on this collectible and your collection.',
            icon: Icons.bolt_rounded,
            accentColor: AtlasColors.intelligenceBlue,
            badge: primaryAction == null
                ? null
                : const AtlasStatusChip(
                    label: 'Atlas Ready',
                    icon: Icons.auto_awesome_rounded,
                    accentColor: AtlasColors.vaultGold,
                    size: AtlasStatusChipSize.compact,
                  ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          for (int index = 0; index < sortedActions.length; index++) ...[
            _CollectorActionRow(
              action: sortedActions[index],
              onPressed: () {
                onActionPressed(sortedActions[index].type);
              },
            ),
            if (index < sortedActions.length - 1)
              const SizedBox(height: AtlasSpacing.sm),
          ],
        ],
      ),
    );
  }

  AtlasCollectorAction? _findPrimaryAction(List<AtlasCollectorAction> actions) {
    for (final AtlasCollectorAction action in actions) {
      if (action.isPrimary) {
        return action;
      }
    }

    return null;
  }
}

class _CollectorActionRow extends StatelessWidget {
  const _CollectorActionRow({required this.action, required this.onPressed});

  final AtlasCollectorAction action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final _ActionPresentation presentation = _presentationFor(action.type);

    return AtlasActionRow(
      title: action.label,
      description: presentation.description,
      icon: action.icon,
      accentColor: presentation.accentColor,
      badge: action.isPrimary
          ? const AtlasStatusChip(
              label: 'Recommended',
              icon: Icons.star_rounded,
              accentColor: AtlasColors.vaultGold,
              size: AtlasStatusChipSize.compact,
            )
          : null,
      compact: action.type == AtlasCollectorActionType.scanAnother,
      showChevron: action.type != AtlasCollectorActionType.scanAnother,
      onTap: onPressed,
    );
  }

  _ActionPresentation _presentationFor(AtlasCollectorActionType type) {
    switch (type) {
      case AtlasCollectorActionType.viewExistingItem:
        return const _ActionPresentation(
          description:
              'Open the collectible already stored in this collection.',
          accentColor: AtlasColors.success,
        );

      case AtlasCollectorActionType.addToVault:
        return const _ActionPresentation(
          description: 'Add this collectible to the selected collection.',
          accentColor: AtlasColors.vaultGold,
        );

      case AtlasCollectorActionType.addAnotherCopy:
        return const _ActionPresentation(
          description:
              'Add another physical copy while preserving the existing collectible.',
          accentColor: AtlasColors.vaultGold,
        );

      case AtlasCollectorActionType.reviewVariantSticker:
        return const _ActionPresentation(
          description:
              'Review variant, exclusive, sticker, limited edition, and signature details.',
          accentColor: AtlasColors.intelligenceBlue,
        );

      case AtlasCollectorActionType.updateCondition:
        return const _ActionPresentation(
          description:
              'Update the collectible and box condition for your existing copy.',
          accentColor: AtlasColors.intelligenceBlue,
        );

      case AtlasCollectorActionType.addToWishlist:
        return const _ActionPresentation(
          description: 'Track this collectible on your wishlist for later.',
          accentColor: AtlasColors.intelligenceBlue,
        );

      case AtlasCollectorActionType.removeFromWishlist:
        return const _ActionPresentation(
          description:
              'Remove this collectible from the wishlist for this collection.',
          accentColor: AtlasColors.warning,
        );

      case AtlasCollectorActionType.scanAnother:
        return const _ActionPresentation(
          description:
              'Return to the scanner and identify another collectible.',
          accentColor: AtlasColors.textSecondary,
        );
    }
  }
}

class _ActionPresentation {
  const _ActionPresentation({
    required this.description,
    required this.accentColor,
  });

  final String description;
  final Color accentColor;
}
