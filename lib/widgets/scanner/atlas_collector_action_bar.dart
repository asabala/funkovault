import 'package:flutter/material.dart';

import 'package:funkovault2/atlas/collection/actions/atlas_collector_action.dart';
import 'package:funkovault2/theme/atlas_colors.dart';
import 'package:funkovault2/theme/atlas_spacing.dart';
import 'package:funkovault2/theme/atlas_typography.dart';
import 'package:funkovault2/widgets/atlas/atlas_glass_panel.dart';

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
    List<AtlasCollectorAction>.from(
      actions,
    )..sort(
          (
          AtlasCollectorAction first,
          AtlasCollectorAction second,
          ) {
        return first.priority.compareTo(
          second.priority,
        );
      },
    );

    return AtlasGlassPanel(
      accentColor: AtlasColors.intelligenceBlue,
      padding: const EdgeInsets.all(
        AtlasSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '⚡ Quick Actions',
            style: AtlasTypography.headingSmall,
          ),
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          for (
          int index = 0;
          index < sortedActions.length;
          index++
          ) ...[
            _CollectorActionButton(
              action: sortedActions[index],
              onPressed: () {
                onActionPressed(
                  sortedActions[index].type,
                );
              },
            ),
            if (index < sortedActions.length - 1)
              const SizedBox(
                height: AtlasSpacing.sm,
              ),
          ],
        ],
      ),
    );
  }
}

class _CollectorActionButton extends StatelessWidget {
  const _CollectorActionButton({
    required this.action,
    required this.onPressed,
  });

  final AtlasCollectorAction action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (action.isPrimary) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(
          action.icon,
        ),
        label: Text(
          action.displayLabel,
        ),
      );
    }

    if (action.type ==
        AtlasCollectorActionType.scanAnother) {
      return TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          action.icon,
        ),
        label: Text(
          action.displayLabel,
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        action.icon,
      ),
      label: Text(
        action.displayLabel,
      ),
    );
  }
}