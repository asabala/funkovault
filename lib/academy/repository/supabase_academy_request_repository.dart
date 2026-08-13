import '../models/academy_request.dart';
import '../models/academy_request_submission_result.dart';
import 'academy_request_repository_contract.dart';

class SupabaseAcademyRequestRepository
    implements AcademyRequestRepositoryContract {
  const SupabaseAcademyRequestRepository();

  @override
  AcademyRequestStorageBehavior get storageBehavior {
    return AcademyRequestStorageBehavior.unavailable;
  }

  @override
  bool get canSubmitRequests {
    return false;
  }

  @override
  List<AcademyRequest> getRequests() {
    throw UnimplementedError(
      'Supabase Academy request storage is not connected yet.',
    );
  }

  @override
  List<AcademyRequest> getNewRequests() {
    throw UnimplementedError(
      'Supabase Academy request storage is not connected yet.',
    );
  }

  @override
  int getNewRequestCount() {
    throw UnimplementedError(
      'Supabase Academy request storage is not connected yet.',
    );
  }

  @override
  Future<AcademyRequestSubmissionResult> submitTopicRequest({
    required String topic,
    String? trackId,
    String? notes,
  }) async {
    return const AcademyRequestSubmissionResult.unavailable();
  }

  @override
  Future<AcademyRequestSubmissionResult> submitTrackRequest({
    required String trackTitle,
    required String trackId,
    String? notes,
  }) async {
    return const AcademyRequestSubmissionResult.unavailable();
  }

  @override
  bool markReviewed(String requestId) {
    throw UnimplementedError(
      'Supabase Academy request storage is not connected yet.',
    );
  }

  @override
  bool approve(String requestId) {
    throw UnimplementedError(
      'Supabase Academy request storage is not connected yet.',
    );
  }

  @override
  bool decline(String requestId) {
    throw UnimplementedError(
      'Supabase Academy request storage is not connected yet.',
    );
  }
}
