import 'dart:math';

import '../models/atlas_live_sniffer_box_candidate.dart';
import '../models/atlas_live_sniffer_native_frame.dart';
import '../models/atlas_live_sniffer_target_state.dart';

final class AtlasLiveSnifferBoxCandidateExtractor {
  const AtlasLiveSnifferBoxCandidateExtractor();

  static final RegExp _numberPattern = RegExp(r'(?<!\d)#?\s*(\d{1,4})(?!\d)');
  static final RegExp _lettersPattern = RegExp(r'[A-Za-z]{2,}');
  static final RegExp _dateOrTimePattern = RegExp(r'\d\s*[:/]\s*\d');

  // Mirrors the native Fix 6.5 Auction Viewport Authority. Native Kotlin is
  // the primary filter; this is a defensive second boundary for replay/tests.
  static const double _auctionLeft = 0.15;
  static const double _auctionTop = 0.33;
  static const double _auctionRight = 0.85;
  static const double _auctionBottom = 0.80;

  // Manual Scan One authority. The ML Kit tracked box can include neighboring
  // merchandise, so selected-target OCR is additionally constrained to a tight
  // ellipse around the user's persistent tap anchor. Both number and name
  // evidence must pass this same gate before entering temporal identity state.
  static const double _focusedTargetRadiusX = 0.22;
  static const double _focusedTargetRadiusY = 0.24;

  static const Set<String> _overlayNoiseTokens = <String>{
    'atlas',
    'live',
    'scanning',
    'match',
    'owned',
    'wishlist',
    'possible',
    'variant',
    'keep',
    'watching',
    'featured',
    'detected',
  };

  static const Set<String> _marketplaceNoiseTokens = <String>{
    'bid',
    'bids',
    'winning',
    'winner',
    'won',
    'shipping',
    'join',
    'joined',
    'shared',
    'viewer',
    'viewers',
    'ranking',
    'custom',
    'purchase',
    'purchased',
    'products',
    'entries',
    'giveaway',
    'sold',
    'taxes',
    'shop',
    'wallet',
    'boost',
    'clip',
    'likes',
    'followers',
    'following',
    'comments',
  };

