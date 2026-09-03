import 'package:flutter/material.dart';

import '../../atlas/scan/authenticity/models/atlas_authenticity_assessment.dart';
import '../../atlas/scan/authenticity/models/atlas_visual_inspection.dart';
import '../../atlas/scan/models/scan_session.dart';
import '../../atlas/scan/results/scan_variant_status.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../atlas/atlas_glass_card.dart';
import '../atlas/atlas_glass_panel.dart';
import '../atlas/components/atlas_section_header.dart';
import '../atlas/components/atlas_status_chip.dart';

class AtlasInspectionIntelligenceDashboard extends StatelessWidget {
  const AtlasInspectionIntelligenceDashboard({
    super.key,
    required this.session,
    required this.inspection,
  });

  final ScanSession session;
  final AtlasVisualInspection inspection;

  @override
  Widget build(BuildContext context) {
    final AtlasAuthenticityAssessment? assessment =
        session.authenticityContribution?.assessment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EvidenceConfidenceCard(
          value:
              assessment?.evidenceConfidence ??
              inspection.resolvedEvidenceConfidence,
          hasAssessment: assessment != null,
        ),
        const SizedBox(height: AtlasSpacing.md),
        _ReferenceCoverageCard(assessment: assessment),
        const SizedBox(height: AtlasSpacing.md),
        _AuthenticityConcernCard(assessment: assessment),
        const SizedBox(height: AtlasSpacing.md),
        _VariantConfirmationCard(resolution: session.variantResolution),
        const SizedBox(height: AtlasSpacing.md),
        _AutographCoaEvidenceCard(inspection: inspection),
      ],
    );
  }
}

class _EvidenceConfidenceCard extends StatelessWidget {
  const _EvidenceConfidenceCard({
    required this.value,
    required this.hasAssessment,
  });

  final double value;
  final bool hasAssessment;

  @override
  Widget build(BuildContext context) {
    final int percent = (value * 100).round().clamp(0, 100).toInt();
    final String label = !hasAssessment
        ? 'Draft evidence'
        : value >= 0.80
        ? 'Clear evidence'
        : value >= 0.55
        ? 'Usable evidence'
        : value >= 0.40
        ? 'Limited evidence'
        : 'Insufficient evidence';

    return _MetricCard(
      title: '📷 Evidence Confidence',
      subtitle: 'How clearly Atlas can observe the evidence you supplied.',
      icon: Icons.center_focus_strong_rounded,
      accentColor: AtlasColors.intelligenceBlue,
      value: '$percent%',
      statusLabel: label,
      progress: value,
    );
  }
}

class _ReferenceCoverageCard extends StatelessWidget {
  const _ReferenceCoverageCard({required this.assessment});

  final AtlasAuthenticityAssessment? assessment;

  @override
  Widget build(BuildContext context) {
    final double? value = assessment?.referenceCoverage;
    final int percent = value == null
        ? 0
        : (value * 100).round().clamp(0, 100).toInt();
    final String label = value == null
        ? 'Run preview'
        : value >= 0.75
        ? 'Strong reference coverage'
        : value >= 0.50
        ? 'Useful reference coverage'
        : 'Limited reference coverage';

    return _MetricCard(
      title: '📚 Reference Coverage',
      subtitle:
          'How complete and trustworthy the comparison reference is for this item.',
      icon: Icons.menu_book_rounded,
      accentColor: AtlasColors.vaultGold,
      value: value == null ? '—' : '$percent%',
      statusLabel: label,
      progress: value,
    );
  }
}

class _AuthenticityConcernCard extends StatelessWidget {
  const _AuthenticityConcernCard({required this.assessment});

  final AtlasAuthenticityAssessment? assessment;

  @override
  Widget build(BuildContext context) {
    if (assessment == null) {
      return const _MetricCard(
        title: '🛡️ Authenticity Concern',
        subtitle:
            'Atlas reports warning signals and inconsistencies, never a definitive authentic/fake verdict.',
        icon: Icons.shield_outlined,
        accentColor: AtlasColors.textSecondary,
        value: '—',
        statusLabel: 'Run preview',
      );
    }

    final _ConcernPresentation presentation = _concernPresentation(
      assessment!.concernLevel,
    );
    final int percent = (assessment!.aggregatedConcernScore * 100)
        .round()
        .clamp(0, 100)
        .toInt();

    return _MetricCard(
      title: '🛡️ Authenticity Concern',
      subtitle: assessment!.summary,
      icon: Icons.shield_outlined,
      accentColor: presentation.color,
      value: '$percent%',
      statusLabel: presentation.label,
      progress: assessment!.aggregatedConcernScore,
    );
  }
}

