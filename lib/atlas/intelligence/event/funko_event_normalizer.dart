import 'funko_event.dart';

final class FunkoEventNormalizer {
  const FunkoEventNormalizer();

  FunkoEvent normalize(String phrase) {
    final normalized = normalizeText(phrase);

    for (final event in FunkoEvent.values) {
      if (event.aliases.contains(normalized)) {
        return event;
      }
    }

    return FunkoEvent.unknown;
  }

  String normalizeText(String value) {
    return value
        .toLowerCase()
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool isKnownEvent(String phrase) {
    return normalize(phrase).isKnown;
  }
}
