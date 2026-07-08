import '../repository/academy_request_repository.dart';
import '../repository/academy_request_repository_contract.dart';
import '../repository/supabase_academy_request_repository.dart';
import 'academy_request_storage_config.dart';

class AcademyRequestRepositoryProvider {
  const AcademyRequestRepositoryProvider._();

  static AcademyRequestRepositoryContract create() {
    switch (AcademyRequestStorageConfig.mode) {
      case AcademyRequestStorageMode.local:
        return AcademyRequestRepository();
      case AcademyRequestStorageMode.supabase:
        return const SupabaseAcademyRequestRepository();
    }
  }
}