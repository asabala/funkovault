import 'package:flutter/material.dart';

import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/components/atlas_action_row.dart';
import '../../atlas/components/atlas_form_field.dart';
import '../../atlas/components/atlas_section_header.dart';

class AskAtlasCard extends StatefulWidget {
  const AskAtlasCard({
    super.key,
    required this.suggestions,
    required this.onAsk,
  });

  final List<String> suggestions;
  final ValueChanged<String> onAsk;

  @override
  State<AskAtlasCard> createState() {
    return _AskAtlasCardState();
  }
}

class _AskAtlasCardState extends State<AskAtlasCard> {
  static const int _maxQuestionLength = 180;
  static const int _maxVisibleSuggestions = 4;

  final TextEditingController _questionController =
  TextEditingController();

  bool get _canSubmit {
    return _questionController.text.trim().isNotEmpty;
  }

  List<String> get _visibleSuggestions {
    final Set<String> seen =
    <String>{};

    final List<String> suggestions =
    <String>[];

    for (final String rawSuggestion
    in widget.suggestions) {
      final String suggestion =
      rawSuggestion.trim();

      if (suggestion.isEmpty) {
        continue;
      }

      final String normalized =
      suggestion.toLowerCase();

      if (!seen.add(normalized)) {
        continue;
      }

      suggestions.add(
        suggestion,
      );

      if (suggestions.length >=
          _maxVisibleSuggestions) {
        break;
      }
    }

    return suggestions;
  }

  @override
  void initState() {
    super.initState();

    _questionController.addListener(
      _handleQuestionChanged,
    );
  }

  @override
  void dispose() {
    _questionController.removeListener(
      _handleQuestionChanged,
    );

    _questionController.dispose();

    super.dispose();
  }

  void _handleQuestionChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _submitTypedQuestion() {
    final String question =
    _questionController.text.trim();

    if (question.isEmpty) {
      return;
    }

    _askQuestion(
      question,
    );

    _questionController.clear();

    FocusScope.of(context).unfocus();
  }

  void _askSuggestion(
      String question,
      ) {
    FocusScope.of(context).unfocus();

    _askQuestion(
      question,
    );
  }

  void _askQuestion(
      String question,
      ) {
    final String cleanedQuestion =
    question.trim();

    if (cleanedQuestion.isEmpty) {
      return;
    }

    widget.onAsk(
      cleanedQuestion,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> visibleSuggestions =
        _visibleSuggestions;

    return AtlasGlassCard(
      accentColor:
      AtlasColors.intelligenceBlue,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const AtlasSectionHeader(
            title: 'Ask Atlas',
            subtitle:
            'Ask a collector question and Atlas will answer using approved Academy knowledge.',
            icon:
            Icons.auto_awesome_rounded,
            accentColor:
            AtlasColors.intelligenceBlue,
          ),
          const SizedBox(
            height: AtlasSpacing.lg,
          ),
          AtlasFormField(
            controller:
            _questionController,
            label: 'Collector Question',
            hintText:
            'Example: What is a Chase?',
            icon:
            Icons.search_rounded,
            maxLength:
            _maxQuestionLength,
            textInputAction:
            TextInputAction.search,
            textCapitalization:
            TextCapitalization.sentences,
            onFieldSubmitted: (_) {
              if (_canSubmit) {
                _submitTypedQuestion();
              }
            },
            suffixIcon: IconButton(
              tooltip: 'Ask Atlas',
              onPressed: _canSubmit
                  ? _submitTypedQuestion
                  : null,
              icon: const Icon(
                Icons.arrow_forward_rounded,
              ),
            ),
          ),
          if (visibleSuggestions.isNotEmpty) ...[
            const SizedBox(
              height: AtlasSpacing.lg,
            ),
            const AtlasSectionHeader(
              title: 'Suggested Questions',
              subtitle:
              'Start with one of these Academy topics.',
              icon:
              Icons.question_answer_outlined,
            ),
            const SizedBox(
              height: AtlasSpacing.md,
            ),
            for (
            int index = 0;
            index <
                visibleSuggestions.length;
            index++
            ) ...[
              AtlasActionRow(
                title:
                visibleSuggestions[index],
                description:
                'Ask Atlas about this collector topic.',
                icon: Icons
                    .question_answer_outlined,
                accentColor:
                AtlasColors
                    .intelligenceBlue,
                onTap: () {
                  _askSuggestion(
                    visibleSuggestions[index],
                  );
                },
              ),
              if (index !=
                  visibleSuggestions.length -
                      1)
                const SizedBox(
                  height:
                  AtlasSpacing.sm,
                ),
            ],
          ],
        ],
      ),
    );
  }
}