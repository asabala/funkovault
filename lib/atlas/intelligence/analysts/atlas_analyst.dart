// Base contract for every analyst in the Atlas Intelligence Framework.
//
// An analyst:
//
// 1. Receives structured input.
// 2. Validates whether that input can be analyzed.
// 3. Performs one clearly defined intelligence responsibility.
// 4. Returns a structured result.
//
// Examples:
//
// CollectorDNAAnalyst:
// CollectorMetrics -> CollectorTraitProfile
//
// RecommendationAnalyst:
// RecommendationInput -> List<Recommendation>
//
// VaultHealthAnalyst:
// VaultHealthInput -> VaultHealthAnalysis
//
// Analysts must remain independent from:
//
// - Flutter widgets
// - Screens and navigation
// - Supabase
// - Hive
// - Collection-specific user interfaces
//
// Data gathering happens before the analyst is called.
// Presentation happens after the analyst returns its result.
abstract class AtlasAnalyst<TInput, TResult> {
  const AtlasAnalyst();

  // Stable framework identifier for this analyst.
  //
  // This identifier should not change when the display name changes.
  //
  // Examples:
  //
  // - collector_dna
  // - vault_health
  // - recommendations
  // - collection_timeline
  String get id;

  // User-facing or developer-friendly analyst name.
  //
  // Example:
  //
  // "Collector DNA Analyst"
  String get name;

  // Plain-language explanation of the analyst's responsibility.
  String get description;

  // Version of this analyst's logic.
  //
  // This allows Atlas to identify which version produced a result.
  // It will also support:
  //
  // - result auditing
  // - analyst comparisons
  // - recommendation history
  // - migration tracking
  // - debugging
  String get version => '1.0.0';

  // Validates whether the supplied input contains enough usable data for
  // this analyst to perform a trustworthy analysis.
  //
  // Return an empty list when the input is valid.
  //
  // Return one or more plain-language issues when the input is not valid.
  //
  // Example:
  //
  // ```dart
  // @override
  // List<String> validateInput(CollectorMetrics input) {
  //   final issues = <String>[];
  //
  //   if (input.ownedCount == 0) {
  //     issues.add(
  //       'At least one owned collectible is required.',
  //     );
  //   }
  //
  //   if (input.totalCollectionCount < 5) {
  //     issues.add(
  //       'At least five collectibles are required for reliable analysis.',
  //     );
  //   }
  //
  //   return issues;
  // }
  // ```
  //
  // Analysts should override this method instead of duplicating validation
  // inside both [canAnalyze] and [analyze].
  List<String> validateInput(TInput input) {
    return const <String>[];
  }

  // Determines whether this analyst can analyze the supplied input.
  //
  // This is derived from [validateInput], ensuring Atlas has both:
  //
  // - a simple readiness check
  // - an explanation when the analyst is not ready
  bool canAnalyze(TInput input) {
    return validateInput(input).isEmpty;
  }

  // Performs the analyst's single intelligence responsibility.
  //
  // Results must be structured and must never depend on parsing
  // user-facing text.
  //
  // Callers that need automatic validation should use [analyzeChecked].
  Future<TResult> analyze(TInput input);

  // Validates the input before performing analysis.
  //
  // This is the preferred entry point for most Atlas experiences because it
  // prevents an analyst from running with incomplete or unsupported data.
  //
  // A [StateError] is thrown when input validation fails. The error includes:
  //
  // - analyst name
  // - analyst ID
  // - analyst version
  // - every validation issue
  //
  // Analysts should not override this method. Custom validation belongs in
  // [validateInput], while intelligence logic belongs in [analyze].
  Future<TResult> analyzeChecked(TInput input) async {
    final issues = validateInput(input);

    if (issues.isNotEmpty) {
      final formattedIssues = issues
          .map(
            (issue) => '- $issue',
      )
          .join('\n');

      throw StateError(
        '$name cannot perform analysis.\n'
            'Analyst: $id\n'
            'Version: $version\n'
            '$formattedIssues',
      );
    }

    return analyze(input);
  }

  @override
  String toString() {
    return 'AtlasAnalyst('
        'id: $id, '
        'name: $name, '
        'version: $version'
        ')';
  }
}