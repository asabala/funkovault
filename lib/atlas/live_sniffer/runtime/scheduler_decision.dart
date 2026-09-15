/// Orchestration action determined by [FrameScheduler] for a given [FrameTick].
enum SchedulerDecision {
  /// Maintain object bounding box tracking and HUD positioning only.
  /// Skips expensive OCR and catalog resolution.
  trackOnly,

  /// Trigger candidate evaluation (ROI segmentation, OCR, and evidence accumulation).
  evaluateCandidate,
}
