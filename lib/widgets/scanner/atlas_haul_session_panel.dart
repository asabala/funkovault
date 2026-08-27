import 'package:flutter/material.dart';

import 'package:funkovault2/atlas/scan/ledger/atlas_scan_ledger_entry.dart';
import 'package:funkovault2/atlas/scan/results/atlas_continuous_scan_result.dart';
import 'package:funkovault2/theme/atlas_colors.dart';
import 'package:funkovault2/theme/atlas_spacing.dart';
import 'package:funkovault2/widgets/atlas/atlas_glass_card.dart';
import 'package:funkovault2/widgets/atlas/components/atlas_section_header.dart';
import 'package:funkovault2/widgets/atlas/components/atlas_status_chip.dart';

class AtlasHaulSessionPanel extends StatelessWidget {
  const AtlasHaulSessionPanel({
    super.key,
    required this.entries,
    required this.results,
    required this.activeResolutionCount,
    required this.pendingResolutionCount,
    this.onReviewHaul,
  });

  final List<AtlasScanLedgerEntry> entries;
  final List<AtlasContinuousScanResult> results;
  final int activeResolutionCount;
  final int pendingResolutionCount;
  final VoidCallback? onReviewHaul;

  @override
  Widget build(BuildContext context) {
    final List<AtlasScanLedgerEntry> orderedEntries =
        entries.toList(growable: false)..sort(
          (AtlasScanLedgerEntry a, AtlasScanLedgerEntry b) =>
              b.createdAt.compareTo(a.createdAt),
        );

    final Map<String, AtlasContinuousScanResult> resultsByTrack =
        <String, AtlasContinuousScanResult>{
          for (final AtlasContinuousScanResult result in results)
            result.trackId: result,
        };

    return AtlasGlassCard(
      padding: EdgeInsets.zero,
      accentColor: _sessionAccentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AtlasSpacing.lg,
              AtlasSpacing.lg,
              AtlasSpacing.lg,
              AtlasSpacing.md,
            ),
            child: AtlasSectionHeader(
              title: '📦 Haul Session',
              subtitle:
                  'Atlas keeps scanning while items resolve in the background.',
              icon: Icons.inventory_2_outlined,
              accentColor: _sessionAccentColor,
              trailing: AtlasStatusChip(
                label:
                    '${entries.length} item${entries.length == 1 ? '' : 's'}',
                icon: Icons.qr_code_scanner_rounded,
                accentColor: _sessionAccentColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AtlasSpacing.lg),
            child: _HaulQueueSummary(
              activeResolutionCount: activeResolutionCount,
              pendingResolutionCount: pendingResolutionCount,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          if (orderedEntries.isNotEmpty && onReviewHaul != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AtlasSpacing.lg),
              child: FilledButton.icon(
                onPressed: onReviewHaul,
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('📦 Review Haul'),
              ),
            ),
            const SizedBox(height: AtlasSpacing.md),
          ],
          if (orderedEntries.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AtlasSpacing.lg,
                0,
                AtlasSpacing.lg,
                AtlasSpacing.lg,
              ),
              child: _EmptyHaulMessage(),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(
                  AtlasSpacing.lg,
                  0,
                  AtlasSpacing.lg,
                  AtlasSpacing.lg,
                ),
                itemCount: orderedEntries.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AtlasSpacing.sm),
                itemBuilder: (BuildContext context, int index) {
                  final AtlasScanLedgerEntry entry = orderedEntries[index];

                  return _HaulItemRow(
                    entry: entry,
                    result: resultsByTrack[entry.trackId],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Color get _sessionAccentColor {
    if (activeResolutionCount > 0 || pendingResolutionCount > 0) {
      return AtlasColors.intelligenceBlue;
    }

    if (entries.any((AtlasScanLedgerEntry entry) => entry.hasFailed)) {
      return AtlasColors.danger;
    }

    if (entries.any((AtlasScanLedgerEntry entry) => entry.needsReview)) {
      return AtlasColors.warning;
    }

    if (entries.isNotEmpty) {
      return AtlasColors.success;
    }

    return AtlasColors.vaultGold;
  }
}

class _HaulQueueSummary extends StatelessWidget {
  const _HaulQueueSummary({
    required this.activeResolutionCount,
    required this.pendingResolutionCount,
  });

  final int activeResolutionCount;
  final int pendingResolutionCount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AtlasSpacing.sm,
      runSpacing: AtlasSpacing.sm,
      children: [
        AtlasStatusChip(
          label: '$activeResolutionCount resolving',
          icon: Icons.sync_rounded,
          accentColor: activeResolutionCount > 0
              ? AtlasColors.intelligenceBlue
              : AtlasColors.textSecondary,
        ),
        AtlasStatusChip(
          label: '$pendingResolutionCount queued',
          icon: Icons.schedule_rounded,
          accentColor: pendingResolutionCount > 0
              ? AtlasColors.warning
              : AtlasColors.textSecondary,
        ),
      ],
    );
  }
}

