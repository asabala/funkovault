import 'funko_event.dart';
import 'funko_event_evidence_source.dart';

final class FunkoEventEvidence {
  const FunkoEventEvidence({
    required this.event,
    required this.matchedText,
    required this.source,
  });

  final FunkoEvent event;
  final String matchedText;
  final FunkoEventEvidenceSource source;
}
