enum AtlasLiveSnifferHudState {
  listening,
  owned,
  notOwned,
  wishlisted,
  possibleVariant,
  needsReview,
}

final class AtlasLiveSnifferHudItem {
  const AtlasLiveSnifferHudItem({
    required this.title,
    required this.statusLabel,
    this.cachedValue,
    this.matchConfidence,
  });

  final String title;
  final String statusLabel;
  final double? cachedValue;
  final double? matchConfidence;

  String toOverlayLine({int? index}) {
    final String prefix = index == null ? '' : '$index. ';
    final String confidence = matchConfidence == null
        ? ''
        : ' ${(matchConfidence! * 100).round()}%';
    final String value = cachedValue != null && cachedValue! > 0
        ? ' \$${cachedValue!.toStringAsFixed(0)}'
        : '';
    return '$prefix$title — $statusLabel$confidence$value';
  }
}

final class AtlasLiveSnifferHudSnapshot {
  const AtlasLiveSnifferHudSnapshot({
    required this.state,
    required this.title,
    required this.statusLabel,
    this.detail,
    this.cachedValue,
    this.matchConfidence,
    this.items = const <AtlasLiveSnifferHudItem>[],
  });

  const AtlasLiveSnifferHudSnapshot.listening()
    : state = AtlasLiveSnifferHudState.listening,
      title = 'Auction Fast Mode',
      statusLabel = 'Watching screen',
      detail = 'Looking for Pop name + number...',
      cachedValue = null,
      matchConfidence = null,
      items = const <AtlasLiveSnifferHudItem>[];

  final AtlasLiveSnifferHudState state;
  final String title;
  final String statusLabel;
  final String? detail;
  final double? cachedValue;
  final double? matchConfidence;
  final List<AtlasLiveSnifferHudItem> items;

  String toOverlayText() {
    final List<String> lines = <String>['ATLAS LIVE', title, statusLabel];

    final String normalizedDetail = detail?.trim() ?? '';
    if (normalizedDetail.isNotEmpty) {
      lines.add(normalizedDetail);
    }

    final double? value = cachedValue;
    if (value != null && value > 0) {
      lines.add('Cached Value: \$${value.toStringAsFixed(0)}');
    }

    final double? confidence = matchConfidence;
    if (confidence != null && confidence >= 0 && confidence <= 1) {
      lines.add('Match: ${(confidence * 100).round()}%');
    }

    if (items.isNotEmpty) {
      final int visibleCount = items.length > 6 ? 6 : items.length;
      for (int index = 0; index < visibleCount; index++) {
        lines.add(items[index].toOverlayLine(index: index + 1));
      }
      if (items.length > visibleCount) {
        lines.add('+${items.length - visibleCount} more');
      }
    }

    return lines.join('\n');
  }
}
