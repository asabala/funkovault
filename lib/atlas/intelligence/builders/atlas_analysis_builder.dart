import '../models/analysis_finding.dart';
import '../models/atlas_analysis.dart';
import '../models/recommendation.dart';

class AtlasAnalysisBuilder<TResult> {
  AtlasAnalysisBuilder(this.result);

  TResult result;

  double _confidence = 1.0;

  final List<AnalysisFinding> _findings = [];

  final List<Recommendation> _recommendations = [];

  final Map<String, Object?> _metadata = {};

  double get confidence => _confidence;

  set confidence(double value) {
    assert(value >= 0 && value <= 1, 'confidence must be between 0 and 1');

    _confidence = value;
  }

  List<AnalysisFinding> get findings => List.unmodifiable(_findings);

  List<Recommendation> get recommendations =>
      List.unmodifiable(_recommendations);

  Map<String, Object?> get metadata => Map.unmodifiable(_metadata);

  void addFinding(AnalysisFinding finding) {
    _findings.add(finding);
  }

  void addFindings(Iterable<AnalysisFinding> findings) {
    _findings.addAll(findings);
  }

  void addRecommendation(Recommendation recommendation) {
    _recommendations.add(recommendation);
  }

  void addRecommendations(Iterable<Recommendation> recommendations) {
    _recommendations.addAll(recommendations);
  }

  void addMetadata(String key, Object? value) {
    _metadata[key] = value;
  }

  void addAllMetadata(Map<String, Object?> values) {
    _metadata.addAll(values);
  }

  AtlasAnalysis<TResult> build() {
    return AtlasAnalysis<TResult>(
      result: result,
      confidence: _confidence,
      findings: List.unmodifiable(_findings),
      recommendations: List.unmodifiable(_recommendations),
      metadata: Map.unmodifiable(_metadata),
    );
  }
}