class _EmptyHaulMessage extends StatelessWidget {
  const _EmptyHaulMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AtlasSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AtlasColors.divider),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.center_focus_strong_rounded,
            color: AtlasColors.textSecondary,
          ),
          SizedBox(width: AtlasSpacing.sm),
          Expanded(
            child: Text(
              'Point the camera at collectible barcodes. '
              'Stable items will appear here without stopping the scanner.',
            ),
          ),
        ],
      ),
    );
  }
}

class _HaulItemRow extends StatelessWidget {
  const _HaulItemRow({required this.entry, required this.result});

  final AtlasScanLedgerEntry entry;
  final AtlasContinuousScanResult? result;

  @override
  Widget build(BuildContext context) {
    final _HaulItemPresentation presentation = _presentationFor(entry);

    final String? resolvedDisplayName = result
        ?.session
        .catalogProduct
        ?.displayName
        .trim();

    final String title =
        resolvedDisplayName != null && resolvedDisplayName.isNotEmpty
        ? resolvedDisplayName
        : 'Barcode ${entry.stableCode.normalizedValue}';

    final String subtitle = _subtitleFor(entry);

    return Container(
      padding: const EdgeInsets.all(AtlasSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: presentation.accentColor.withValues(alpha: 0.38),
        ),
        color: presentation.accentColor.withValues(alpha: 0.06),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(presentation.icon, color: presentation.accentColor),
          const SizedBox(width: AtlasSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AtlasColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AtlasSpacing.sm),
          AtlasStatusChip(
            label: presentation.label,
            icon: presentation.icon,
            accentColor: presentation.accentColor,
          ),
        ],
      ),
    );
  }

  String _subtitleFor(AtlasScanLedgerEntry entry) {
    if (entry.hasFailed) {
      final String failure = entry.failureMessage?.trim() ?? '';

      if (failure.isNotEmpty) {
        return failure;
      }

      return 'Atlas could not finish resolving this item.';
    }

    if (entry.needsReview) {
      return 'Resolution needs collector review before commit.';
    }

    if (entry.isResolved) {
      return 'Resolved and waiting for haul review.';
    }

    if (entry.isCommitted) {
      return 'Committed to the collection.';
    }

    if (entry.isResolving) {
      return 'Atlas is resolving this item in the background.';
    }

    if (entry.isQueued) {
      return 'Waiting for an available resolution slot.';
    }

    return 'Stable evidence captured and ready to queue.';
  }

  _HaulItemPresentation _presentationFor(AtlasScanLedgerEntry entry) {
    return switch (entry.status) {
      AtlasScanLedgerStatus.observed => const _HaulItemPresentation(
        label: 'Observed',
        icon: Icons.visibility_outlined,
        accentColor: AtlasColors.textSecondary,
      ),
      AtlasScanLedgerStatus.queued => const _HaulItemPresentation(
        label: 'Queued',
        icon: Icons.schedule_rounded,
        accentColor: AtlasColors.warning,
      ),
      AtlasScanLedgerStatus.resolving => const _HaulItemPresentation(
        label: 'Resolving',
        icon: Icons.sync_rounded,
        accentColor: AtlasColors.intelligenceBlue,
      ),
      AtlasScanLedgerStatus.resolved => const _HaulItemPresentation(
        label: 'Resolved',
        icon: Icons.check_circle_outline_rounded,
        accentColor: AtlasColors.success,
      ),
      AtlasScanLedgerStatus.needsReview => const _HaulItemPresentation(
        label: 'Review',
        icon: Icons.fact_check_outlined,
        accentColor: AtlasColors.warning,
      ),
      AtlasScanLedgerStatus.failed => const _HaulItemPresentation(
        label: 'Failed',
        icon: Icons.error_outline_rounded,
        accentColor: AtlasColors.danger,
      ),
      AtlasScanLedgerStatus.committed => const _HaulItemPresentation(
        label: 'Committed',
        icon: Icons.inventory_rounded,
        accentColor: AtlasColors.success,
      ),
    };
  }
}

class _HaulItemPresentation {
  const _HaulItemPresentation({
    required this.label,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final IconData icon;
  final Color accentColor;
}
