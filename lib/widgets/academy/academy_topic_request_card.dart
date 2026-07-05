import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_card.dart';
import '../atlas/atlas_glass_panel.dart';

class AcademyTopicRequestCard extends StatefulWidget {
  const AcademyTopicRequestCard({
    super.key,
    required this.onSubmit,
  });

  final ValueChanged<String> onSubmit;

  @override
  State<AcademyTopicRequestCard> createState() =>
      _AcademyTopicRequestCardState();
}

class _AcademyTopicRequestCardState extends State<AcademyTopicRequestCard> {
  final TextEditingController _topicController = TextEditingController();

  @override
  void dispose() {
    _topicController.dispose();

    super.dispose();
  }

  void _submitTopic() {
    final topic = _topicController.text.trim();

    if (topic.isEmpty) {
      return;
    }

    widget.onSubmit(topic);

    _topicController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      child: AtlasGlassPanel(
        child: Padding(
          padding: const EdgeInsets.all(AtlasSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: AtlasColors.vaultGold,
                  ),
                  const SizedBox(width: AtlasSpacing.sm),
                  Expanded(
                    child: Text(
                      'Suggest an Academy Topic',
                      style: AtlasTypography.headingSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AtlasSpacing.sm),
              Text(
                'Want Atlas to teach something else? Suggest a collector topic for future Academy review.',
                style: AtlasTypography.bodySmall.copyWith(
                  color: AtlasColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AtlasSpacing.md),
              TextField(
                controller: _topicController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submitTopic(),
                decoration: InputDecoration(
                  hintText: 'Example: Limited Edition stickers',
                  prefixIcon: const Icon(Icons.edit_note),
                  suffixIcon: IconButton(
                    tooltip: 'Submit topic request',
                    icon: const Icon(Icons.send),
                    onPressed: _submitTopic,
                  ),
                ),
              ),
              const SizedBox(height: AtlasSpacing.sm),
              Text(
                'Future version: topic requests can be sent to the Atlas admin review queue.',
                style: AtlasTypography.bodySmall.copyWith(
                  color: AtlasColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}