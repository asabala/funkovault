import '../data/academy_request_status_actions.dart';
import '../models/academy_request.dart';

class AcademyRequestMessageBuilder {
  const AcademyRequestMessageBuilder._();

  static String reviewed(AcademyRequest request) {
    return _buildActionMessage(
      request: request,
      actionLabel: AcademyRequestStatusActions.reviewed,
    );
  }

  static String approved(AcademyRequest request) {
    return _buildActionMessage(
      request: request,
      actionLabel: AcademyRequestStatusActions.approved,
    );
  }

  static String declined(AcademyRequest request) {
    return _buildActionMessage(
      request: request,
      actionLabel: AcademyRequestStatusActions.declined,
    );
  }

  static String _buildActionMessage({
    required AcademyRequest request,
    required String actionLabel,
  }) {
    if (actionLabel == AcademyRequestStatusActions.reviewed) {
      return '${request.title} marked as reviewed.';
    }

    return '${request.title} $actionLabel.';
  }
}
