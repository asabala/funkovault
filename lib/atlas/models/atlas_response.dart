// AtlasResponse
//
// Every request to Atlas returns one of these.
//
// Whether the request came from:
// • Barcode Scanner
// • Voice
// • Search
// • AI Vision
// • Recommendations
// • Analytics
//
// Atlas always speaks the same language.

class AtlasResponse {
  // Was Atlas successful?
  final bool success;

  // Human readable message.
  final String message;

  // Atlas confidence.
  //
  // 0.0 = No confidence
  // 1.0 = Absolute certainty
  final double confidence;

  // Where the answer came from.
  //
  // Examples:
  // Local Collection
  // Catalog
  // Barcode
  // AI Vision
  // Community
  // Supabase
  final String source;

  // Optional object identifier.
  final String? objectId;

  // Optional object type.
  //
  // Pop
  // Collection
  // Barcode
  // Activity
  final String? objectType;

  // Optional title.
  final String? title;

  // Suggested next action.
  //
  // View Pop
  // Add Pop
  // Learn Barcode
  // Scan Again
  final String? suggestedAction;

  // Additional data.
  final Map<String, dynamic> data;

  // Time response was created.
  final DateTime timestamp;

  const AtlasResponse({
    required this.success,
    required this.message,
    this.confidence = 1.0,
    this.source = 'Atlas',
    this.objectId,
    this.objectType,
    this.title,
    this.suggestedAction,
    this.data = const {},
    required this.timestamp,
  });

  factory AtlasResponse.success({
    required String message,
    double confidence = 1.0,
    String source = 'Atlas',
    String? objectId,
    String? objectType,
    String? title,
    String? suggestedAction,
    Map<String, dynamic> data = const {},
  }) {
    return AtlasResponse(
      success: true,
      message: message,
      confidence: confidence,
      source: source,
      objectId: objectId,
      objectType: objectType,
      title: title,
      suggestedAction: suggestedAction,
      data: data,
      timestamp: DateTime.now(),
    );
  }

  factory AtlasResponse.failure({
    required String message,
    double confidence = 0.0,
    String source = 'Atlas',
    String? suggestedAction,
    Map<String, dynamic> data = const {},
  }) {
    return AtlasResponse(
      success: false,
      message: message,
      confidence: confidence,
      source: source,
      suggestedAction: suggestedAction,
      data: data,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    return '''
AtlasResponse(
  success: $success,
  message: $message,
  confidence: ${(confidence * 100).toStringAsFixed(1)}%,
  source: $source,
  objectId: $objectId,
  objectType: $objectType,
  title: $title,
  suggestedAction: $suggestedAction,
  timestamp: $timestamp
)
''';
  }
}