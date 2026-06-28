import 'package:flutter/material.dart';

import '../../widgets/atlas_status_banner.dart';
import '../../widgets/vault_scroll_view.dart';
import '../models/atlas_activity.dart';
import '../services/atlas_activity_service.dart';

class AtlasTimelineScreen extends StatelessWidget {
  const AtlasTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const activityService = AtlasActivityService();

    final activities =
    activityService.recentActivities();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlas Timeline'),
      ),
      body: VaultScrollView(
        children: [
          const AtlasStatusBanner(
            title: 'Atlas Timeline',
            message:
            'Atlas remembers important events in your collecting journey.',
            icon: Icons.timeline,
          ),

          const SizedBox(height: 16),

          ...activities.map(
                (activity) => _ActivityTile(
              activity: activity,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.activity,
  });

  final AtlasActivity activity;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(_iconForType(activity.type)),
        title: Text(activity.title),
        subtitle: Text(activity.description),
        trailing: Text(
          _formatTime(activity.timestamp),
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'health':
        return Icons.health_and_safety;
      case 'collector_identity':
        return Icons.badge;
      case 'system':
        return Icons.shield;
      default:
        return Icons.event_note;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }

    return '${difference.inDays}d ago';
  }
}