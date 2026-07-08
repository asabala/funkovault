import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/app_state.dart';
import '../../models/pop.dart';
import '../pop/add_pop_screen.dart';
import '../pop/pop_details_screen.dart';
import '../../widgets/collector_identity_chips.dart';

class CollectionDetailsScreen extends StatefulWidget {
final String collectionName;

const CollectionDetailsScreen({
super.key,
required this.collectionName,
});

@override
State<CollectionDetailsScreen> createState() =>
_CollectionDetailsScreenState();
}

class _CollectionDetailsScreenState
extends State<CollectionDetailsScreen> {
String _searchText = '';

String _sortBy = 'Name A-Z';

String _ownerFilter = 'All Owners';
bool _selectionMode = false;
final Set<String> _selectedPopIds = {};

void _showAssignOwnerDialog(
    BuildContext context,
    AppState appState,
    ) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text(
          'Assign Owner',
        ),
        content: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            'Arthur',
            'Natacia',
            'Amerika',
            'Nyssa',
            'Angelica',
            'Shared',
          ].map((owner) {
            return ListTile(
              title: Text(owner),
              onTap: () async {
                final selectedIds =
                _selectedPopIds.toList();

                Navigator.of(context).pop();

                await appState.updateOwnerForPops(
                  selectedIds,
                  owner,
                );

                if (!mounted) return;

                setState(() {
                  _selectedPopIds.clear();
                  _selectionMode = false;
                });

                ScaffoldMessenger.of(this.context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      'Assigned to $owner',
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      );
    },
  );
}

@override
Widget build(BuildContext context) {
final appState = context.watch<AppState>();

final List<Pop> allPops =
appState.selectedCollectionPops;

final List<Pop> filteredPops =
allPops.where((pop) {
if (_ownerFilter != 'All Owners' &&
pop.owner != _ownerFilter) {
return false;
}

final search =
_searchText.trim().toLowerCase();

if (search.isEmpty) {
return true;
}

final searchableText = '''
${pop.name}
${pop.number}
${pop.category}
${pop.series}
${pop.itemCondition}
${pop.boxCondition}
'''
    .toLowerCase()
    .replaceAll('\n', ' ');

return searchableText.contains(
search,
);
}).toList();

switch (_sortBy) {
case 'Name A-Z':
filteredPops.sort(
(a, b) => a.name
    .toLowerCase()
    .compareTo(
b.name.toLowerCase(),
),
);
break;

case 'Name Z-A':
filteredPops.sort(
(a, b) => b.name
    .toLowerCase()
    .compareTo(
a.name.toLowerCase(),
),
);
break;

case 'Value High-Low':
filteredPops.sort(
(a, b) =>
b.value.compareTo(a.value),
);
break;

case 'Value Low-High':
filteredPops.sort(
(a, b) =>
a.value.compareTo(b.value),
);
break;

case 'Number':
filteredPops.sort(
(a, b) =>
a.number.compareTo(
b.number,
),
);
break;
}

final int totalPops =
allPops.length;

final double collectionValue =
allPops.fold(
0.0,
(total, pop) =>
total + pop.value,
);

return Scaffold(
  appBar: AppBar(
    title: Text(
      widget.collectionName,
    ),
    actions: [
      IconButton(
        icon: const Icon(
          Icons.merge_type,
        ),
        tooltip: 'Merge Duplicates',
        onPressed: () {
          appState.mergeDuplicates();

          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'Duplicates merged',
              ),
            ),
          );
        },
      ),
      IconButton(
        icon: Icon(
          _selectionMode
              ? Icons.close
              : Icons.checklist,
        ),
        onPressed: () {
          setState(() {
            _selectionMode =
            !_selectionMode;

            if (!_selectionMode) {
              _selectedPopIds.clear();
            }
          });
        },
      ),
    ],
  ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
children: [
Row(
children: [
Expanded(
child: _StatCard(
title: 'Total Pops',
value:
totalPops.toString(),
icon:
Icons.inventory_2,
),
),
const SizedBox(
width: 12,
),
Expanded(
child: _StatCard(
title: 'Value',
value:
'\$${collectionValue.toStringAsFixed(2)}',
icon: Icons
    .attach_money,
),
),
],
),

const SizedBox(height: 8),

TextField(
decoration:
const InputDecoration(
hintText:
'Search name, number, category, series...',
prefixIcon:
Icon(Icons.search),
border:
OutlineInputBorder(),
),
onChanged: (value) {
setState(() {
_searchText = value;
});
},
),

const SizedBox(height: 6),

DropdownButtonFormField<String>(
initialValue: _sortBy,
decoration:
const InputDecoration(
labelText: 'Sort By',
border:
OutlineInputBorder(),
),
items: const [
DropdownMenuItem(
value: 'Name A-Z',
child:
Text('Name A-Z'),
),
DropdownMenuItem(
value: 'Name Z-A',
child:
Text('Name Z-A'),
),
DropdownMenuItem(
value:
'Value High-Low',
child: Text(
'Value High-Low',
),
),
DropdownMenuItem(
value:
'Value Low-High',
child: Text(
'Value Low-High',
),
),
DropdownMenuItem(
value: 'Number',
child:
Text('Number'),
),
],
onChanged: (value) {
if (value == null) {
return;
}

setState(() {
_sortBy = value;
});
},
),

const SizedBox(height: 6),

DropdownButtonFormField<String>(
initialValue:
_ownerFilter,
decoration:
const InputDecoration(
labelText:
'Filter Owner',
border:
OutlineInputBorder(),
),
items: const [
DropdownMenuItem(
value:
'All Owners',
child: Text(
'All Owners',
),
),
DropdownMenuItem(
value: 'Arthur',
child:
Text('Arthur'),
),
DropdownMenuItem(
value: 'Natacia',
child:
Text('Natacia'),
),
DropdownMenuItem(
value: 'Amerika',
child:
Text('Amerika'),
),
DropdownMenuItem(
value: 'Nyssa',
child:
Text('Nyssa'),
),
DropdownMenuItem(
value:
'Angelica',
child: Text(
'Angelica',
),
),
DropdownMenuItem(
value: 'Shared',
child:
Text('Shared'),
),
],
onChanged: (value) {
if (value == null) {
return;
}

setState(() {
_ownerFilter =
value;
});
},
),

const SizedBox(height: 8),
Row(
mainAxisAlignment:
MainAxisAlignment
    .spaceBetween,
children: [
const Text(
'Pop Inventory',
style: TextStyle(
fontSize: 22,
fontWeight:
FontWeight.bold,
),
),
Chip(
label: Text(
'${filteredPops.length} Showing',
),
),
],
),

  const SizedBox(height: 8),

  if (_selectionMode &&
      _selectedPopIds.isNotEmpty)
    Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(
            Icons.people,
          ),
          label: Text(
            'Assign Owner (${_selectedPopIds.length})',
          ),
          onPressed: () {
            _showAssignOwnerDialog(
              context,
              appState,
            );
          },
        ),
      ),
    ),

  Expanded(
child: filteredPops.isEmpty
? const _EmptyState()
    : ListView.builder(
itemCount:
filteredPops.length,
itemBuilder:
(context, index) {
final pop =
filteredPops[index];

return Dismissible(
key: Key(pop.id),
direction:
DismissDirection
    .endToStart,
background:
Container(
alignment:
Alignment
    .centerRight,
padding:
const EdgeInsets
    .only(
right: 20,
),
color:
Colors.red,
child:
const Icon(
Icons.delete,
color:
Colors.white,
),
),
  confirmDismiss: (_) async {
    final result =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Pop',
          ),
          content: Text(
            'Are you sure you want to delete ${pop.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await appState.deletePop(
        pop.id,
      );

      if (!context.mounted) {
        return false;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            '${pop.name} deleted',
          ),
        ),
      );

      return true;
    }

    return false;
  },
