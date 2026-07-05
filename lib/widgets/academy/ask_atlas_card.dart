import 'package:flutter/material.dart';

import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_card.dart';
import '../atlas/atlas_glass_panel.dart';

class AskAtlasCard extends StatefulWidget {
  const AskAtlasCard({
    super.key,
    required this.suggestions,
    required this.onAsk,
  });

  final List<String> suggestions;
  final ValueChanged<String> onAsk;

  @override
  State<AskAtlasCard> createState() => _AskAtlasCardState();
}

class _AskAtlasCardState extends State<AskAtlasCard> {
  final TextEditingController _questionController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();

    super.dispose();
  }

  void _submitQuestion() {
    final question = _questionController.text.trim();

    if (question.isEmpty) {
      return;
    }

    widget.onAsk(question);

    _questionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final visibleSuggestions = widget.suggestions.take(4).toList();

    return AtlasGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AtlasColors.vaultGold,
              ),
              const SizedBox(width: AtlasSpacing.sm),
              Text(
                'Ask Atlas',
                style: AtlasTypography.headingSmall,
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.sm),
          Text(
            'Ask a collector question and Atlas will answer using approved Academy knowledge.',
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          TextField(
            controller: _questionController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _submitQuestion(),
            decoration: InputDecoration(
              hintText: 'Ask something like “What is a Chase?”',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Ask Atlas',
                icon: const Icon(Icons.arrow_forward),
                onPressed: _submitQuestion,
              ),
            ),
          ),
          if (visibleSuggestions.isNotEmpty) ...[
            const SizedBox(height: AtlasSpacing.md),
            AtlasGlassPanel(
              child: Column(
                children: [
                  for (int index = 0; index < visibleSuggestions.length; index++) ...[
                    _AskAtlasSuggestion(
                      question: visibleSuggestions[index],
                      onTap: widget.onAsk,
                    ),
                    if (index < visibleSuggestions.length - 1)
                      const Divider(height: 1),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AskAtlasSuggestion extends StatelessWidget {
  const _AskAtlasSuggestion({
    required this.question,
    required this.onTap,
  });

  final String question;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(
        Icons.question_answer_outlined,
        color: AtlasColors.intelligenceBlue,
      ),
      title: Text(
        question,
        style: AtlasTypography.bodyMedium,
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
      ),
      onTap: () => onTap(question),
    );
  }
}