import '../models/academy_request.dart';

class AcademyRequestStatusUpdater {
  const AcademyRequestStatusUpdater._();

  static AcademyRequest updateStatus({
    required AcademyRequest request,
    required AcademyRequestStatus status,
    required DateTime updatedAt,
  }) {
    if (!_canTransition(
      from: request.status,
      to: status,
    )) {
      return request;
    }

    if (request.status == status) {
      return request;
    }

    return request.copyWith(
      status: status,
      updatedAt: updatedAt,
    );
  }

  static bool _canTransition({
    required AcademyRequestStatus from,
    required AcademyRequestStatus to,
  }) {
    switch (from) {
      case AcademyRequestStatus.newRequest:
        return to ==
            AcademyRequestStatus.reviewed ||
            to ==
                AcademyRequestStatus.approved ||
            to ==
                AcademyRequestStatus.declined;

      case AcademyRequestStatus.reviewed:
        return to ==
            AcademyRequestStatus.approved ||
            to ==
                AcademyRequestStatus.declined;

      case AcademyRequestStatus.approved:
      case AcademyRequestStatus.declined:
        return false;
    }
  }
}