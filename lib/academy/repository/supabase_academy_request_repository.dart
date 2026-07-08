import '../models/academy_request.dart';
import 'academy_request_repository_contract.dart';

class SupabaseAcademyRequestRepository
    implements AcademyRequestRepositoryContract {
  const SupabaseAcademyRequestRepository();

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
  AcademyRequest addTopicRequest({
    required String topic,
    String? trackId,
    String? notes,
  }) {
    throw UnimplementedError(
      'Supabase Academy request storage is not connected yet.',
    );
  }

  @override
  AcademyRequest addTrackRequest({
    required String trackTitle,
    required String trackId,
    String? notes,
  }) {
    throw UnimplementedError(
      'Supabase Academy request storage is not connected yet.',
    );
  }

  @override
  void markReviewed(String requestId) {
    throw UnimplementedError(
      'Supabase Academy request storage is not connected yet.',
    );
  }

  @override
  void approve(String requestId) {
    throw UnimplementedError(
      'Supabase Academy request storage is not connected yet.',
    );
  }

  @override
  void decline(String requestId) {
    throw UnimplementedError(
      'Supabase Academy request storage is not connected yet.',
    );
  }

  @override
  void clearAll() {
    throw UnimplementedError(
      'Supabase Academy request storage is not connected yet.',
    );
  }
}