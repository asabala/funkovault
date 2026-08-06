import 'package:flutter/material.dart';

import 'package:funkovault2/atlas/completion/models/atlas_completion_result.dart';
import 'package:funkovault2/theme/atlas_colors.dart';
import 'package:funkovault2/theme/atlas_spacing.dart';
import 'package:funkovault2/theme/atlas_symbols.dart';
import 'package:funkovault2/theme/atlas_typography.dart';

enum AtlasCompletionPreviewState {
  idle,
  loading,
  loaded,
  error,
}

class AtlasCompletionPreviewCard extends StatelessWidget {
  const AtlasCompletionPreviewCard({
    super.key,
    required this.state,
    this.result,
    this.isExpanded = false,
    this.onTap,
    this.errorMessage,
  });

  final AtlasCompletionPreviewState state;

  final AtlasCompletionResult? result;

  final bool isExpanded;

  final VoidCallback? onTap;

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(
        16,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          16,
        ),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: const EdgeInsets.all(
            AtlasSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              16,
            ),
            color: AtlasColors.intelligenceBlue.withValues(
              alpha: 0.07,
            ),
            border: Border.all(
              color: _accentColor.withValues(
                alpha: 0.24,
              ),
            ),
          ),
          child: AnimatedSize(
            duration: const Duration(
              milliseconds: 220,
            ),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return switch (state) {
      AtlasCompletionPreviewState.idle =>
          _buildIdleContent(),
      AtlasCompletionPreviewState.loading =>
          _buildLoadingContent(),
      AtlasCompletionPreviewState.loaded =>
          _buildLoadedContent(),
      AtlasCompletionPreviewState.error =>
          _buildErrorContent(),
    };
  }

  Widget _buildIdleContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PreviewHeader(
          symbol: AtlasSymbols.completion,
          title: 'Collector Progress',
          trailingIcon: Icons.expand_more_rounded,
        ),
        const SizedBox(
          height: AtlasSpacing.xs,
        ),
        Text(
          'View related releases and completion.',
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingContent() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PreviewHeader(
          symbol: AtlasSymbols.completion,
          title: 'Collector Progress',
          trailingWidget: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
        SizedBox(
          height: AtlasSpacing.sm,
        ),
        Text(
          'Calculating collection progress...',
          style: AtlasTypography.bodySmall,
        ),
        SizedBox(
          height: AtlasSpacing.md,
        ),
        LinearProgressIndicator(
          minHeight: 6,
          backgroundColor: AtlasColors.surface,
        ),
      ],
    );
  }

  Widget _buildLoadedContent() {
    final AtlasCompletionResult? completionResult =
        result;

    if (completionResult == null) {
      return _buildErrorContent();
    }

    final double progress =
    completionResult.totalReleaseCount == 0
        ? 0
        : (completionResult.completionPercent / 100).clamp(
      0,
      1,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PreviewHeader(
          symbol: AtlasSymbols.completion,
          title: 'Collector Progress',
          trailingIcon: isExpanded
              ? Icons.expand_less_rounded
              : Icons.expand_more_rounded,
        ),
        const SizedBox(
          height: AtlasSpacing.sm,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                completionResult.formattedProgress,
                style: AtlasTypography.headingSmall,
              ),
            ),
            Text(
              completionResult.formattedCompletion,
              style: AtlasTypography.headingSmall.copyWith(
                color: _accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: AtlasSpacing.xs,
        ),
        Text(
          completionResult.totalReleaseCount == 1
              ? 'release owned'
              : 'releases owned',
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.textSecondary,
          ),
        ),
        const SizedBox(
          height: AtlasSpacing.sm,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(
            999,
          ),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: AtlasColors.surface,
            valueColor: AlwaysStoppedAnimation<Color>(
              _accentColor,
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(
            height: AtlasSpacing.md,
          ),
          Wrap(
            spacing: AtlasSpacing.sm,
            runSpacing: AtlasSpacing.sm,
            children: [
              _PreviewMetric(
                symbol: AtlasSymbols.owned,
                label:
                '${completionResult.ownedReleaseCount} Owned',
              ),
              _PreviewMetric(
                symbol: AtlasSymbols.wishlist,
                label:
                '${completionResult.wishlistReleaseCount} Wishlist',
              ),
              _PreviewMetric(
                symbol: AtlasSymbols.missing,
                label:
                '${completionResult.missingReleaseCount} Missing',
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildErrorContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PreviewHeader(
          symbol: AtlasSymbols.reviewVariant,
          title: 'Collector Progress',
          trailingIcon: Icons.refresh_rounded,
        ),
        const SizedBox(
          height: AtlasSpacing.xs,
        ),
        Text(
          errorMessage?.trim().isNotEmpty == true
              ? errorMessage!.trim()
              : 'Unable to calculate progress. Tap to retry.',
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color get _accentColor {
    final AtlasCompletionResult? completionResult =
        result;

    if (state == AtlasCompletionPreviewState.error) {
      return AtlasColors.warning;
    }

    if (completionResult?.isComplete == true) {
      return AtlasColors.success;
    }

    if ((completionResult?.completionPercent ?? 0) >= 75) {
      return AtlasColors.vaultGold;
    }

    return AtlasColors.intelligenceBlue;
  }
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({
    required this.symbol,
    required this.title,
    this.trailingIcon,
    this.trailingWidget,
  });

  final String symbol;

  final String title;

  final IconData? trailingIcon;

  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          symbol,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        const SizedBox(
          width: AtlasSpacing.sm,
        ),
        Expanded(
          child: Text(
            title,
            style: AtlasTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (trailingWidget != null)
          trailingWidget!
        else if (trailingIcon != null)
          Icon(
            trailingIcon,
            size: 21,
            color: AtlasColors.textSecondary,
          ),
      ],
    );
  }
}

class _PreviewMetric extends StatelessWidget {
  const _PreviewMetric({
    required this.symbol,
    required this.label,
  });

  final String symbol;

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          999,
        ),
        color: AtlasColors.surface.withValues(
          alpha: 0.60,
        ),
        border: Border.all(
          color: AtlasColors.border.withValues(
            alpha: 0.70,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            symbol,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            label,
            style: AtlasTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}