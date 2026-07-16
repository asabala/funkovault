import 'package:flutter/material.dart';

import '../../atlas/coordinator/atlas_dashboard_model.dart';
import '../../atlas/engines/vault_context_explainer_engine.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_panel.dart';

class VaultAskAtlasBottomSheet {
  const VaultAskAtlasBottomSheet._();

  static void show({
    required BuildContext context,
    required AtlasDashboardModel dashboard,
    required VaultContextExplainerEngine explainerEngine,
    String initialQuestion = 'What should I clean up first?',
    ValueChanged<String>? onOpenVaultFilter,
  }) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (_) {
        return _VaultAskAtlasSheet(
          dashboard: dashboard,
          explainerEngine: explainerEngine,
          initialQuestion: initialQuestion,
          onOpenVaultFilter: onOpenVaultFilter,
        );
      },
    );
  }
}

class _VaultAskAtlasSheet extends StatefulWidget {
  const _VaultAskAtlasSheet({
    required this.dashboard,
    required this.explainerEngine,
    required this.initialQuestion,
    required this.onOpenVaultFilter,
  });

  final AtlasDashboardModel dashboard;
  final VaultContextExplainerEngine explainerEngine;
  final String initialQuestion;
  final ValueChanged<String>? onOpenVaultFilter;

  @override
  State<_VaultAskAtlasSheet> createState() => _VaultAskAtlasSheetState();
}

class _VaultAskAtlasSheetState extends State<_VaultAskAtlasSheet> {
  late final TextEditingController _questionController;
  late VaultContextAnswer _answer;

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

  VaultContextAnswer _buildAnswer(String question) {
    return widget.explainerEngine.explain(
      question: question,
      dashboard: widget.dashboard,
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

  void _openVaultAction() {
    final filterKey = _answer.vaultFilterKey;

    if (filterKey == null || filterKey.trim().isEmpty) {
      return;
    }

    final onOpenVaultFilter = widget.onOpenVaultFilter;

    if (onOpenVaultFilter == null) {
      return;
    }

    Navigator.of(context).pop();
    onOpenVaultFilter(filterKey);
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
                      'Ask Atlas About My Vault',
                      style: AtlasTypography.headingLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AtlasSpacing.sm),
              Text(
                'Trusted answers from your current Vault data',
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
                    labelText: 'Ask about your Vault',
                    hintText: 'What should I clean up first?',
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
                    if (_answer.hasVaultAction &&
                        widget.onOpenVaultFilter != null) ...[
                      const SizedBox(height: AtlasSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _openVaultAction,
                          icon: const Icon(
                            Icons.open_in_new_rounded,
                          ),
                          label: Text(
                            _answer.actionLabel!,
                          ),
                        ),
                      ),
                    ],
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
                        'Atlas is answering from trusted Vault metrics and existing collection engines. This read-only assistant cannot change your Vault.',
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