import '../models/scan_session.dart';
import '../results/scan_variant_status.dart';

/// Applies an explicit collector confirmation to an existing variant review.
///
/// This service does not change [ScanSession.atlasProductId] or
/// [ScanSession.resolvedProduct]. It only records that the collector reviewed
/// the current resolved release against the visual variant evidence.
final class AtlasVariantConfirmationService {
  const AtlasVariantConfirmationService();

  ScanSession confirmResolvedVariant(ScanSession session) {
    final ScanVariantResolution? current = session.variantResolution;
    if (current == null || !current.requiresConfirmation) {
      return session;
    }

    final List<String> confirmedTraits = _deduplicate(<String>[
      ...current.confirmedTraits,
      ...current.unconfirmedTraits,
    ]);

    return session.copyWith(
      variantResolution: ScanVariantResolution(
        status: ScanVariantStatus.exactMatch,
        candidateProductIds: <String>[
          if (session.atlasProductId?.value.trim().isNotEmpty == true)
            session.atlasProductId!.value.trim(),
        ],
        confirmedTraits: confirmedTraits,
        unconfirmedTraits: const <String>[],
        confidence: current.confidence,
      ),
    );
  }

  static List<String> _deduplicate(Iterable<String> values) {
    final Map<String, String> normalized = <String, String>{};
    for (final String value in values) {
      final String trimmed = value.trim();
      if (trimmed.isEmpty) continue;
      normalized.putIfAbsent(trimmed.toLowerCase(), () => trimmed);
    }
    return List<String>.unmodifiable(normalized.values);
  }
}
