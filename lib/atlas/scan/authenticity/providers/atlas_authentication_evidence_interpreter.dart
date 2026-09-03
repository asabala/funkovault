import 'atlas_authentication_provider.dart';

enum AtlasAuthenticationDocumentationState {
  observed,
  supported,
  unverified,
  inconsistent,
}

final class AtlasAuthenticationEvidenceInterpretation {
  const AtlasAuthenticationEvidenceInterpretation({
    required this.providerKind,
    required this.providerDisplayName,
    required this.certificateNumber,
    required this.detectedProviderDisplayName,
    required this.detectedCertificateNumber,
    required this.providerFieldMismatch,
    required this.certificateNumberMismatch,
    required this.documentationState,
  });

  final AtlasAuthenticationProviderKind providerKind;
  final String providerDisplayName;
  final String certificateNumber;
  final String detectedProviderDisplayName;
  final String detectedCertificateNumber;
  final bool providerFieldMismatch;
  final bool certificateNumberMismatch;
  final AtlasAuthenticationDocumentationState documentationState;

  bool get hasProvider => providerDisplayName.isNotEmpty;
  bool get hasCertificateNumber => certificateNumber.isNotEmpty;
  bool get hasInternalMismatch =>
      providerFieldMismatch || certificateNumberMismatch;
}

abstract final class AtlasAuthenticationEvidenceInterpreter {
  static AtlasAuthenticationEvidenceInterpretation interpret({
    String provider = '',
    String certificateNumber = '',
    String certificationText = '',
    bool? hasCoa,
  }) {
    final String explicitProvider = provider.trim();
    final String explicitNumber = _normalizeCertificateNumber(
      certificateNumber,
    );
    final String rawText = certificationText.trim();

    final _ProviderMatch detectedProvider = _detectProvider(rawText);
    final String detectedNumber = _detectCertificateNumber(rawText);

    final _ProviderMatch explicitProviderMatch = _providerFromText(
      explicitProvider,
    );

    final bool providerMismatch =
        explicitProvider.isNotEmpty &&
        detectedProvider.kind != AtlasAuthenticationProviderKind.unknown &&
        explicitProviderMatch.kind != AtlasAuthenticationProviderKind.unknown &&
        explicitProviderMatch.kind != detectedProvider.kind;

    final bool numberMismatch =
        explicitNumber.isNotEmpty &&
        detectedNumber.isNotEmpty &&
        explicitNumber.toLowerCase() != detectedNumber.toLowerCase();

    final String resolvedProvider = explicitProvider.isNotEmpty
        ? explicitProvider
        : detectedProvider.displayName;
    final AtlasAuthenticationProviderKind resolvedProviderKind =
        explicitProvider.isNotEmpty
        ? explicitProviderMatch.kind
        : detectedProvider.kind;
    final String resolvedNumber = explicitNumber.isNotEmpty
        ? explicitNumber
        : detectedNumber;

    final bool hasDocumentation =
        hasCoa == true ||
        resolvedProvider.isNotEmpty ||
        resolvedNumber.isNotEmpty ||
        rawText.isNotEmpty;

    final AtlasAuthenticationDocumentationState documentationState;
    if (providerMismatch || numberMismatch) {
      documentationState = AtlasAuthenticationDocumentationState.inconsistent;
    } else if (hasDocumentation &&
        resolvedProvider.isNotEmpty &&
        resolvedNumber.isNotEmpty) {
      documentationState = AtlasAuthenticationDocumentationState.supported;
    } else if (hasDocumentation) {
      documentationState = AtlasAuthenticationDocumentationState.unverified;
    } else {
      documentationState = AtlasAuthenticationDocumentationState.observed;
    }

    return AtlasAuthenticationEvidenceInterpretation(
      providerKind: resolvedProviderKind,
      providerDisplayName: resolvedProvider,
      certificateNumber: resolvedNumber,
      detectedProviderDisplayName: detectedProvider.displayName,
      detectedCertificateNumber: detectedNumber,
      providerFieldMismatch: providerMismatch,
      certificateNumberMismatch: numberMismatch,
      documentationState: documentationState,
    );
  }

  static _ProviderMatch _detectProvider(String text) {
    final _ProviderMatch match = _providerFromText(text);
    if (match.kind == AtlasAuthenticationProviderKind.other) {
      return const _ProviderMatch(AtlasAuthenticationProviderKind.unknown, '');
    }
    return match;
  }

  static _ProviderMatch _providerFromText(String text) {
    final String normalized = text.toLowerCase();
    if (normalized.isEmpty) {
      return const _ProviderMatch(AtlasAuthenticationProviderKind.unknown, '');
    }

    if (RegExp(r'\bjsa\b|james\s+spence').hasMatch(normalized)) {
      return const _ProviderMatch(AtlasAuthenticationProviderKind.jsa, 'JSA');
    }
    if (RegExp(r'\bpsa(?:\s*/?\s*dna)?\b').hasMatch(normalized)) {
      return const _ProviderMatch(
        AtlasAuthenticationProviderKind.psaDna,
        'PSA/DNA',
      );
    }
    if (RegExp(r'\bbeckett\b|\bbas\b').hasMatch(normalized)) {
      return const _ProviderMatch(
        AtlasAuthenticationProviderKind.beckett,
        'Beckett',
      );
    }

    return _ProviderMatch(
      text.trim().isEmpty
          ? AtlasAuthenticationProviderKind.unknown
          : AtlasAuthenticationProviderKind.other,
      text.trim(),
    );
  }

  static String _detectCertificateNumber(String text) {
    if (text.trim().isEmpty) return '';

    final List<RegExp> labeledPatterns = <RegExp>[
      RegExp(
        r'(?:cert(?:ificate|ification)?\s*(?:no\.?|number|#)?|coa\s*(?:no\.?|number|#)?)[\s:\-#]*([a-z0-9][a-z0-9\-]{3,})',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:verification\s*(?:no\.?|number|#)?)[\s:\-#]*([a-z0-9][a-z0-9\-]{3,})',
        caseSensitive: false,
      ),
    ];

    for (final RegExp pattern in labeledPatterns) {
      final RegExpMatch? match = pattern.firstMatch(text);
      if (match != null) {
        return _normalizeCertificateNumber(match.group(1) ?? '');
      }
    }

    return '';
  }

  static String _normalizeCertificateNumber(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}

final class _ProviderMatch {
  const _ProviderMatch(this.kind, this.displayName);

  final AtlasAuthenticationProviderKind kind;
  final String displayName;
}
