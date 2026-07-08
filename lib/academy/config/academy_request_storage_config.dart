enum AcademyRequestStorageMode {
  local,
  supabase,
}

class AcademyRequestStorageConfig {
  const AcademyRequestStorageConfig._();

  static const AcademyRequestStorageMode mode = AcademyRequestStorageMode.local;
}