  String extractSupplementalText(
    AtlasLiveSnifferNativeFrame frame, {
    double? focusX,
    double? focusY,
  }) {
    if (frame.textBlocks.isEmpty) return '';
    final bool hasFocus = focusX != null && focusY != null;
    final double targetX = focusX ?? 0.5;
    final double targetY = focusY ?? 0.5;
    final bool targetScoped =
        frame.isSingleTargetFrame && frame.targetState.mayContributeEvidence;

    return frame.textBlocks
        .where((AtlasLiveSnifferNativeTextBlock block) {
          return _isUsableBlock(block, targetScoped: targetScoped);
        })
        .where((AtlasLiveSnifferNativeTextBlock block) {
          if (!hasFocus) return true;
          if (targetScoped) {
            return _isInsideFocusedTargetCluster(
              block,
              focusX: targetX,
              focusY: targetY,
            );
          }
          return (block.centerX - targetX).abs() <= 0.30 &&
              (block.centerY - targetY).abs() <= 0.34;
        })
        .where((AtlasLiveSnifferNativeTextBlock block) {
          return _isInsideTrackedTargetGuard(
            block,
            frame: frame,
            targetScoped: targetScoped,
          );
        })
        .map((AtlasLiveSnifferNativeTextBlock block) => block.text.trim())
        .where((String value) => value.isNotEmpty)
        .join(' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<AtlasLiveSnifferBoxCandidate> extract(
    AtlasLiveSnifferNativeFrame frame, {
    double? focusX,
    double? focusY,
  }) {
    if (frame.textBlocks.isEmpty) {
      return const <AtlasLiveSnifferBoxCandidate>[];
    }

    final bool hasFocus = focusX != null && focusY != null;
    final double targetX = focusX ?? 0.5;
    final double targetY = focusY ?? 0.5;
    final bool targetScoped =
        frame.isSingleTargetFrame && frame.targetState.mayContributeEvidence;
    final List<AtlasLiveSnifferNativeTextBlock> usableBlocks = frame.textBlocks
        .where((AtlasLiveSnifferNativeTextBlock block) {
          return _isUsableBlock(block, targetScoped: targetScoped);
        })
        .where((AtlasLiveSnifferNativeTextBlock block) {
          if (!hasFocus) return true;
          if (targetScoped) {
            return _isInsideFocusedTargetCluster(
              block,
              focusX: targetX,
              focusY: targetY,
            );
          }
          return (block.centerX - targetX).abs() <= 0.34 &&
              (block.centerY - targetY).abs() <= 0.34;
        })
        .where((AtlasLiveSnifferNativeTextBlock block) {
          return _isInsideTrackedTargetGuard(
            block,
            frame: frame,
            targetScoped: targetScoped,
          );
        })
        .toList(growable: false);
    if (usableBlocks.isEmpty) {
      return const <AtlasLiveSnifferBoxCandidate>[];
    }

    final List<AtlasLiveSnifferBoxCandidate> results =
        <AtlasLiveSnifferBoxCandidate>[];
    final Set<String> dedupe = <String>{};

    for (final AtlasLiveSnifferNativeTextBlock anchor in usableBlocks) {
      // Fix 6C: when Scan One owns a physical Pop, rank candidate numbers by
      // their position inside the tracked Pop bounds. The official Funko box
      // number badge is normally in the upper-right area of the visible panel.
      // Do not derive these bounds from the anchor itself; doing so would pin
      // the anchor near relX == 0.5 and erase the spatial signal.
      final targetBox = targetScoped ? frame.trackedBoundingBox : null;
      final bool useFocusedSpatialAuthority = targetScoped && hasFocus;
      final _RankedNumberMatch? rankedNumber = _bestProductNumberMatch(
        anchor.text,
        anchorX: anchor.centerX,
        anchorY: anchor.centerY,
        regionLeft: useFocusedSpatialAuthority
            ? (targetX - _focusedTargetRadiusX).clamp(0.0, 1.0).toDouble()
            : targetBox?.left,
        regionRight: useFocusedSpatialAuthority
            ? (targetX + _focusedTargetRadiusX).clamp(0.0, 1.0).toDouble()
            : targetBox?.right,
        regionTop: useFocusedSpatialAuthority
            ? (targetY - _focusedTargetRadiusY).clamp(0.0, 1.0).toDouble()
            : targetBox?.top,
        regionBottom: useFocusedSpatialAuthority
            ? (targetY + _focusedTargetRadiusY).clamp(0.0, 1.0).toDouble()
            : targetBox?.bottom,
      );
      if (rankedNumber == null) continue;
      final RegExpMatch match = rankedNumber.match;

      final String number = match.group(1)?.trim() ?? '';
      if (number.isEmpty) continue;

      final double anchorHeight = (anchor.bottom - anchor.top).abs();
      final double anchorWidth = (anchor.right - anchor.left).abs();
      if (anchorHeight < 0.010 && anchorWidth < 0.030) continue;

      // A Pop number normally lives in the header/side panel, while the name
      // strip can be substantially lower on a large foreground box. Search a
      // tall local package column instead of the old tiny OCR neighborhood.
      final double regionLeft = (anchor.centerX - 0.34)
          .clamp(0.0, 1.0)
          .toDouble();
      final double regionRight = (anchor.centerX + 0.34)
          .clamp(0.0, 1.0)
          .toDouble();
      final double regionTop = (anchor.centerY - 0.16)
          .clamp(0.0, 1.0)
          .toDouble();
      final double regionBottom = (anchor.centerY + 0.48)
          .clamp(0.0, targetScoped ? 1.0 : 0.90)
          .toDouble();

      final List<AtlasLiveSnifferNativeTextBlock> nearby = usableBlocks
          .where((AtlasLiveSnifferNativeTextBlock block) {
            return block.centerX >= regionLeft &&
                block.centerX <= regionRight &&
                block.centerY >= regionTop &&
                block.centerY <= regionBottom;
          })
          .toList(growable: false);

      final String combinedText = nearby
          .map((AtlasLiveSnifferNativeTextBlock block) => block.text.trim())
          .where((String value) => value.isNotEmpty)
          .join(' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      if (combinedText.isEmpty || !_lettersPattern.hasMatch(combinedText)) {
        continue;
      }

      final String lower = combinedText.toLowerCase();
      final bool hasPackagingClue = _looksLikePopPackaging(lower);
      final bool hasMeaningfulText = _meaningfulWordCount(combinedText) >= 1;
      if (!hasPackagingClue && !hasMeaningfulText) continue;

      final double left = nearby
          .map((AtlasLiveSnifferNativeTextBlock block) => block.left)
          .fold<double>(anchor.left, (double a, double b) => a < b ? a : b);
      final double top = nearby
          .map((AtlasLiveSnifferNativeTextBlock block) => block.top)
          .fold<double>(anchor.top, (double a, double b) => a < b ? a : b);
      final double right = nearby
          .map((AtlasLiveSnifferNativeTextBlock block) => block.right)
          .fold<double>(anchor.right, (double a, double b) => a > b ? a : b);
      final double bottom = nearby
          .map((AtlasLiveSnifferNativeTextBlock block) => block.bottom)
          .fold<double>(anchor.bottom, (double a, double b) => a > b ? a : b);

      // Featured scoring is based primarily on the number line itself. This
      // avoids a large background OCR block making a tiny shelf Pop look like
      // the foreground auction item.
      final double horizontalCenter = (1 - ((anchor.centerX - 0.5).abs() / 0.5))
          .clamp(0.0, 1.0)
          .toDouble();
      final double verticalTarget = (1 - ((anchor.centerY - 0.50).abs() / 0.50))
          .clamp(0.0, 1.0)
          .toDouble();
      final double textScale = (anchorHeight / 0.045)
          .clamp(0.0, 1.0)
          .toDouble();
      final double widthScale = (anchorWidth / 0.22).clamp(0.0, 1.0).toDouble();
      final bool anchorHasPackagingClue = _looksLikePopPackaging(
        anchor.text.toLowerCase(),
      );
      final double packagingBonus = hasPackagingClue ? 0.10 : 0.0;
      final double anchorPackagingBonus = anchorHasPackagingClue ? 0.24 : 0.0;
      final double numberLineBonus = _isMostlyNumber(anchor.text) ? 0.08 : 0.0;
      final double numberAuthority =
          (rankedNumber.score / 170.0).clamp(0.0, 1.0).toDouble() * 0.24;

      final double focusBonus;
      if (hasFocus) {
        final double dx = anchor.centerX - targetX;
        final double dy = anchor.centerY - targetY;
        final double distance = sqrt(dx * dx + dy * dy);
        focusBonus = ((1 - (distance / 0.44)).clamp(0.0, 1.0) * 0.50)
            .toDouble();
      } else {
        focusBonus = 0.0;
      }

      // Auction streams often contain perfectly sharp shelf numbers and sticky
      // notes above the foreground turntable. Penalize those softly instead of
      // hard-coding a screen band; the selected/tapped foreground anchor can
      // still win when a seller holds the Pop higher in frame.
      final double upperBackgroundPenalty =
          hasFocus && anchor.centerY < targetY - 0.24
          ? (((targetY - 0.24) - anchor.centerY) / 0.30)
                    .clamp(0.0, 1.0)
                    .toDouble() *
                0.24
          : 0.0;
      final double tinyBackgroundPenalty = textScale < 0.38 && widthScale < 0.35
          ? 0.12
          : 0.0;

      final double featuredScore =
          (horizontalCenter * (hasFocus ? 0.08 : 0.28) +
                  verticalTarget * (hasFocus ? 0.06 : 0.22) +
                  textScale * 0.20 +
                  widthScale * 0.12 +
                  packagingBonus +
                  anchorPackagingBonus +
                  numberLineBonus +
                  numberAuthority +
                  focusBonus -
                  upperBackgroundPenalty -
                  tinyBackgroundPenalty)
              .clamp(0.0, 1.0)
              .toDouble();

      if (featuredScore < 0.23) continue;

      final String spatialKey =
          '${(anchor.centerX * 12).round()}:${(anchor.centerY * 12).round()}:$number';
      if (!dedupe.add(spatialKey)) continue;

      results.add(
        AtlasLiveSnifferBoxCandidate(
          candidateId: spatialKey,
          productNumber: number,
          text: combinedText,
          left: left,
          top: top,
          right: right,
          bottom: bottom,
          featuredScore: featuredScore,
        ),
      );
    }

    // NAME-FIRST identity acquisition:
    // A readable selected foreground box is useful evidence even before ML Kit
    // successfully reads the Funko number badge. Do not discard WOLVERINE,
    // TIANA, CHUCKLES, etc. just because the number is missing on this frame.
    if (results.isEmpty && targetScoped && hasFocus) {
      final List<AtlasLiveSnifferNativeTextBlock> identityBlocks = usableBlocks
          .where((AtlasLiveSnifferNativeTextBlock block) {
            return _lettersPattern.hasMatch(block.text) &&
                _meaningfulWordCount(block.text) >= 1;
          })
          .toList(growable: false);

      if (identityBlocks.isNotEmpty) {
        final String identityText = identityBlocks
            .map((AtlasLiveSnifferNativeTextBlock block) => block.text.trim())
            .where((String value) => value.isNotEmpty)
            .join(' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

        if (identityText.isNotEmpty) {
          final double left = identityBlocks
              .map((AtlasLiveSnifferNativeTextBlock block) => block.left)
              .reduce((double a, double b) => a < b ? a : b);
          final double top = identityBlocks
              .map((AtlasLiveSnifferNativeTextBlock block) => block.top)
              .reduce((double a, double b) => a < b ? a : b);
          final double right = identityBlocks
              .map((AtlasLiveSnifferNativeTextBlock block) => block.right)
              .reduce((double a, double b) => a > b ? a : b);
          final double bottom = identityBlocks
              .map((AtlasLiveSnifferNativeTextBlock block) => block.bottom)
              .reduce((double a, double b) => a > b ? a : b);

          results.add(
            AtlasLiveSnifferBoxCandidate(
              candidateId:
                  'identity:${(targetX * 24).round()}:${(targetY * 24).round()}',
              productNumber: '',
              text: identityText,
              left: left,
              top: top,
              right: right,
              bottom: bottom,
              featuredScore: 0.62,
            ),
          );
        }
      }
    }

    results.sort(
      (AtlasLiveSnifferBoxCandidate a, AtlasLiveSnifferBoxCandidate b) =>
          b.featuredScore.compareTo(a.featuredScore),
    );
    return List<AtlasLiveSnifferBoxCandidate>.unmodifiable(results.take(12));
  }

  bool _isInsideFocusedTargetCluster(
    AtlasLiveSnifferNativeTextBlock block, {
    required double focusX,
    required double focusY,
  }) {
    final double dx = (block.centerX - focusX) / _focusedTargetRadiusX;
    final double dy = (block.centerY - focusY) / _focusedTargetRadiusY;
    return dx * dx + dy * dy <= 1.0;
  }

  bool _isInsideTrackedTargetGuard(
    AtlasLiveSnifferNativeTextBlock block, {
    required AtlasLiveSnifferNativeFrame frame,
    required bool targetScoped,
  }) {
    final targetBox = frame.trackedBoundingBox;
    if (!targetScoped || targetBox == null) return true;

    // Keep the native tracked box as a secondary sanity guard only. Identity
    // authority for a manual target comes from the tighter tap-centered cluster.
    final double horizontalPad = (targetBox.width * 0.06).clamp(0.015, 0.04);
    final double verticalPad = (targetBox.height * 0.06).clamp(0.015, 0.04);
    return block.centerX >= targetBox.left - horizontalPad &&
        block.centerX <= targetBox.right + horizontalPad &&
        block.centerY >= targetBox.top - verticalPad &&
        block.centerY <= targetBox.bottom + verticalPad;
  }

  bool _isUsableBlock(
    AtlasLiveSnifferNativeTextBlock block, {
    required bool targetScoped,
  }) {
    final String lower = block.text.toLowerCase().trim();
    if (lower.isEmpty) return false;

    if (targetScoped && !_isInsideAuctionViewport(block)) return false;

    // Ignore status/app chrome. Also mask the native Atlas overlay footprint in
    // the upper-right so Atlas never OCRs its own '#9', 'Match: 15%', etc.
    if (!targetScoped) {
      if (block.centerY < 0.075 || block.centerY > 0.91) return false;
      if (block.centerY < 0.27 && block.centerX > 0.28) return false;
    }

    final Set<String> tokens = _tokens(lower);
    if (tokens.any(_overlayNoiseTokens.contains)) return false;
    if (tokens.any(_marketplaceNoiseTokens.contains) &&
        !_looksLikePopPackaging(lower)) {
      return false;
    }
    return true;
  }

  bool _isInsideAuctionViewport(AtlasLiveSnifferNativeTextBlock block) {
    return block.centerX >= _auctionLeft &&
        block.centerX <= _auctionRight &&
        block.centerY >= _auctionTop &&
        block.centerY <= _auctionBottom;
  }

  _RankedNumberMatch? _bestProductNumberMatch(
    String value, {
    double? anchorX,
    double? anchorY,
    double? regionLeft,
    double? regionRight,
    double? regionTop,
    double? regionBottom,
  }) {
    final String lower = value.toLowerCase().trim();
    if (lower.isEmpty || _dateOrTimePattern.hasMatch(lower)) return null;
    final Set<String> tokens = _tokens(lower);
    if (tokens.any(_overlayNoiseTokens.contains)) return null;
    if (tokens.any(_marketplaceNoiseTokens.contains) &&
        !_looksLikePopPackaging(lower)) {
      return null;
    }
    final bool packagingLine = _looksLikePopPackaging(lower);
    final bool boilerplateLine = _looksLikeBoilerplateNumberLine(lower);
    _RankedNumberMatch? best;
    for (final RegExpMatch match in _numberPattern.allMatches(lower)) {
      final String digits = match.group(1)?.trim() ?? '';
      final int? number = int.tryParse(digits);
      if (digits.isEmpty || number == null || number <= 0) continue;
      final String before = lower.substring(0, match.start);
      final String after = lower.substring(match.end);
      final String nearbyBefore = before.length <= 16
          ? before
          : before.substring(before.length - 16);
      final String nearbyAfter = after.length <= 16
          ? after
          : after.substring(0, 16);
      final String context = '$nearbyBefore $digits $nearbyAfter';
      if (RegExp(r'[$£€]\s*$').hasMatch(nearbyBefore)) {
        continue;
      }
      if (RegExp(r'\d[.,]\s*$').hasMatch(nearbyBefore)) {
        continue;
      }
      if (RegExp(r'^\s*[.,]\d').hasMatch(nearbyAfter)) {
        continue;
      }
      if (RegExp(r'^\s*(?:[.,]\d{1,2})?\s*%').hasMatch(nearbyAfter)) {
        continue;
      }
      if (number <= 21 && RegExp(r'^\s*\+').hasMatch(nearbyAfter)) {
        continue;
      }
      if (RegExp(r'(?:qty|quantity|count|lot)\s*$').hasMatch(nearbyBefore)) {
        continue;
      }
      if (RegExp(r'^\s*(?:pcs?|pieces?)\b').hasMatch(nearbyAfter)) {
        continue;
      }
      if (RegExp(r'^\s*(?:in(?:ch|ches)?|cm|mm)\b').hasMatch(nearbyAfter) ||
          RegExp(r'^\s*"').hasMatch(nearbyAfter)) {
        continue;
      }
      final bool explicitHash =
          match.group(0)?.trimLeft().startsWith('#') ?? false;
      if (boilerplateLine && !explicitHash && !packagingLine) {
        continue;
      }
      int score = 0;
      if (explicitHash) {
        score += 110;
      }
      if (_isMostlyNumber(value)) {
        score += 28;
      }
      if (packagingLine) {
        score += 30;
      }
      score += switch (digits.length) {
        4 => 42,
        3 => 38,
        2 => 20,
        _ => 6,
      };

      // Funko Box Layout Spatial Bias. This is intentionally applied only when
      // the native selected-target tracker gives us real Pop bounds. It boosts
      // the official upper-right badge and suppresses lower/edge-panel numbers
      // such as checklist grids, copyright rows, and secondary identifiers.
      if (anchorX != null &&
          anchorY != null &&
          regionLeft != null &&
          regionRight != null &&
          regionTop != null &&
          regionBottom != null) {
        final double boxWidth = regionRight - regionLeft;
        final double boxHeight = regionBottom - regionTop;
        if (boxWidth > 0.001 && boxHeight > 0.001) {
          final double relX = ((anchorX - regionLeft) / boxWidth)
              .clamp(0.0, 1.0)
              .toDouble();
          final double relY = ((anchorY - regionTop) / boxHeight)
              .clamp(0.0, 1.0)
              .toDouble();

          final bool upperRightBadge =
              relX >= 0.55 && relX <= 0.95 && relY >= 0.02 && relY <= 0.48;
          final bool lowerPanel = relY > 0.72;
          final bool farSidePanel = relX < 0.10 || relX > 0.98;

          if (upperRightBadge) {
            score += 100;
          } else if (lowerPanel || farSidePanel) {
            score -= 60;
          }
        }
      }
      final int popDistance = _distanceToNearestKeyword(
        lower,
        match.start,
        const <String>['pop', 'funko'],
      );
      if (popDistance <= 6) {
        score += 42;
      } else if (popDistance <= 14) {
        score += 24;
      }
      final double endRatio = match.end / lower.length;
      if (endRatio >= 0.78) {
        score += 30;
      } else if (endRatio >= 0.62) {
        score += 16;
      }
      if (number >= 1900 && number <= 2100) {
        final bool yearContext =
            context.contains('copyright') ||
            context.contains('©') ||
            context.contains('(c)') ||
            context.contains('made in') ||
            context.contains('manufactured');
        score += yearContext ? -90 : -10;
      }
      final String stripped = lower
          .replaceAll(RegExp(r'[^a-z0-9#]+'), ' ')
          .trim();
      if (stripped == digits || stripped == '#$digits') {
        score += 20;
      }
      if (digits.length <= 2 && !explicitHash && !packagingLine) {
        score -= 42;
      }
      final candidate = _RankedNumberMatch(match: match, score: score);
      if (best == null || candidate.score > best.score) {
        best = candidate;
      }
    }
    return best != null && best.score >= 40 ? best : null;
  }

  bool _looksLikeBoilerplateNumberLine(String value) {
    return value.contains('collect them all') ||
        value.contains('collect all') ||
        value.contains('warning') ||
        value.contains('attention') ||
        value.contains('advertencia') ||
        value.contains('copyright') ||
        value.contains('made in') ||
        value.contains('manufactured') ||
        value.contains('www.') ||
        value.contains('funko.com');
  }

  int _distanceToNearestKeyword(
    String value,
    int numberStart,
    List<String> keywords,
  ) {
    int best = 1 << 20;
    for (final String keyword in keywords) {
      int from = 0;
      while (true) {
        final int index = value.indexOf(keyword, from);
        if (index < 0) break;
        final int distance = (index - numberStart).abs();
        if (distance < best) best = distance;
        from = index + keyword.length;
      }
    }
    return best;
  }

  bool _isMostlyNumber(String value) {
    final String stripped = value
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), ' ')
        .trim();
    if (stripped.isEmpty) return false;
    final List<String> tokens = stripped.split(RegExp(r'\s+'));
    return tokens.length <= 2 &&
        tokens.any((String token) => RegExp(r'^\d{1,4}$').hasMatch(token));
  }

  bool _looksLikePopPackaging(String value) {
    return value.contains('pop') ||
        value.contains('funko') ||
        value.contains('animation') ||
        value.contains('heroes') ||
        value.contains('movies') ||
        value.contains('television') ||
        value.contains('games') ||
        value.contains('rocks') ||
        value.contains('vinyl figure');
  }

  Set<String> _tokens(String value) {
    return value
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .split(' ')
        .where((String token) => token.isNotEmpty)
        .toSet();
  }

  int _meaningfulWordCount(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .split(' ')
        .where((String token) {
          return token.length >= 3 &&
              !_overlayNoiseTokens.contains(token) &&
              !_marketplaceNoiseTokens.contains(token);
        })
        .length;
  }
}

final class _RankedNumberMatch {
  const _RankedNumberMatch({required this.match, required this.score});
  final RegExpMatch match;
  final int score;
}
