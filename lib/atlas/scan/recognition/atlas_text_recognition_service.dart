import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

abstract interface class AtlasTextRecognition {
  Future<String> recognize(String path);
  Future<void> close();
}

final class AtlasTextRecognitionService implements AtlasTextRecognition {
  AtlasTextRecognitionService({TextRecognizer? recognizer})
    : _recognizer = recognizer ?? TextRecognizer();

  final TextRecognizer _recognizer;

  @override
  Future<String> recognize(String path) async {
    final normalized = path.trim();
    if (normalized.isEmpty) return '';
    final result = await _recognizer.processImage(
      InputImage.fromFilePath(normalized),
    );
    return result.text.trim();
  }

  @override
  Future<void> close() => _recognizer.close();
}