child: Card(
  child: ListTile(
    leading: _selectionMode
        ? Checkbox(
      value: _selectedPopIds.contains(
        pop.id,
      ),
      onChanged: (value) {
        setState(() {
          if (value == true) {
            _selectedPopIds.add(
              pop.id,
            );
          } else {
            _selectedPopIds.remove(
              pop.id,
            );
          }
        });
      },
    )
        : pop.imageUrl.isNotEmpty
        ? ClipRRect(
      borderRadius:
      BorderRadius.circular(8),
      child: Image.network(
        pop.imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return const CircleAvatar(
            child: Icon(
              Icons.inventory_2,
            ),
          );
        },
      ),
    )
        : CircleAvatar(
      child: Text(
        pop.number.isEmpty
            ? '?'
            : pop.number,
      ),
    ),
    title: Text(
      pop.quantity > 1
          ? '${pop.name} (${pop.quantity})'
          : pop.name,
    ),
    subtitle: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
if (pop
    .category
    .isNotEmpty)
Text(
pop.category,
),
        if (pop.series.isNotEmpty)
          Text(pop.series),

        CollectorIdentityChips(
          pop: pop,
        ),

        Text(
          'Owner: ${pop.owner}',
        ),
Text(
'Estimated Value: \$${pop.value.toStringAsFixed(2)}',
),
],
),
trailing:
const Icon(
Icons
    .chevron_right,
),
    onTap: () {
      if (_selectionMode) {
        setState(() {
          if (_selectedPopIds.contains(
            pop.id,
          )) {
            _selectedPopIds.remove(
              pop.id,
            );
          } else {
            _selectedPopIds.add(
              pop.id,
            );
          }
        });

        return;
      }

      Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
PopDetailsScreen(
pop: pop,
),
),
);
},
),
),
);
},
),
),
],
),
),
    ),
floatingActionButton:
FloatingActionButton.extended(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const AddPopScreen(),
),
);
},
icon: const Icon(Icons.add),
label: const Text(
'Add Pop',
),
),
);
}
}

class _EmptyState extends StatelessWidget {
const _EmptyState();

@override
Widget build(BuildContext context) {
return Center(
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: const [
Icon(
Icons.search_off,
size: 80,
),
SizedBox(height: 8),
Text(
'No Pops Found',
style: TextStyle(
fontSize: 22,
fontWeight:
FontWeight.bold,
),
),
SizedBox(height: 8),
Text(
'Try a different search.',
textAlign:
TextAlign.center,
),
],
),
);
}
}

class _StatCard extends StatelessWidget {
final String title;
final String value;
final IconData icon;

const _StatCard({
required this.title,
required this.value,
required this.icon,
});

@override
Widget build(BuildContext context) {
return Card(
elevation: 2,
child: Padding(
padding:
const EdgeInsets.symmetric(
vertical: 8,
horizontal: 12,
),
child: Column(
children: [
Icon(
icon,
size: 22,
),
const SizedBox(
height: 8,
),
Text(
value,
style:
const TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),
const SizedBox(
height: 4,
),
Text(title),
],
),
),
);
}
}
