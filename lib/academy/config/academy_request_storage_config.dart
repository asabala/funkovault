import 'package:flutter/foundation.dart';

enum AcademyRequestStorageMode { local, supabase }

class AcademyRequestStorageConfig {
  const AcademyRequestStorageConfig._();

  static const AcademyRequestStorageMode mode = AcademyRequestStorageMode.local;

  static const bool allowLocalSessionSubmissions = kDebugMode;
}
