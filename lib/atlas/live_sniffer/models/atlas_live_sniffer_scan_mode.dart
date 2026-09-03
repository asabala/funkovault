enum AtlasLiveSnifferScanMode { automatic, featured, allVisible }

extension AtlasLiveSnifferScanModeLabel on AtlasLiveSnifferScanMode {
  String get label => switch (this) {
    AtlasLiveSnifferScanMode.automatic => 'Auto',
    AtlasLiveSnifferScanMode.featured => 'Featured Pop',
    AtlasLiveSnifferScanMode.allVisible => 'All Visible',
  };

  String get description => switch (this) {
    AtlasLiveSnifferScanMode.automatic =>
      'Scan one clear foreground Pop automatically. If Atlas sees multiple stable Pops, ask whether to scan one or all.',
    AtlasLiveSnifferScanMode.featured =>
      'Use one Pop at a time. Tap the floating Atlas HUD to select or retarget the exact box you want.',
    AtlasLiveSnifferScanMode.allVisible =>
      'Scan multiple stable Pop boxes on screen in parallel.',
  };
}
