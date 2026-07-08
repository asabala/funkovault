import 'package:flutter/material.dart';

import '../../../academy/models/academy_request.dart';

class AcademyRequestTypeBadge extends StatelessWidget {
  const AcademyRequestTypeBadge({
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
        color: _badgeColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: _badgeColor.withValues(alpha: 0.32),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            size: 13,
            color: _badgeColor,
          ),
          const SizedBox(width: 6),
          Text(
            request.typeLabel,
            style: TextStyle(
              color: _badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  IconData get _icon {
    switch (request.type) {
      case AcademyRequestType.topic:
        return Icons.lightbulb_outline_rounded;
      case AcademyRequestType.track:
        return Icons.route_rounded;
    }
  }

  Color get _badgeColor {
    switch (request.type) {
      case AcademyRequestType.topic:
        return Colors.purpleAccent;
      case AcademyRequestType.track:
        return Colors.cyanAccent;
    }
  }
}