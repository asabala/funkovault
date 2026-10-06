import 'package:flutter/material.dart';

import '../../../atlas/hero/models/atlas_hero_summary.dart';
import '../../../models/pop.dart';
import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_card.dart';
import '../atlas/components/atlas_chip.dart';
import '../atlas/components/atlas_product_image.dart';
import 'pop_identity_badges.dart';

class AtlasProductHeroCard extends StatelessWidget {
  const AtlasProductHeroCard({
    super.key,
    required this.pop,
    required this.heroSummary,
    this.trendPercent,
    this.trendTimeframe = '30d',
  });

  final Pop pop;
  final AtlasHeroSummary heroSummary;
  final double? trendPercent;
  final String trendTimeframe;

  @override
  Widget build(BuildContext context) {
    final String numberLabel = pop.number.trim().isEmpty
        ? 'No number'
        : '#${pop.number.trim()}';
    final String seriesLabel = pop.series.trim();

    return AtlasGlassCard(
      borderRadius: 26,
      padding: const EdgeInsets.all(AtlasSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroTopRow(pop: pop),
          const SizedBox(height: AtlasSpacing.lg),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double imageWidth = (constraints.maxWidth * 0.62).clamp(
                176.0,
                222.0,
              );

              return Center(
                child: _PremiumImageFrame(
                  imageUrl: pop.imageUrl,
                  width: imageWidth,
                ),
              );
            },
          ),
          const SizedBox(height: AtlasSpacing.lg),
          Text(
            pop.name,
            style: AtlasTypography.headingLarge.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            seriesLabel.isEmpty ? numberLabel : '$numberLabel • $seriesLabel',
            style: AtlasTypography.bodyMedium.copyWith(
              color: AtlasColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          PopIdentityBadges(pop: pop, showStandardBadge: false),
          const SizedBox(height: AtlasSpacing.lg),
          _CollectibleProfile(pop: pop),
          const SizedBox(height: AtlasSpacing.lg),
          _PremiumMarketStats(
            value: pop.value,
            score: heroSummary.normalizedScore,
            classification: heroSummary.classification,
            trendPercent: trendPercent,
            trendTimeframe: trendTimeframe,
          ),
          const SizedBox(height: AtlasSpacing.md),
          _VerificationPanel(pop: pop),
        ],
      ),
    );
  }
}

class _HeroTopRow extends StatelessWidget {
  const _HeroTopRow({required this.pop});

  final Pop pop;

  @override
  Widget build(BuildContext context) {
    final _PrimaryReleaseBadge releaseBadge = _primaryReleaseBadge(pop);

    return Row(
      children: [
        Flexible(
          child: Align(
            alignment: Alignment.centerLeft,
            child: AtlasChip(
              label: releaseBadge.label,
              icon: releaseBadge.icon,
            ),
          ),
        ),
        const SizedBox(width: AtlasSpacing.sm),
        AtlasChip(
          label: pop.isWishlist ? 'Wishlist' : 'Owned: ${pop.quantity}',
          icon: pop.isWishlist
              ? Icons.favorite_rounded
              : Icons.inventory_2_rounded,
        ),
      ],
    );
  }
}

class _PremiumImageFrame extends StatelessWidget {
  const _PremiumImageFrame({required this.imageUrl, required this.width});

  final String imageUrl;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.60),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AtlasColors.vaultGold.withValues(alpha: 0.14),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AtlasColors.vaultGold.withValues(alpha: 0.14),
                AtlasColors.card,
                AtlasColors.vaultGold.withValues(alpha: 0.08),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: AtlasProductImage(
              imageUrl: imageUrl,
              width: width,
              height: width * 1.08,
            ),
          ),
        ),
      ),
    );
  }
}

class _CollectibleProfile extends StatelessWidget {
  const _CollectibleProfile({required this.pop});

  final Pop pop;

  @override
  Widget build(BuildContext context) {
    final details = <String>[
      if (_profileValue(pop.releaseDate) != null)
        _profileValue(pop.releaseDate)!,
      if (_profileValue(pop.productionStatus) != null)
        _profileValue(pop.productionStatus)!,
      if (_profileValue(pop.packagingType) != null)
        _profileValue(pop.packagingType)!,
      if (_profileValue(pop.size) != null) _profileValue(pop.size)!,
      if (_profileValue(pop.finish) != null) _profileValue(pop.finish)!,
    ];

    final uniqueDetails = <String>[];
    for (final detail in details) {
      if (!uniqueDetails.any(
        (existing) => existing.toLowerCase() == detail.toLowerCase(),
      )) {
        uniqueDetails.add(detail);
      }
    }

    if (uniqueDetails.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COLLECTIBLE PROFILE',
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.vaultGold,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.35,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          uniqueDetails.take(3).join(' • '),
          style: AtlasTypography.bodyMedium.copyWith(
            color: AtlasColors.textPrimary,
            height: 1.34,
          ),
        ),
      ],
    );
  }
}

