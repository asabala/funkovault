import 'package:flutter/material.dart';

import '../../../academy/models/academy_track.dart';
import '../../../theme/atlas_colors.dart';
import '../../../theme/atlas_spacing.dart';
import '../../../theme/atlas_typography.dart';
import '../../atlas/atlas_glass_card.dart';
import '../../atlas/components/atlas_section_header.dart';
import '../../atlas/components/atlas_status_chip.dart';
import 'academy_track_icon_mapper.dart';

class AcademyTrackSelectorCard extends StatelessWidget {
  const AcademyTrackSelectorCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tracks,
    required this.selectedTrackId,
    required this.onTrackSelected,
  });

  final String title;
  final String subtitle;
  final List<AcademyTrack> tracks;
  final String selectedTrackId;
  final ValueChanged<String> onTrackSelected;

  @override
  Widget build(BuildContext context) {
    return AtlasGlassCard(
      accentColor: AtlasColors.intelligenceBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtlasSectionHeader(
            title: title.trim().isEmpty ? 'Choose Academy Track' : title.trim(),
            subtitle: subtitle.trim().isEmpty
                ? 'Choose the collector path you want to explore.'
                : subtitle.trim(),
            icon: Icons.school_rounded,
            accentColor: AtlasColors.intelligenceBlue,
          ),
          if (tracks.isNotEmpty) ...[
            const SizedBox(height: AtlasSpacing.lg),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int index = 0; index < tracks.length; index++) ...[
                    _TrackChip(
                      track: tracks[index],
                      isSelected: tracks[index].id == selectedTrackId,
                      onTap: () {
                        onTrackSelected(tracks[index].id);
                      },
                    ),
                    if (index != tracks.length - 1)
                      const SizedBox(width: AtlasSpacing.sm),
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

class _TrackChip extends StatelessWidget {
  const _TrackChip({
    required this.track,
    required this.isSelected,
    required this.onTap,
  });

  final AcademyTrack track;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = track.isAvailable
        ? AtlasColors.intelligenceBlue
        : AtlasColors.textSecondary;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 200,
        padding: const EdgeInsets.all(AtlasSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.16)
              : AtlasColors.background.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: 0.70)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    AcademyTrackIconMapper.iconFor(track.id),
                    size: 20,
                    color: accentColor,
                  ),
                ),
                const Spacer(),
                if (track.status.trim().isNotEmpty)
                  AtlasStatusChip(
                    label: track.status.trim(),
                    accentColor: track.isAvailable
                        ? AtlasColors.vaultGold
                        : AtlasColors.textSecondary,
                    size: AtlasStatusChipSize.compact,
                  ),
              ],
            ),
            const SizedBox(height: AtlasSpacing.md),
            Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AtlasTypography.headingSmall.copyWith(
                color: isSelected
                    ? AtlasColors.textPrimary
                    : AtlasColors.textPrimary,
              ),
            ),
            const SizedBox(height: AtlasSpacing.xs),
            Text(
              track.subtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AtlasTypography.bodySmall.copyWith(
                color: AtlasColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
