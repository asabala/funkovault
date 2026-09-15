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

  bool get isOwned =>
      statusLabel.toUpperCase().contains('OWNED') &&
      !statusLabel.toUpperCase().contains('NOT OWNED');

  String get haveLabel {
    final String normalized = statusLabel.toUpperCase();
    if (normalized.contains('OWNED') && !normalized.contains('NOT OWNED')) {
      return 'YES';
    }
    if (normalized.contains('NOT OWNED') || normalized.contains('WISHLIST')) {
      return 'NO';
    }
    if (normalized.contains('POSSIBLE') || normalized.contains('VARIANT')) {
      return 'REVIEW';
    }
    return 'UNKNOWN';
  }

  String get ppgLabel {
    final double? value = cachedValue;
    if (value == null || value <= 0) return '—';
    return '\$${value.toStringAsFixed(0)}';
  }

  String toOverlayLine({int? index}) {
    final String prefix = index == null ? '' : '$index. ';
    return '$prefix${_compactTitle(title)} | PPG: $ppgLabel | Have: $haveLabel';
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
      title = 'LiveLens Auction Mode',
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
    if (items.isNotEmpty) {
      return _toCompactMultiOverlayText();
    }

    if (_shouldUseCompactSingleOverlay) {
      return _toCompactSingleOverlayText();
    }

    return _toCompactStatusOverlayText();
  }

  bool get _shouldUseCompactSingleOverlay {
    final String normalized = statusLabel.toUpperCase();
    if (title.trim().startsWith('#')) return true;
    if (cachedValue != null && cachedValue! > 0) return true;
    return normalized.contains('OWNED') ||
        normalized.contains('WISHLIST') ||
        normalized.contains('POSSIBLE') ||
        normalized.contains('VARIANT') ||
        normalized.contains('NUMBER LOCKED') ||
        normalized.contains('SCANNING BOX') ||
        normalized.contains('MATCHING');
  }

  String _toCompactSingleOverlayText() {
    final List<String> lines = <String>['ATLAS LIVELENS'];
    lines.add(_compactTitle(title));
    lines.add('PPG: ${_ppgLabel(cachedValue)}');
    lines.add('Have: ${_haveLabel(statusLabel)}');

    final String normalized = statusLabel.toUpperCase();
    if (normalized.contains('NUMBER LOCKED')) {
      lines.add('Status: Number locked');
    } else if (normalized.contains('POSSIBLE') ||
        normalized.contains('VARIANT')) {
      lines.add('Status: Review variant');
    }

    return lines.join('\n');
  }

  String _toCompactMultiOverlayText() {
    final int ownedCount = items.where((AtlasLiveSnifferHudItem item) {
      return item.isOwned;
    }).length;
    final int visibleCount = items.length > 5 ? 5 : items.length;
    final List<String> lines = <String>[
      'ATLAS LIVELENS',
      'Scanning ${items.length} Pops...',
      'Have: $ownedCount / ${items.length}',
    ];

    for (int index = 0; index < visibleCount; index++) {
      lines.add(items[index].toOverlayLine(index: index + 1));
    }
    if (items.length > visibleCount) {
      lines.add('+${items.length - visibleCount} more');
    }
    return lines.join('\n');
  }

  String _toCompactStatusOverlayText() {
    final List<String> lines = <String>['ATLAS LIVELENS'];
    lines.add(_compactTitle(title));

    final String normalizedStatus = statusLabel.trim();
    if (normalizedStatus.isNotEmpty) {
      lines.add(_compactStatus(normalizedStatus));
    }

    final String normalizedDetail = detail?.trim() ?? '';
    if (_shouldShowStatusDetail(normalizedDetail)) {
      lines.add(_compactStatus(normalizedDetail));
    }

    return lines.join('\n');
  }

  bool _shouldShowStatusDetail(String value) {
    if (value.isEmpty) return false;
    final String normalized = value.toLowerCase();
    if (normalized.contains('waiting for a readable')) return false;
    if (normalized.contains('watching the foreground')) return false;
    if (normalized.contains('scanning is paused')) return true;
    return value.length <= 72;
  }
}

String _ppgLabel(double? value) {
  if (value == null || value <= 0) return '—';
  return '\$${value.toStringAsFixed(0)}';
}

String _haveLabel(String statusLabel) {
  final String normalized = statusLabel.toUpperCase();
  if (normalized.contains('OWNED') && !normalized.contains('NOT OWNED')) {
    return 'YES';
  }
  if (normalized.contains('NOT OWNED') || normalized.contains('WISHLIST')) {
    return 'NO';
  }
  if (normalized.contains('POSSIBLE') || normalized.contains('VARIANT')) {
    return 'REVIEW';
  }
  if (normalized.contains('NUMBER LOCKED') || normalized.contains('SCANNING')) {
    return 'UNKNOWN';
  }
  return 'UNKNOWN';
}

String _compactTitle(String value) {
  final String compact = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (compact.length <= 48) return compact;
  return '${compact.substring(0, 45)}...';
}

String _compactStatus(String value) {
  final String compact = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (compact.length <= 58) return compact;
  return '${compact.substring(0, 55)}...';
}