String? _profileValue(String value) {
  final cleaned = value.trim();
  final normalized = cleaned.toLowerCase();

  if (cleaned.isEmpty ||
      normalized == 'none' ||
      normalized == 'unknown' ||
      normalized == 'not entered' ||
      normalized == 'standard') {
    return null;
  }

  return cleaned;
}

class _PremiumMarketStats extends StatelessWidget {
  const _PremiumMarketStats({
    required this.value,
    required this.score,
    required this.classification,
    required this.trendPercent,
    required this.trendTimeframe,
  });

  final double value;
  final int score;
  final String classification;
  final double? trendPercent;
  final String trendTimeframe;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double gap = AtlasSpacing.sm;
        final double panelWidth = (constraints.maxWidth - gap) / 2;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: panelWidth,
              child: _MetricShell(
                child: _ValueMetric(
                  value: value,
                  trendPercent: trendPercent,
                  trendTimeframe: trendTimeframe,
                ),
              ),
            ),
            const SizedBox(width: gap),
            SizedBox(
              width: panelWidth,
              child: _MetricShell(
                child: _ScoreMetric(
                  score: score,
                  classification: classification,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricShell extends StatelessWidget {
  const _MetricShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 126),
      padding: const EdgeInsets.all(AtlasSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.42),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AtlasColors.card, AtlasColors.background],
        ),
      ),
      child: child,
    );
  }
}

class _ValueMetric extends StatelessWidget {
  const _ValueMetric({
    required this.value,
    required this.trendPercent,
    required this.trendTimeframe,
  });

