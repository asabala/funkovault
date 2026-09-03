enum AtlasAuthenticationProviderKind { jsa, psaDna, beckett, other, unknown }

enum AtlasAuthenticationVerificationState {
  notAttempted,
  unsupported,
  verified,
  notFound,
  mismatch,
  failed,
}

final class AtlasAuthenticationLookupRequest {
  const AtlasAuthenticationLookupRequest({
    required this.provider,
    required this.certificateNumber,
    this.signer,
    this.itemDescription,
  });

  final AtlasAuthenticationProviderKind provider;
  final String certificateNumber;
  final String? signer;
  final String? itemDescription;
}

final class AtlasAuthenticationLookupResult {
  const AtlasAuthenticationLookupResult({
    required this.state,
    required this.provider,
    required this.certificateNumber,
    this.matchedSigner,
    this.matchedItemDescription,
    this.reference,
    this.message,
  });

  final AtlasAuthenticationVerificationState state;
  final AtlasAuthenticationProviderKind provider;
  final String certificateNumber;
  final String? matchedSigner;
  final String? matchedItemDescription;
  final Uri? reference;
  final String? message;

  bool get isVerified => state == AtlasAuthenticationVerificationState.verified;
}

/// Future provider integration seam for JSA, PSA/DNA, Beckett, or another
/// authentication service.
///
/// Scanner 5E intentionally ships no network-backed adapter. Merely detecting a
/// provider name or certificate number must never be represented as externally
/// verified authentication.
abstract interface class AtlasAuthenticationProviderAdapter {
  String get id;
  AtlasAuthenticationProviderKind get provider;

  Future<AtlasAuthenticationLookupResult> lookup(
    AtlasAuthenticationLookupRequest request,
  );
}
