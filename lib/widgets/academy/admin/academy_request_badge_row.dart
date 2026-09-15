import 'package:flutter/material.dart';

import '../../../academy/models/academy_request.dart';
import '../../../theme/atlas_spacing.dart';
import 'academy_request_status_badge.dart';
import 'academy_request_type_badge.dart';

class AcademyRequestBadgeRow extends StatelessWidget {
  const AcademyRequestBadgeRow({super.key, required this.request});

  final AcademyRequest request;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AtlasSpacing.sm,
      runSpacing: AtlasSpacing.sm,
      children: [
        AcademyRequestTypeBadge(request: request),
        AcademyRequestStatusBadge(request: request),
      ],
    );
  }
}
