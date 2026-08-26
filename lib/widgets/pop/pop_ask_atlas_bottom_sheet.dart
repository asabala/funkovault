import 'package:flutter/material.dart';

import '../../../atlas/engines/context/pop_context_explainer_engine.dart';
import '../../../models/activity.dart';
import '../../../models/pop.dart';
import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_panel.dart';

class PopAskAtlasBottomSheet {
  const PopAskAtlasBottomSheet._();

  static void show({
    required BuildContext context,
    required Pop pop,
    required List<Activity> activities,
    required PopContextExplainerEngine explainerEngine,
    String initialQuestion = 'What changed with this Pop?',
  }) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (_) {
        return _PopAskAtlasSheet(
          pop: pop,
          activities: activities,
          explainerEngine: explainerEngine,
          initialQuestion: initialQuestion,
        );
      },
    );
  }
}

class _PopAskAtlasSheet extends StatefulWidget {
  const _PopAskAtlasSheet({
    required this.pop,
    required this.activities,
    required this.explainerEngine,
    required this.initialQuestion,
  });

  final Pop pop;
  final List<Activity> activities;
  final PopContextExplainerEngine explainerEngine;
  final String initialQuestion;

  @override
  State<_PopAskAtlasSheet> createState() => _PopAskAtlasSheetState();
}

class _PopAskAtlasSheetState extends State<_PopAskAtlasSheet> {
  late final TextEditingController _questionController;
  late PopContextAnswer _answer;

  @override
  void initState() {
    super.initState();

    _questionController = TextEditingController(
      text: widget.initialQuestion,
    );

    _answer = _buildAnswer(widget.initialQuestion);
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  PopContextAnswer _buildAnswer(String question) {
    return widget.explainerEngine.explain(
      question: question,
      pop: widget.pop,
      activities: widget.activities,
    );
  }

  void _submitQuestion() {
    final question = _questionController.text.trim();

    if (question.isEmpty) {
      return;
    }

    setState(() {
      _answer = _buildAnswer(question);
    });
  }

  void _askSuggestedQuestion(String question) {
    _questionController.text = question;
    _questionController.selection = TextSelection.collapsed(
      offset: question.length,
    );

    setState(() {
      _answer = _buildAnswer(question);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AtlasSpacing.lg,
          AtlasSpacing.sm,
          AtlasSpacing.lg,
          AtlasSpacing.lg + bottomInset,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: AtlasColors.vaultGold,
                  ),
                  const SizedBox(width: AtlasSpacing.sm),
                  Expanded(
                    child: Text(
                      'Ask Atlas About This Pop',
                      style: AtlasTypography.headingLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AtlasSpacing.sm),
              Text(
                widget.pop.number.trim().isEmpty
                    ? widget.pop.name
                    : '${widget.pop.name} #${widget.pop.number}',
                style: AtlasTypography.bodyMedium.copyWith(
                  color: AtlasColors.textSecondary,
                ),
              ),
              const SizedBox(height: AtlasSpacing.lg),
              AtlasGlassPanel(
                child: TextField(
                  controller: _questionController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitQuestion(),
                  decoration: InputDecoration(
                    labelText: 'Ask about this collectible',
                    hintText: 'What changed with this Pop?',
                    prefixIcon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                    ),
                    suffixIcon: IconButton(
                      tooltip: 'Ask Atlas',
                      onPressed: _submitQuestion,
                      icon: const Icon(
                        Icons.arrow_upward_rounded,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: AtlasSpacing.lg),
              AtlasGlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.psychology_alt_rounded,
                          color: AtlasColors.vaultGold,
                        ),
                        const SizedBox(width: AtlasSpacing.md),
                        Expanded(
                          child: Text(
                            _answer.title,
                            style: AtlasTypography.headingSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AtlasSpacing.md),
                    Text(
                      _answer.answer,
                      style: AtlasTypography.bodyMedium,
                    ),
                    const SizedBox(height: AtlasSpacing.lg),
                    Text(
                      'Atlas Tip',
                      style: AtlasTypography.bodySmall.copyWith(
                        color: AtlasColors.vaultGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AtlasSpacing.xs),
                    Text(
                      _answer.atlasTip,
                      style: AtlasTypography.bodySmall.copyWith(
                        color: AtlasColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AtlasSpacing.lg),
              Text(
                'Suggested Questions',
                style: AtlasTypography.headingSmall,
              ),
              const SizedBox(height: AtlasSpacing.sm),
              Wrap(
                spacing: AtlasSpacing.sm,
                runSpacing: AtlasSpacing.sm,
                children: _answer.suggestedQuestions
                    .map(
                      (question) => ActionChip(
                    avatar: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                    ),
                    label: Text(question),
                    onPressed: () {
                      _askSuggestedQuestion(question);
                    },
                  ),
                )
                    .toList(),
              ),
              const SizedBox(height: AtlasSpacing.lg),
              AtlasGlassPanel(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: AtlasColors.vaultGold,
                    ),
                    const SizedBox(width: AtlasSpacing.md),
                    Expanded(
                      child: Text(
                        'Atlas is answering from trusted Vault data and recorded activity. This read-only assistant cannot change your collection.',
                        style: AtlasTypography.bodySmall.copyWith(
                          color: AtlasColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}