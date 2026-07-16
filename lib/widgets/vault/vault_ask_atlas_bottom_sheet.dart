import 'package:flutter/material.dart';

import '../../atlas/coordinator/atlas_dashboard_model.dart';
import '../../atlas/engines/vault_context_explainer_engine.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_panel.dart';

class VaultNavigationRequest {
  const VaultNavigationRequest({
    this.filterKey,
    this.searchQuery,
    this.minimumValue,
    this.maximumValue,
    this.sortKey,
  });

  final String? filterKey;
  final String? searchQuery;
  final double? minimumValue;
  final double? maximumValue;
  final String? sortKey;

  bool get hasFilter =>
      filterKey != null && filterKey!.trim().isNotEmpty;

  bool get hasSearch =>
      searchQuery != null && searchQuery!.trim().isNotEmpty;

  bool get hasValueRange =>
      minimumValue != null || maximumValue != null;

  bool get hasSort =>
      sortKey != null && sortKey!.trim().isNotEmpty;

  bool get hasNavigationDetails =>
      hasFilter || hasSearch || hasValueRange || hasSort;
}

class VaultAskAtlasBottomSheet {
  const VaultAskAtlasBottomSheet._();

  static void show({
    required BuildContext context,
    required AtlasDashboardModel dashboard,
    required VaultContextExplainerEngine explainerEngine,
    String initialQuestion = 'What should I clean up first?',
    ValueChanged<String>? onOpenVaultFilter,
    ValueChanged<String>? onOpenVaultSearch,
    ValueChanged<VaultNavigationRequest>? onOpenVaultRequest,
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
          onOpenVaultSearch: onOpenVaultSearch,
          onOpenVaultRequest: onOpenVaultRequest,
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
    required this.onOpenVaultSearch,
    required this.onOpenVaultRequest,
  });

  final AtlasDashboardModel dashboard;
  final VaultContextExplainerEngine explainerEngine;
  final String initialQuestion;
  final ValueChanged<String>? onOpenVaultFilter;
  final ValueChanged<String>? onOpenVaultSearch;
  final ValueChanged<VaultNavigationRequest>? onOpenVaultRequest;

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

  VaultNavigationRequest _buildNavigationRequest() {
    return VaultNavigationRequest(
      filterKey: _answer.vaultFilterKey,
      searchQuery: _answer.vaultSearchQuery,
      minimumValue: _answer.minimumValue,
      maximumValue: _answer.maximumValue,
      sortKey: _answer.vaultSortKey,
    );
  }

  void _openVaultAction() {
    final request = _buildNavigationRequest();

    if (!request.hasNavigationDetails) {
      return;
    }

    final onOpenVaultRequest = widget.onOpenVaultRequest;

    if (onOpenVaultRequest != null) {
      Navigator.of(context).pop();
      onOpenVaultRequest(request);
      return;
    }

    if (request.hasFilter) {
      final onOpenVaultFilter = widget.onOpenVaultFilter;

      if (onOpenVaultFilter == null) {
        return;
      }

      Navigator.of(context).pop();
      onOpenVaultFilter(request.filterKey!);
      return;
    }

    if (request.hasSearch) {
      final onOpenVaultSearch = widget.onOpenVaultSearch;

      if (onOpenVaultSearch == null) {
        return;
      }

      Navigator.of(context).pop();
      onOpenVaultSearch(request.searchQuery!);
    }
  }

  bool get _canOpenVaultAction {
    final request = _buildNavigationRequest();

    if (!request.hasNavigationDetails) {
      return false;
    }

    if (widget.onOpenVaultRequest != null) {
      return true;
    }

    if (request.hasFilter && widget.onOpenVaultFilter != null) {
      return true;
    }

    if (request.hasSearch && widget.onOpenVaultSearch != null) {
      return true;
    }

    return false;
  }

  IconData get _actionIcon {
    if (_answer.hasVaultValueAction) {
      return Icons.attach_money_rounded;
    }

    if (_answer.hasVaultSearchAction) {
      return Icons.search_rounded;
    }

    if (_answer.hasVaultSortAction) {
      return Icons.sort_rounded;
    }

    return Icons.open_in_new_rounded;
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
                    if (_canOpenVaultAction) ...[
                      const SizedBox(height: AtlasSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _openVaultAction,
                          icon: Icon(_actionIcon),
                          label: Text(
                            _answer.actionLabel ?? 'Open Entire Vault',
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