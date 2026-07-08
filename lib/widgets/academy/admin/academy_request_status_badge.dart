import 'package:flutter/material.dart';

import '../../../academy/models/academy_request.dart';

class AcademyRequestStatusBadge extends StatelessWidget {
  const AcademyRequestStatusBadge({
    super.key,
    required this.request,
  });

  final AcademyRequest request;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: _backgroundColor.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        request.statusLabel,
        style: TextStyle(
          color: _textColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (request.status) {
      case AcademyRequestStatus.newRequest:
        return Colors.lightBlueAccent;
      case AcademyRequestStatus.reviewed:
        return Colors.amberAccent;
      case AcademyRequestStatus.approved:
        return Colors.greenAccent;
      case AcademyRequestStatus.declined:
        return Colors.redAccent;
    }
  }

  Color get _textColor {
    switch (request.status) {
      case AcademyRequestStatus.newRequest:
        return Colors.lightBlueAccent;
      case AcademyRequestStatus.reviewed:
        return Colors.amberAccent;
      case AcademyRequestStatus.approved:
        return Colors.greenAccent;
      case AcademyRequestStatus.declined:
        return Colors.redAccent;
    }
  }
}