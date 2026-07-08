import 'package:flutter/material.dart';

class AcademyAdminMoreRequestsLabel extends StatelessWidget {
  const AcademyAdminMoreRequestsLabel({
    super.key,
    required this.hiddenRequestCount,
  });

  final int hiddenRequestCount;

  @override
  Widget build(BuildContext context) {
    if (hiddenRequestCount <= 0) {
      return const SizedBox.shrink();
    }

    return Text(
      '+$hiddenRequestCount more request(s)',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.58),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}