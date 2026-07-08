import '../models/academy_request.dart';

class AcademyRequestStatusUpdater {
  const AcademyRequestStatusUpdater._();

  static AcademyRequest updateStatus({
    required AcademyRequest request,
    required AcademyRequestStatus status,
    required DateTime updatedAt,
  }) {
    return request.copyWith(
      status: status,
      updatedAt: updatedAt,
    );
  }
}