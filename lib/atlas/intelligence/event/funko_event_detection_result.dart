import 'funko_event.dart';
import 'funko_event_evidence.dart';

final class FunkoEventDetectionResult {
  const FunkoEventDetectionResult({
    required this.evidence,
  });

  final List<FunkoEventEvidence> evidence;

  bool get hasEvents => evidence.isNotEmpty;

  bool contains(FunkoEvent event) {
    return evidence.any(
          (item) => item.event == event,
    );
  }
}