class _VariantConfirmationCard extends StatelessWidget {
  const _VariantConfirmationCard({required this.resolution});

  final ScanVariantResolution? resolution;

  @override
  Widget build(BuildContext context) {
    final _VariantPresentation presentation = _variantPresentation(resolution);

    return AtlasGlassCard(
      accentColor: presentation.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtlasSectionHeader(
            title: '🧩 Variant Confirmation',
            subtitle:
                'Visual evidence may recommend review, but it never silently rewrites the catalog-resolved identity.',
            icon: Icons.extension_rounded,
            accentColor: presentation.color,
            trailing: AtlasStatusChip(
              label: presentation.label,
              icon: presentation.icon,
              accentColor: presentation.color,
            ),
          ),
          if (resolution != null) ...[
            const SizedBox(height: AtlasSpacing.md),
            AtlasGlassPanel(
              accentColor: presentation.color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(resolution!.confidence * 100).round().clamp(0, 100)}% variant confidence',
                    style: AtlasTypography.metricSmall,
                  ),
                  if (resolution!.confirmedTraits.isNotEmpty) ...[
                    const SizedBox(height: AtlasSpacing.sm),
                    Text(
                      'Confirmed: ${resolution!.confirmedTraits.join(', ')}',
                      style: AtlasTypography.bodySmall,
                    ),
                  ],
                  if (resolution!.unconfirmedTraits.isNotEmpty) ...[
                    const SizedBox(height: AtlasSpacing.xs),
                    Text(
                      'Needs review: ${resolution!.unconfirmedTraits.join(', ')}',
                      style: AtlasTypography.bodySmall.copyWith(
                        color: AtlasColors.warning,
                      ),
                    ),
                  ],
                  if (resolution!.candidateProductIds.length > 1) ...[
                    const SizedBox(height: AtlasSpacing.xs),
                    Text(
                      '${resolution!.candidateProductIds.length} catalog candidates remain.',
                      style: AtlasTypography.bodySmall,
                    ),
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

class _AutographCoaEvidenceCard extends StatelessWidget {
  const _AutographCoaEvidenceCard({required this.inspection});

  final AtlasVisualInspection inspection;

  @override
  Widget build(BuildContext context) {
    final bool autographObserved =
        inspection.hasAutograph == true ||
        inspection.signature.trim().isNotEmpty;
    final bool coaObserved =
        inspection.hasCoa == true ||
        inspection.authenticationProvider.trim().isNotEmpty ||
        inspection.authenticityNumber.trim().isNotEmpty ||
        inspection.certificationText.trim().isNotEmpty;
    final bool hasAnyEvidence = autographObserved || coaObserved;

    final Color color = hasAnyEvidence
        ? AtlasColors.intelligenceBlue
        : AtlasColors.textSecondary;

    return AtlasGlassCard(
      accentColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtlasSectionHeader(
            title: '✍️ Autograph / 📜 COA Evidence',
            subtitle:
                'Observed documentation is recorded separately from external provider verification.',
            icon: Icons.draw_outlined,
            accentColor: color,
            trailing: AtlasStatusChip(
              label: hasAnyEvidence ? 'Observed' : 'Not inspected',
              icon: hasAnyEvidence
                  ? Icons.visibility_outlined
                  : Icons.remove_red_eye_outlined,
              accentColor: color,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          AtlasGlassPanel(
            accentColor: color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EvidenceRow(
                  label: 'Autograph',
                  value: autographObserved
                      ? (inspection.signature.trim().isEmpty
                            ? 'Present / observed'
                            : inspection.signature.trim())
                      : inspection.hasAutograph == false
                      ? 'Marked not present'
                      : 'Not inspected',
                ),
                const SizedBox(height: AtlasSpacing.sm),
                _EvidenceRow(
                  label: 'COA',
                  value: coaObserved
                      ? 'Documentation observed'
                      : inspection.hasCoa == false
                      ? 'Marked not present'
                      : 'Not inspected',
                ),
                if (inspection.authenticationProvider.trim().isNotEmpty) ...[
                  const SizedBox(height: AtlasSpacing.sm),
                  _EvidenceRow(
                    label: 'Provider',
                    value: inspection.authenticationProvider.trim(),
                  ),
                ],
                if (inspection.authenticityNumber.trim().isNotEmpty) ...[
                  const SizedBox(height: AtlasSpacing.sm),
                  _EvidenceRow(
                    label: 'Certificate',
                    value: inspection.authenticityNumber.trim(),
                  ),
                ],
                if (hasAnyEvidence) ...[
                  const SizedBox(height: AtlasSpacing.md),
                  Text(
                    'Provider verification: not performed by Atlas in Scanner 5.',
                    style: AtlasTypography.bodySmall.copyWith(
                      color: AtlasColors.textSecondary,
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.value,
    required this.statusLabel,
    this.progress,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String value;
  final String statusLabel;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtlasSectionHeader(
            title: title,
            subtitle: subtitle,
            icon: icon,
            accentColor: accentColor,
            trailing: AtlasStatusChip(
              label: statusLabel,
              icon: icon,
              accentColor: accentColor,
            ),
          ),
          const SizedBox(height: AtlasSpacing.md),
          Row(
            children: [
              Text(
                value,
                style: AtlasTypography.metricMedium.copyWith(
                  color: accentColor,
                ),
              ),
              if (progress != null) ...[
                const SizedBox(width: AtlasSpacing.lg),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress!.clamp(0.0, 1.0).toDouble(),
                      minHeight: 8,
                      backgroundColor: AtlasColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _EvidenceRow extends StatelessWidget {
  const _EvidenceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 88, child: Text(label, style: AtlasTypography.label)),
        const SizedBox(width: AtlasSpacing.sm),
        Expanded(child: Text(value, style: AtlasTypography.bodyMedium)),
      ],
    );
  }
}

class _ConcernPresentation {
  const _ConcernPresentation(this.label, this.color);

  final String label;
  final Color color;
}

_ConcernPresentation _concernPresentation(AtlasAuthenticityConcernLevel level) {
  return switch (level) {
    AtlasAuthenticityConcernLevel.noObviousConcerns =>
      const _ConcernPresentation('No obvious concerns', AtlasColors.success),
    AtlasAuthenticityConcernLevel.reviewRecommended =>
      const _ConcernPresentation('Review recommended', AtlasColors.warning),
    AtlasAuthenticityConcernLevel.significantInconsistencies =>
      const _ConcernPresentation(
        'Significant inconsistencies',
        AtlasColors.warning,
      ),
    AtlasAuthenticityConcernLevel.strongCounterfeitIndicators =>
      const _ConcernPresentation(
        'Strong warning indicators',
        AtlasColors.danger,
      ),
    AtlasAuthenticityConcernLevel.insufficientData =>
      const _ConcernPresentation(
        'Insufficient data',
        AtlasColors.textSecondary,
      ),
  };
}

class _VariantPresentation {
  const _VariantPresentation(this.label, this.color, this.icon);

  final String label;
  final Color color;
  final IconData icon;
}

_VariantPresentation _variantPresentation(ScanVariantResolution? resolution) {
  if (resolution == null) {
    return const _VariantPresentation(
      'Not evaluated',
      AtlasColors.textSecondary,
      Icons.help_outline_rounded,
    );
  }

  return switch (resolution.status) {
    ScanVariantStatus.exactMatch => const _VariantPresentation(
      'Confirmed',
      AtlasColors.success,
      Icons.check_circle_outline_rounded,
    ),
    ScanVariantStatus.likelyMatch => const _VariantPresentation(
      'Likely match',
      AtlasColors.intelligenceBlue,
      Icons.auto_awesome_rounded,
    ),
    ScanVariantStatus.multipleCandidates => const _VariantPresentation(
      'Choose variant',
      AtlasColors.warning,
      Icons.rule_rounded,
    ),
    ScanVariantStatus.visualConfirmationRequired => const _VariantPresentation(
      'Visual confirmation needed',
      AtlasColors.warning,
      Icons.visibility_outlined,
    ),
    ScanVariantStatus.unknown => const _VariantPresentation(
      'Unknown',
      AtlasColors.textSecondary,
      Icons.help_outline_rounded,
    ),
  };
}
