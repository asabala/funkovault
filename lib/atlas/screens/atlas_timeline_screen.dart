import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/activity.dart';
import '../../services/app_state.dart';
import '../../widgets/atlas/atlas_greeting_card.dart';
import '../../widgets/vault/vault_scroll_view.dart';

class AtlasTimelineScreen extends StatelessWidget {
  const AtlasTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = context.watch<AppState>().recentActivities;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlas Timeline'),
      ),
      body: VaultScrollView(
        children: [
          const AtlasGreetingCard(
            title: 'Atlas Timeline',
            message:
            'Atlas remembers important events in your collecting journey.',
            icon: Icons.timeline,
          ),
          const SizedBox(height: 16),
          if (activities.isEmpty)
            const _EmptyTimelineCard()
          else
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

class _EmptyTimelineCard extends StatelessWidget {
  const _EmptyTimelineCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 42,
            ),
            SizedBox(height: 12),
            Text(
              'No activity recorded yet',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            Text(
              'Important Vault changes will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.activity,
  });

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          _iconForAction(activity.action),
        ),
        title: Text(
          _titleForActivity(activity),
        ),
        subtitle: Text(activity.details),
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

  String _titleForActivity(Activity activity) {
    switch (activity.action) {
      case 'pop_added':
        return 'Pop Added';
      case 'pop_updated':
        return 'Pop Updated';
      case 'pop_deleted':
        return 'Pop Deleted';
      case 'quantity_increased':
        return 'Quantity Increased';
      case 'owner_changed':
        return 'Owner Changed';
      case 'csv_import':
        return 'CSV Import';
      case 'collection_cleared':
        return 'Collection Cleared';
      case 'duplicates_consolidated':
        return 'Duplicates Consolidated';
      case 'wishlist_added':
        return 'Moved to Wishlist';
      case 'wishlist_removed':
        return 'Moved to Owned';
      case 'value_updated':
        return 'Value Updated';
      case 'quantity_updated':
        return 'Quantity Updated';
      default:
        return 'Vault Activity';
    }
  }

  IconData _iconForAction(String action) {
    switch (action) {
      case 'pop_added':
        return Icons.add_circle_outline_rounded;
      case 'pop_updated':
        return Icons.edit_rounded;
      case 'pop_deleted':
        return Icons.delete_outline_rounded;
      case 'quantity_increased':
      case 'quantity_updated':
        return Icons.format_list_numbered_rounded;
      case 'owner_changed':
        return Icons.person_outline_rounded;
      case 'csv_import':
        return Icons.upload_file_rounded;
      case 'collection_cleared':
        return Icons.cleaning_services_rounded;
      case 'duplicates_consolidated':
        return Icons.merge_type_rounded;
      case 'wishlist_added':
        return Icons.favorite_rounded;
      case 'wishlist_removed':
        return Icons.inventory_2_rounded;
      case 'value_updated':
        return Icons.attach_money_rounded;
      default:
        return Icons.event_note_rounded;
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