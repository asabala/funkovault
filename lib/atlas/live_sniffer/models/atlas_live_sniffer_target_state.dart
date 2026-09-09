enum AtlasLiveSnifferTargetState {
  none,
  awaitingSelection,
  acquiring,
  locked,
  coasting,
  reacquiring,
  lost,
}

AtlasLiveSnifferTargetState atlasLiveSnifferTargetStateFromWire(String value) {
  return switch (value.trim()) {
    'awaitingSelection' => AtlasLiveSnifferTargetState.awaitingSelection,
    'acquiring' => AtlasLiveSnifferTargetState.acquiring,
    'locked' => AtlasLiveSnifferTargetState.locked,
    'coasting' => AtlasLiveSnifferTargetState.coasting,
    'reacquiring' => AtlasLiveSnifferTargetState.reacquiring,
    'lost' => AtlasLiveSnifferTargetState.lost,
    _ => AtlasLiveSnifferTargetState.none,
  };
}

extension AtlasLiveSnifferTargetStateX on AtlasLiveSnifferTargetState {
  bool get isSingleTargetLifecycle => this != AtlasLiveSnifferTargetState.none;

  bool get mayContributeEvidence =>
      this == AtlasLiveSnifferTargetState.acquiring ||
      this == AtlasLiveSnifferTargetState.locked;
}
