import 'package:flutter/material.dart';

import '../../atlas/components/atlas_empty_state.dart';

class AcademyAdminEmptyInboxState extends StatelessWidget {
  const AcademyAdminEmptyInboxState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AtlasEmptyState(
      eyebrow: 'Academy Admin',
      title: 'Inbox Clear',
      message:
      'Topic and track requests will appear here when collectors submit them for Academy review.',
      icon: Icons.inbox_rounded,
      compact: true,
    );
  }
}