  final double value;
  final double? trendPercent;
  final String trendTimeframe;

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.attach_money_rounded,
              size: 17,
              color: AtlasColors.vaultGold,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'CURRENT VALUE',
                  maxLines: 1,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AtlasSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                hasValue ? '\$${value.toStringAsFixed(2)}' : '—',
                style: AtlasTypography.headingLarge.copyWith(
                  color: AtlasColors.vaultGold,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Icon(
              Icons.show_chart_rounded,
              color: AtlasColors.vaultGold,
              size: 32,
            ),
          ],
        ),
        const SizedBox(height: AtlasSpacing.sm),
        Text(
          _trendLabel(trendPercent, trendTimeframe),
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ScoreMetric extends StatelessWidget {
  const _ScoreMetric({required this.score, required this.classification});

  final int score;
  final String classification;

  @override
  Widget build(BuildContext context) {
    final double progress = (score.clamp(0, 100)) / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.insights_rounded,
              size: 17,
              color: AtlasColors.vaultGold,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'COLLECTOR SCORE',
                  maxLines: 1,
                  style: AtlasTypography.bodySmall.copyWith(
                    color: AtlasColors.textSecondary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AtlasSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Text(
                '$score / 100',
                style: AtlasTypography.headingLarge.copyWith(
                  color: AtlasColors.vaultGold,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(
              width: 46,
              height: 46,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 7,
                    color: AtlasColors.border,
                  ),
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 7,
                    color: AtlasColors.vaultGold,
                    backgroundColor: Colors.transparent,
                    strokeCap: StrokeCap.round,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AtlasSpacing.sm),
        Text(
          classification,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AtlasTypography.bodySmall.copyWith(
            color: AtlasColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _VerificationPanel extends StatelessWidget {
  const _VerificationPanel({required this.pop});

  final Pop pop;

  @override
  Widget build(BuildContext context) {
    final bool hasCatalogIdentity =
        pop.sourceCatalogId.trim().isNotEmpty ||
        pop.sourceCollectibleId.trim().isNotEmpty ||
        pop.sourceUpc.trim().isNotEmpty;
    final bool hasAuthentication =
        pop.authenticationProvider.trim().isNotEmpty ||
        pop.authenticityNumber.trim().isNotEmpty;
    final bool hasCondition =
        !_isMissingDetail(pop.itemCondition) ||
        !_isMissingDetail(pop.boxCondition);

    return Container(
      padding: const EdgeInsets.all(AtlasSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AtlasColors.vaultGold.withValues(alpha: 0.44),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AtlasColors.card, AtlasColors.background],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AtlasColors.vaultGold.withValues(alpha: 0.13),
                  border: Border.all(
                    color: AtlasColors.vaultGold.withValues(alpha: 0.40),
                  ),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: AtlasColors.vaultGold,
                  size: 31,
                ),
              ),
              const SizedBox(width: AtlasSpacing.md),
              Expanded(
                child: Text(
                  'VERIFICATION & AUTHENTICITY',
                  style: AtlasTypography.bodyMedium.copyWith(
                    color: AtlasColors.textSecondary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.md),
          _VerificationRow(
            passed: hasCatalogIdentity,
            text: hasCatalogIdentity
                ? 'Catalog identity linked'
                : 'Catalog identity not linked',
          ),
          const SizedBox(height: 5),
          _VerificationRow(
            passed: hasCondition,
            text: hasCondition ? _conditionText(pop) : 'Condition not recorded',
          ),
          const SizedBox(height: 5),
          _VerificationRow(
            passed: hasAuthentication,
            text: hasAuthentication
                ? _authenticationText(pop)
                : 'Authentication not recorded',
          ),
          if (_catalogSerial(pop).isNotEmpty) ...[
            const SizedBox(height: AtlasSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'SER. #: ${_catalogSerial(pop)}',
                style: AtlasTypography.bodySmall.copyWith(
                  color: AtlasColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VerificationRow extends StatelessWidget {
  const _VerificationRow({required this.passed, required this.text});

  final bool passed;
  final String text;

  @override
  Widget build(BuildContext context) {
    final Color color = passed ? AtlasColors.success : AtlasColors.warning;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          passed ? Icons.check_circle_rounded : Icons.info_outline_rounded,
          size: 17,
          color: color,
        ),
        const SizedBox(width: AtlasSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

_PrimaryReleaseBadge _primaryReleaseBadge(Pop pop) {
  final List<_PrimaryReleaseBadge> candidates = [
    _PrimaryReleaseBadge(pop.variant.trim(), Icons.auto_awesome_rounded),
    _PrimaryReleaseBadge(
      pop.eventSticker.trim(),
      Icons.local_activity_outlined,
    ),
    _PrimaryReleaseBadge(pop.retailExclusive.trim(), Icons.storefront_outlined),
    _PrimaryReleaseBadge(pop.limitedEdition.trim(), Icons.numbers_rounded),
  ];

  for (final _PrimaryReleaseBadge candidate in candidates) {
    if (_isMeaningfulIdentityValue(candidate.label)) {
      return candidate;
    }
  }

  return const _PrimaryReleaseBadge(
    'Standard Release',
    Icons.inventory_2_outlined,
  );
}

String _trendLabel(double? trendPercent, String timeframe) {
  if (trendPercent == null) {
    return 'Current (No trend yet)';
  }

  final String direction = trendPercent > 0 ? '+' : '';
  return '$direction${trendPercent.toStringAsFixed(1)}% ($timeframe)';
}

String _conditionText(Pop pop) {
  final String item = pop.itemCondition.trim();
  final String box = pop.boxCondition.trim();

  if (!_isMissingDetail(box) && !_isMissingDetail(item)) {
    return 'Condition: Box $box • Item $item';
  }

  if (!_isMissingDetail(box)) {
    return 'Box condition: $box';
  }

  return 'Item condition: $item';
}

String _authenticationText(Pop pop) {
  final String provider = pop.authenticationProvider.trim();
  final String number = pop.authenticityNumber.trim();

  if (provider.isNotEmpty && number.isNotEmpty) {
    return 'Authentication: $provider • $number';
  }

  if (provider.isNotEmpty) {
    return 'Authentication: $provider';
  }

  return 'Authentication #: $number';
}

String _catalogSerial(Pop pop) {
  if (pop.sourceCollectibleId.trim().isNotEmpty) {
    return pop.sourceCollectibleId.trim();
  }
  if (pop.sourceCatalogId.trim().isNotEmpty) {
    return pop.sourceCatalogId.trim();
  }
  return pop.authenticityNumber.trim();
}

bool _isMeaningfulIdentityValue(String value) {
  final String normalized = value.trim().toLowerCase();

  if (normalized.isEmpty) {
    return false;
  }

  return normalized != 'none' &&
      normalized != 'common' &&
      normalized != 'standard' &&
      normalized != 'unsigned' &&
      normalized != 'not entered';
}

bool _isMissingDetail(String value) {
  final String normalized = value.trim().toLowerCase();

  return normalized.isEmpty ||
      normalized == 'none' ||
      normalized == 'not entered' ||
      normalized == 'unknown';
}

class _PrimaryReleaseBadge {
  const _PrimaryReleaseBadge(this.label, this.icon);

  final String label;
  final IconData icon;
}
