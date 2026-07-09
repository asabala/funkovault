import 'package:flutter/material.dart';

import '../../models/pop.dart';

class CollectorIdentityChips extends StatelessWidget {
  const CollectorIdentityChips({
    super.key,
    required this.pop,
  });

  final Pop pop;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    void addChip(String value) {
      final cleanValue = value.trim();

      if (cleanValue.isEmpty ||
          cleanValue == 'None' ||
          cleanValue == 'Unsigned' ||
          cleanValue == 'Common') {
        return;
      }

      chips.add(
        Chip(
          label: Text(cleanValue),
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    addChip(pop.variant);
    addChip(pop.retailExclusive);
    addChip(pop.eventSticker);
    addChip(pop.limitedEdition);
    addChip(pop.signature);

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: chips,
      ),
    );
  }
}