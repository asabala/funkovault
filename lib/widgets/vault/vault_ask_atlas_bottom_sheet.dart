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
  void _clearQuestion() {
    _questionController.clear();

    setState(() {});
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
  bool get _hasUnsupportedDetails {
    return _answer.hasUnsupportedParts;
  }

  String get _supportedAnswerText {
    if (!_hasUnsupportedDetails) {
      return _answer.answer.trim();
    }

    if (!_answer.hasVaultAction) {
      return '';
    }

    return _answer.answer.trim();
  }

  String? get _previewMatchText {
    final count = _answer.previewMatchCount;

    if (count == null) {
      return null;
    }

    if (count == 1) {
      return '1 collectible matches this request.';
    }

    return '$count collectibles match this request.';
  }

  String? get _friendlyUnsupportedAnswerText {
    if (_answer.unsupportedParts.isEmpty) {
      return null;
    }

    return _answer.unsupportedParts.map((part) {
      final formatted = part.isEmpty
          ? part
          : part[0].toUpperCase() + part.substring(1);

      return '$formatted is not supported yet.';
    }).join('\n');
  }

  List<String> get _unsupportedSuggestionQuestions {
    final unsupportedParts = _answer.unsupportedParts
        .map((part) => part.toLowerCase())
        .toSet();

    final suggestions = <String>[];

    void addSuggestions(List<String> values) {
      for (final value in values) {
        if (!suggestions.contains(value)) {
          suggestions.add(value);
        }
      }
    }

    if (unsupportedParts.contains('value-history filtering')) {
      addSuggestions(
        const [
          'Show my most valuable Pops',
          'Show Pops over \$50',
          'Show Pops between \$25 and \$100',
        ],
      );
    }

    if (unsupportedParts.contains('release-year filtering')) {
      addSuggestions(
        const [
          'Find my Stitch Pops',
          'Show my exclusives',
          'Show my variants',
        ],
      );
    }

    if (unsupportedParts.contains('condition filtering')) {
      addSuggestions(
        const [
          'Show Pops that need values',
          'Show my signed Pops',
          'Show my limited Pops',
        ],
      );
    }

    if (unsupportedParts.contains('price-paid filtering')) {
      addSuggestions(
        const [
          'Show Pops over \$50',
          'Show my most valuable Pops',
          'Show Pops that need values',
        ],
      );
    }

    return suggestions.take(3).toList();
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
                  onChanged: (_) {
                    setState(() {});
                  },
                  onSubmitted: (_) => _submitQuestion(),
                  decoration: InputDecoration(
                    labelText: 'Ask about your Vault',
                    hintText: 'What should I clean up first?',
                    prefixIcon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_questionController.text.isNotEmpty)
                          IconButton(
                            tooltip: 'Clear question',
                            onPressed: _clearQuestion,
                            icon: const Icon(
                              Icons.clear_rounded,
                            ),
                          ),
                        IconButton(
                          tooltip: 'Ask Atlas',
                          onPressed: _submitQuestion,
                          icon: const Icon(
                            Icons.arrow_upward_rounded,
                          ),
                        ),
                      ],
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
                    if (_supportedAnswerText.isNotEmpty)
                      Text(
                        _supportedAnswerText,
                        style: AtlasTypography.bodyMedium.copyWith(
                          color: AtlasColors.textPrimary,
                        ),
                      ),

                    if (_previewMatchText != null) ...[
                      const SizedBox(height: 12),
                      _VaultQueryPreviewPanel(
                        message: _previewMatchText!,
                        totalValue: _answer.previewTotalValue,
                        highestValue: _answer.previewHighestValue,
                        averageValue: _answer.previewAverageValue,
                        ownedCount: _answer.previewOwnedCount,
                        wishlistCount: _answer.previewWishlistCount,
                        missingValueCount: _answer.previewMissingValueCount,
                      ),
                    ],
                    if (_friendlyUnsupportedAnswerText != null) ...[
                      if (_supportedAnswerText.isNotEmpty)
                        const SizedBox(height: AtlasSpacing.md),
                      _UnsupportedRequestPanel(
                        message: _friendlyUnsupportedAnswerText!,
                        isPartial: _answer.hasVaultAction,
                        suggestionQuestions:
                        _unsupportedSuggestionQuestions,
                        onAskQuestion: _askSuggestedQuestion,
                      ),
                    ],
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
class _UnsupportedRequestPanel extends StatelessWidget {
  const _UnsupportedRequestPanel({
    required this.message,
    required this.isPartial,
    required this.suggestionQuestions,
    required this.onAskQuestion,
  });

  final String message;
  final bool isPartial;
  final List<String> suggestionQuestions;
  final ValueChanged<String> onAskQuestion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AtlasSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withValues(
            alpha: 0.45,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber,
          ),
          const SizedBox(width: AtlasSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPartial
                      ? 'Some request details were not applied'
                      : 'This request is not supported yet',
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.xs),
                Text(
                  message,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.md),
                Text(
                  'Try asking:',
                  style: AtlasTypography.bodySmall.copyWith(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AtlasSpacing.sm),
                Wrap(
                  spacing: AtlasSpacing.sm,
                  runSpacing: AtlasSpacing.sm,
                  children: suggestionQuestions
                      .map(
                        (question) => ActionChip(
                      avatar: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 16,
                      ),
                      label: Text(question),
                      onPressed: () {
                        onAskQuestion(question);
                      },
                    ),
                  )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _VaultQueryPreviewPanel extends StatelessWidget {
  const _VaultQueryPreviewPanel({
    required this.message,
    required this.totalValue,
    required this.highestValue,
    required this.averageValue,
    required this.ownedCount,
    required this.wishlistCount,
    required this.missingValueCount,
  });

  final String message;

  final double? totalValue;
  final double? highestValue;
  final double? averageValue;

  final int? ownedCount;
  final int? wishlistCount;
  final int? missingValueCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final summaryItems = <String>[];

    if (ownedCount != null && ownedCount! > 0) {
      summaryItems.add(
        ownedCount == 1
            ? '1 owned collectible'
            : '$ownedCount owned collectibles',
      );
    }

    if (wishlistCount != null && wishlistCount! > 0) {
      summaryItems.add(
        wishlistCount == 1
            ? '1 wishlist collectible'
            : '$wishlistCount wishlist collectibles',
      );
    }

    if (totalValue != null && totalValue! > 0) {
      summaryItems.add(
        'Total value: \$${totalValue!.toStringAsFixed(2)}',
      );
    }

    if (highestValue != null && highestValue! > 0) {
      summaryItems.add(
        'Highest value: \$${highestValue!.toStringAsFixed(2)}',
      );
    }

    if (averageValue != null && averageValue! > 0) {
      summaryItems.add(
        'Average value: \$${averageValue!.toStringAsFixed(2)}',
      );
    }

    if (missingValueCount != null && missingValueCount! > 0) {
      summaryItems.add(
        missingValueCount == 1
            ? '1 collectible needs a value'
            : '$missingValueCount collectibles need values',
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.primary.withValues(
          alpha: 0.08,
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(
            alpha: 0.22,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.manage_search_rounded,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (summaryItems.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...summaryItems.map(
                        (item) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 4,
                      ),
                      child: Text(
                        '• $item',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}