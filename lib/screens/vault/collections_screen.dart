import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../../theme/atlas_colors.dart';
import '../../theme/atlas_spacing.dart';
import '../../theme/atlas_typography.dart';
import '../../widgets/atlas/atlas_glass_card.dart';
import '../../widgets/atlas/components/atlas_info_banner.dart';
import '../../widgets/atlas/components/atlas_section_header.dart';
import '../../widgets/atlas/components/atlas_status_chip.dart';
import '../../widgets/vault/vault_scroll_view.dart';
import 'atlas_room_screen.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  Future<void> _showCreateCollectionDialog(
    BuildContext context,
    AppState appState,
  ) async {
    var enteredName = '';
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create Collection'),
          content: TextFormField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Collection Name',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              enteredName = value;
            },
            onFieldSubmitted: (value) {
              Navigator.pop(dialogContext, value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, enteredName);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (name == null || !context.mounted) {
      return;
    }

    final result = await appState.addCollection(name);

    if (!context.mounted) {
      return;
    }

    _showOperationResult(
      context,
      result,
      successMessage: 'Collection created.',
    );
  }

  Future<void> _showRenameCollectionDialog(
    BuildContext context,
    AppState appState,
    String collectionName,
  ) async {
    var enteredName = collectionName;
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Rename Collection'),
          content: TextFormField(
            initialValue: collectionName,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Collection Name',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              enteredName = value;
            },
            onFieldSubmitted: (value) {
              Navigator.pop(dialogContext, value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, enteredName);
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );

    if (newName == null || !context.mounted) {
      return;
    }

    final result = await appState.renameCollection(collectionName, newName);

    if (!context.mounted) {
      return;
    }

    _showOperationResult(
      context,
      result,
      successMessage: 'Collection renamed.',
    );
  }

  Future<void> _showDeleteCollectionDialog(
    BuildContext context,
    AppState appState,
    String collectionName,
  ) async {
    final popCount = appState.collectionPopCount(collectionName);
    final collectionValue = appState.collectionValue(collectionName);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Collection'),
          content: Text(
            'Delete "$collectionName"?\n\n'
            '$popCount ${popCount == 1 ? 'Pop' : 'Pops'} • '
            '\$${collectionValue.toStringAsFixed(2)} current value\n\n'
            'All Pops and wishlist tracking in this collection will be '
            'removed. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final result = await appState.deleteCollection(collectionName);

    if (!context.mounted) {
      return;
    }

    _showOperationResult(
      context,
      result,
      successMessage: 'Collection deleted.',
    );
  }

  Future<void> _selectCollection(
    BuildContext context,
    AppState appState,
    String collectionName,
  ) async {
    final result = await appState.setSelectedCollection(collectionName);

    if (!context.mounted || result == CollectionOperationResult.success) {
      return;
    }

    _showOperationResult(context, result);
  }

  Future<void> _openCollection(
    BuildContext context,
    AppState appState,
    String collectionName,
  ) async {
    final result = await appState.setSelectedCollection(collectionName);

    if (!context.mounted) {
      return;
    }

    if (result != CollectionOperationResult.success) {
      _showOperationResult(context, result);
      return;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AtlasRoomScreen(
          roomName: collectionName,
          description:
              'Your collection room for stats, insights, previews, and collection tools.',
          icon: Icons.folder_outlined,
          collectionName: collectionName,
        ),
      ),
    );
  }

  void _showOperationResult(
    BuildContext context,
    CollectionOperationResult result, {
    String? successMessage,
  }) {
    final message = switch (result) {
      CollectionOperationResult.success => successMessage,
      CollectionOperationResult.invalidName =>
        'Enter a collection name before continuing.',
      CollectionOperationResult.duplicateName =>
        'A collection with that name already exists.',
      CollectionOperationResult.notFound =>
        'That collection is no longer available.',
      CollectionOperationResult.lastCollection =>
        'At least one collection must remain.',
      CollectionOperationResult.persistenceFailure =>
        'Atlas could not save that collection change. Please try again.',
    };

    if (message == null) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Collections')),
      body: VaultScrollView(
        children: [
          AtlasGlassCard(
            accentColor: AtlasColors.vaultGold,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AtlasSectionHeader(
                  title: 'Manage Collections',
                  subtitle:
                      'Create, organize, and open the collections inside your Vault.',
                  icon: Icons.folder_copy_outlined,
                  accentColor: AtlasColors.vaultGold,
                ),
                const SizedBox(height: AtlasSpacing.lg),
                DropdownButtonFormField<String>(
                  key: ValueKey(appState.selectedCollection),
                  initialValue: appState.selectedCollection,
                  decoration: const InputDecoration(
                    labelText: 'Active Collection',
                    border: OutlineInputBorder(),
                  ),
                  items: appState.collectionNames.map((name) {
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _selectCollection(context, appState, value);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AtlasSpacing.lg),
          const AtlasInfoBanner(
            icon: Icons.info_outline_rounded,
            title: 'Entire Vault Stays Global',
            message:
                'Opening a collection shows only that collection. The main Vault and Entire Vault continue to include every collection.',
          ),
          const SizedBox(height: AtlasSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final crossAxisCount = isWide ? 3 : 2;

              return GridView.builder(
                key: const ValueKey('collections-grid'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: appState.collectionNames.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AtlasSpacing.md,
                  mainAxisSpacing: AtlasSpacing.md,
                  childAspectRatio: isWide ? 1.15 : 0.80,
                ),
                itemBuilder: (context, index) {
                  final collectionName = appState.collectionNames[index];
                  final popCount = appState.collectionPopCount(collectionName);
                  final collectionValue = appState.collectionValue(
                    collectionName,
                  );
                  final isActive =
                      collectionName == appState.selectedCollection;

                  return _CollectionGridCard(
                    collectionName: collectionName,
                    popCount: popCount,
                    collectionValue: collectionValue,
                    isActive: isActive,
                    onOpen: () {
                      _openCollection(context, appState, collectionName);
                    },
                    onRename: () {
                      _showRenameCollectionDialog(
                        context,
                        appState,
                        collectionName,
                      );
                    },
                    onDelete: () {
                      _showDeleteCollectionDialog(
                        context,
                        appState,
                        collectionName,
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: AtlasSpacing.sm),
          FilledButton.icon(
            onPressed: () {
              _showCreateCollectionDialog(context, appState);
            },
            icon: const Icon(Icons.create_new_folder_outlined),
            label: const Text('Create Collection'),
          ),
        ],
      ),
    );
  }
}

class _CollectionGridCard extends StatelessWidget {
  const _CollectionGridCard({
    required this.collectionName,
    required this.popCount,
    required this.collectionValue,
    required this.isActive,
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
  });

  final String collectionName;
  final int popCount;
  final double collectionValue;
  final bool isActive;
  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final accentColor = isActive ? AtlasColors.success : AtlasColors.vaultGold;

    return AtlasGlassCard(
      onTap: onOpen,
      accentColor: accentColor,
      borderRadius: 22,
      padding: const EdgeInsets.all(AtlasSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.folder_outlined, color: accentColor, size: 30),
              const Spacer(),
              if (isActive)
                const AtlasStatusChip(
                  label: 'Active',
                  icon: Icons.check_circle_outline_rounded,
                  accentColor: AtlasColors.success,
                  size: AtlasStatusChipSize.compact,
                ),
              PopupMenuButton<_CollectionAction>(
                key: ValueKey('actions-$collectionName'),
                tooltip: 'Collection actions',
                onSelected: (action) {
                  switch (action) {
                    case _CollectionAction.rename:
                      onRename();
                    case _CollectionAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _CollectionAction.rename,
                    child: Text('Rename'),
                  ),
                  PopupMenuItem(
                    value: _CollectionAction.delete,
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AtlasSpacing.md),
          Text(
            collectionName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AtlasTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            '$popCount ${popCount == 1 ? 'Pop' : 'Pops'}',
            style: AtlasTypography.bodySmall.copyWith(
              color: AtlasColors.textSecondary,
            ),
          ),
          const SizedBox(height: AtlasSpacing.xs),
          Text(
            '\$${collectionValue.toStringAsFixed(2)}',
            style: AtlasTypography.bodyMedium.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: ValueKey('open-$collectionName'),
              onPressed: onOpen,
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Open Collection'),
            ),
          ),
        ],
      ),
    );
  }
}

enum _CollectionAction { rename, delete }
