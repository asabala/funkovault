import 'funko_retailer.dart';
import 'funko_retailer_evidence.dart';

// Contains all retailer evidence found during identity analysis.
final class FunkoRetailerDetectionResult {
  const FunkoRetailerDetectionResult({required this.evidence});

  final List<FunkoRetailerEvidence> evidence;

  bool get hasRetailers {
    return evidence.isNotEmpty;
  }

  List<FunkoRetailer> get retailers {
    return List<FunkoRetailer>.unmodifiable(
      evidence.map((FunkoRetailerEvidence item) => item.retailer),
    );
  }

  bool contains(FunkoRetailer retailer) {
    return evidence.any(
      (FunkoRetailerEvidence item) => item.retailer == retailer,
    );
  }
}
