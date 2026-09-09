import 'dart:math';

import '../models/atlas_live_sniffer_box_candidate.dart';
import '../models/atlas_live_sniffer_native_frame.dart';
import '../models/atlas_live_sniffer_target_state.dart';

final class AtlasLiveSnifferBoxCandidateExtractor {
  const AtlasLiveSnifferBoxCandidateExtractor();

  static final RegExp _numberPattern = RegExp(r'(?<!\d)#?\s*(\d{1,4})(?!\d)');
  static final RegExp _lettersPattern = RegExp(r'[A-Za-z]{2,}');
  static final RegExp _dateOrTimePattern = RegExp(r'\d\s*[:/]\s*\d');

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
  };

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
          // Mirrors the native focused OCR crop. The touch is authoritative:
          // background shelf text outside this generous box region cannot win.
          return (block.centerX - targetX).abs() <= 0.34 &&
              (block.centerY - targetY).abs() <= 0.34;
        })
        .toList(growable: false);
    if (usableBlocks.isEmpty) {
      return const <AtlasLiveSnifferBoxCandidate>[];
    }

    final List<AtlasLiveSnifferBoxCandidate> results =
        <AtlasLiveSnifferBoxCandidate>[];
    final Set<String> dedupe = <String>{};

    for (final AtlasLiveSnifferNativeTextBlock anchor in usableBlocks) {
      if (!_canBeProductNumberLine(anchor.text)) continue;

      final Iterable<RegExpMatch> matches = _numberPattern.allMatches(
        anchor.text,
      );
      for (final RegExpMatch match in matches) {
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
        final double horizontalCenter =
            (1 - ((anchor.centerX - 0.5).abs() / 0.5))
                .clamp(0.0, 1.0)
                .toDouble();
        final double verticalTarget =
            (1 - ((anchor.centerY - 0.50).abs() / 0.50))
                .clamp(0.0, 1.0)
                .toDouble();
        final double textScale = (anchorHeight / 0.045)
            .clamp(0.0, 1.0)
            .toDouble();
        final double widthScale = (anchorWidth / 0.22)
            .clamp(0.0, 1.0)
            .toDouble();
        final double packagingBonus = hasPackagingClue ? 0.18 : 0.0;
        final double numberLineBonus = _isMostlyNumber(anchor.text)
            ? 0.10
            : 0.0;

        final double focusBonus;
        if (hasFocus) {
          final double dx = anchor.centerX - targetX;
          final double dy = anchor.centerY - targetY;
          final double distance = sqrt(dx * dx + dy * dy);
          focusBonus = ((1 - (distance / 0.48)).clamp(0.0, 1.0) * 0.42)
              .toDouble();
        } else {
          focusBonus = 0.0;
        }

        final double featuredScore =
            (horizontalCenter * (hasFocus ? 0.10 : 0.28) +
                    verticalTarget * (hasFocus ? 0.08 : 0.22) +
                    textScale * 0.20 +
                    widthScale * 0.12 +
                    packagingBonus +
                    numberLineBonus +
                    focusBonus)
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
    }

    results.sort(
      (AtlasLiveSnifferBoxCandidate a, AtlasLiveSnifferBoxCandidate b) =>
          b.featuredScore.compareTo(a.featuredScore),
    );
    return List<AtlasLiveSnifferBoxCandidate>.unmodifiable(results.take(12));
  }

  bool _isUsableBlock(
    AtlasLiveSnifferNativeTextBlock block, {
    required bool targetScoped,
  }) {
    final String lower = block.text.toLowerCase().trim();
    if (lower.isEmpty) return false;

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

  bool _canBeProductNumberLine(String value) {
    final String lower = value.toLowerCase().trim();
    if (lower.isEmpty) return false;
    if (lower.contains(r'$') || lower.contains('%')) return false;
    if (_dateOrTimePattern.hasMatch(lower)) return false;

    final Set<String> tokens = _tokens(lower);
    if (tokens.any(_overlayNoiseTokens.contains)) return false;
    if (tokens.any(_marketplaceNoiseTokens.contains) &&
        !_looksLikePopPackaging(lower)) {
      return false;
    }

    final int numericGroups = RegExp(r'\d+').allMatches(lower).length;
    if (numericGroups != 1) return false;
    return _numberPattern.hasMatch(lower);
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
