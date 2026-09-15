import 'package:flutter/material.dart';

import 'package:funkovault2/theme/atlas_colors.dart';
import 'package:funkovault2/theme/atlas_spacing.dart';
import 'package:funkovault2/theme/atlas_typography.dart';

class AtlasProductImage extends StatelessWidget {
  const AtlasProductImage({
    required this.imageUrl,
    this.width,
    this.height = 195,
    this.fit = BoxFit.contain,
    this.accentColor = AtlasColors.vaultGold,
    this.borderRadius,
    this.placeholderIcon = Icons.inventory_2_outlined,
    this.errorIcon = Icons.broken_image_rounded,
    this.showBorder = false,
    this.showGlow = true,
    this.showPlaceholderLabel = true,
    super.key,
  });

  final String imageUrl;

  /// Optional fixed width.
  ///
  /// Leave null for large Hero-style presentation.
  final double? width;

  final double height;

  final BoxFit fit;

  final Color accentColor;

  /// When supplied, the image uses a rounded rectangular clip.
  ///
  /// When null, no rectangular clipping is applied.
  final double? borderRadius;

  final IconData placeholderIcon;
  final IconData errorIcon;

  /// Adds an ADS accent border around compact/review images.
  final bool showBorder;

  /// Enables the Atlas radial glow behind the product.
  ///
  /// Recommended for Hero presentation.
  final bool showGlow;

  /// Displays "Product image unavailable" below the placeholder.
  ///
  /// Compact thumbnails should normally disable this.
  final bool showPlaceholderLabel;

  @override
  Widget build(BuildContext context) {
    final String normalizedImageUrl = imageUrl.trim();

    final Widget image = normalizedImageUrl.isEmpty
        ? _AtlasProductImagePlaceholder(
            icon: placeholderIcon,
            showLabel: showPlaceholderLabel,
          )
        : Image.network(
            normalizedImageUrl,
            width: width ?? double.infinity,
            height: height,
            fit: fit,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
                  return _AtlasProductImagePlaceholder(
                    icon: errorIcon,
                    showLabel: showPlaceholderLabel,
                  );
                },
            loadingBuilder:
                (
                  BuildContext context,
                  Widget child,
                  ImageChunkEvent? loadingProgress,
                ) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  final int? expectedBytes = loadingProgress.expectedTotalBytes;

                  final double? progress =
                      expectedBytes == null || expectedBytes <= 0
                      ? null
                      : loadingProgress.cumulativeBytesLoaded / expectedBytes;

                  return Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 2,
                        color: accentColor,
                      ),
                    ),
                  );
                },
          );

    final Widget imageSurface = _buildImageSurface(child: image);

    if (!showGlow) {
      return imageSurface;
    }

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: height * 0.85,
            height: height * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accentColor.withValues(alpha: 0.18),
                  accentColor.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          imageSurface,
        ],
      ),
    );
  }

  Widget _buildImageSurface({required Widget child}) {
    final bool needsSurface = borderRadius != null || showBorder;

    if (!needsSurface) {
      return SizedBox(width: width, height: height, child: child);
    }

    final double radius = borderRadius ?? AtlasSpacing.md;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AtlasColors.textSecondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(radius),
        border: showBorder
            ? Border.all(color: accentColor.withValues(alpha: 0.28))
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _AtlasProductImagePlaceholder extends StatelessWidget {
  const _AtlasProductImagePlaceholder({
    required this.icon,
    required this.showLabel,
  });

  final IconData icon;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: showLabel ? 56 : 32,
            color: AtlasColors.textSecondary,
          ),
          if (showLabel) ...[
            const SizedBox(height: AtlasSpacing.sm),
            const Text(
              'Product image unavailable',
              textAlign: TextAlign.center,
              style: AtlasTypography.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
