import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'wishlist_screen.dart';
import '../services/app_state.dart';
import 'add_pop_screen.dart';

import '../atlas/widgets/vault_report_panel.dart';
import '../atlas/repositories/vault_repository.dart';
import '../atlas/screens/settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _formatCurrency(double value) {
    final parts =
    value.toStringAsFixed(2).split('.');

    final dollars = parts[0];

    final cents = parts[1];

    final buffer = StringBuffer();

    for (int i = 0; i < dollars.length; i++) {
      final position =
          dollars.length - i;

      buffer.write(dollars[i]);

      if (position > 1 &&
          position % 3 == 1) {
        buffer.write(',');
      }
    }

    return '\$${buffer.toString()}.$cents';
  }

  @override
  Widget build(BuildContext context) {
    final appState =
    Provider.of<AppState>(context);

    const repository = VaultRepository();

    final ownerCounts =
    repository.ownerCounts(appState);

    final ownerValues =
    repository.ownerValues(appState);

    final sortedOwners =
    repository.ownerLeaderboard(appState);

    final topPops =
    repository.mostValuablePops(appState);

    final categoryCounts =
    repository.categoryCounts(appState);

    final sortedCategories =
    categoryCounts.entries.toList()
      ..sort(
            (a, b) => b.value.compareTo(a.value),
      );

    final categoryValues =
    repository.categoryValues(appState);

    final sortedCategoryValues =
    categoryValues.entries.toList()
      ..sort(
            (a, b) => b.value.compareTo(a.value),
      );

    return Scaffold(
      backgroundColor:
      const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Funko Vault'),
        actions: [
          IconButton(
            tooltip: 'Atlas Settings',
            icon: const Text(
              '🛡️',
              style: TextStyle(fontSize: 22),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding:
        const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Welcome Arthur',
              style: TextStyle(
                fontSize: 28,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            const VaultReportPanel(),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding:
                const EdgeInsets.all(
                    16),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    const Text(
                      'Viewing Collection',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width:
                      double.infinity,
                      padding:
                      const EdgeInsets
                          .all(12),
                      decoration:
                      BoxDecoration(
                        borderRadius:
                        BorderRadius
                            .circular(
                            8),
                        color:
                        Colors.black26,
                      ),
                      child: Text(
                        appState
                            .selectedCollection,
                        style:
                        const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                DashboardCard(
                  title: 'Total Pops',
                  value: appState
                      .totalPops
                      .toString(),
                ),
                DashboardCard(
                  title:
                  'Collection Value',
                  value:
                  _formatCurrency(
                    appState.totalValue,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const WishlistScreen(),
                      ),
                    );
                  },
                  child: DashboardCard(
                    title: 'Wishlist',
                    value:
                    appState.wishlistCount.toString(),
                  ),
                ),
                const DashboardCard(
                  title: 'Requests',
                  value: '0',
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.qr_code_scanner,
                ),
                title:
                const Text('Scan Pop'),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),
                onTap: () {},
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.add_box),
                title: const Text(
                  'Add Pop Manually',
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const AddPopScreen(),
                    ),
                  );
                },
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Wishlist'),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const WishlistScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Collection Health',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Column(
                children: const [
                  ListTile(
                    title: Text(
                      'Missing Photos',
                    ),
                    trailing:
                    Text('0'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    title: Text(
                      'Missing Purchase Prices',
                    ),
                    trailing:
                    Text('0'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    title: Text(
                      'Pending Approvals',
                    ),
                    trailing:
                    Text('0'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            const Text(
              'Owner Statistics',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Arthur'),
                    trailing: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${ownerCounts['Arthur']} Pops',
                        ),
                        Text(
                          _formatCurrency(
                            ownerValues['Arthur'] ?? 0,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Natacia'),
                    trailing: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${ownerCounts['Natacia']} Pops',
                        ),
                        Text(
                          _formatCurrency(
                            ownerValues['Natacia'] ?? 0,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Amerika'),
                    trailing: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${ownerCounts['Amerika']} Pops',
                        ),
                        Text(
                          _formatCurrency(
                            ownerValues['Amerika'] ?? 0,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Nyssa'),
                    trailing: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${ownerCounts['Nyssa']} Pops',
                        ),
                        Text(
                          _formatCurrency(
                            ownerValues['Nyssa'] ?? 0,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Angelica'),
                    trailing: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${ownerCounts['Angelica']} Pops',
                        ),
                        Text(
                          _formatCurrency(
                            ownerValues['Angelica'] ?? 0,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.groups),
                    title: const Text('Shared'),
                    trailing: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${ownerCounts['Shared']} Pops',
                        ),
                        Text(
                          _formatCurrency(
                            ownerValues['Shared'] ?? 0,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const SizedBox(height: 25),
            const SizedBox(height: 25),

            const Text(
              'Owner Leaderboard',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Column(
                children: List.generate(
                  sortedOwners.length,
                      (index) {
                    final owner =
                    sortedOwners[index];

                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              '#${index + 1}',
                            ),
                          ),
                          title: Text(
                            owner.key,
                          ),
                          subtitle: Text(
                            '${ownerCounts[owner.key] ?? 0} Pops',
                          ),
                          trailing: Text(
                            _formatCurrency(
                              owner.value,
                            ),
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                        if (index <
                            sortedOwners.length -
                                1)
                          const Divider(
                            height: 1,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const Text(
              'Category Values',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Column(
                children: List.generate(
                  sortedCategoryValues.length > 10
                      ? 10
                      : sortedCategoryValues.length,
                      (index) {
                    final category =
                    sortedCategoryValues[index];

                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              '${index + 1}',
                            ),
                          ),
                          title: Text(
                            category.key,
                          ),
                          trailing: Text(
                            _formatCurrency(
                              category.value,
                            ),
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                        if (index <
                            (sortedCategoryValues
                                .length >
                                10
                                ? 10
                                : sortedCategoryValues
                                .length) -
                                1)
                          const Divider(
                            height: 1,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const Text(
              'Top Categories',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Column(
                children: List.generate(
                  sortedCategories.length > 10
                      ? 10
                      : sortedCategories.length,
                      (index) {
                    final category =
                    sortedCategories[index];

                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              '${index + 1}',
                            ),
                          ),
                          title: Text(
                            category.key,
                          ),
                          trailing: Text(
                            '${category.value} Pops',
                          ),
                        ),
                        if (index <
                            (sortedCategories.length >
                                10
                                ? 10
                                : sortedCategories
                                .length) -
                                1)
                          const Divider(
                            height: 1,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const Text(
              'Top Valuable Pops',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

        const SizedBox(height: 10),

        Card(
          child: Column(
            children: List.generate(
              topPops.length > 10
                  ? 10
                  : topPops.length,
                  (index) {
                final pop = topPops[index];

                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          '${index + 1}',
                        ),
                      ),
                      title: Text(
                        pop.name,
                      ),
                      subtitle: Text(
                        pop.owner,
                      ),
                      trailing: Text(
                        _formatCurrency(
                          pop.value,
                        ),
                        style: const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                    if (index <
                        (topPops.length > 10
                            ? 10
                            : topPops.length) -
                            1)
                      const Divider(
                        height: 1,
                      ),
                  ],
                );
              },
            ),
          ),
        ),
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: appState.recentActivities.isEmpty
                  ? const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No recent activity',
                ),
              )
                  : Column(
                children: appState.recentActivities
                    .map((activity) {
                  IconData icon =
                      Icons.history;

                  switch (
                  activity.action) {
                    case 'pop_added':
                      icon =
                          Icons.inventory_2;
                      break;

                    case 'quantity_increased':
                      icon =
                          Icons.add_circle;
                      break;
                  }

                  return ListTile(
                    leading: Icon(icon),
                    title: Text(
                      activity.details,
                    ),
                    subtitle: Text(
                      '${activity.owner} • '
                          '${activity.timestamp.month}/'
                          '${activity.timestamp.day}/'
                          '${activity.timestamp.year}',
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard
    extends StatelessWidget {
  final String title;
  final String value;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment
                .center,
            children: [
              Text(
                value,
                style:
                const TextStyle(
                  fontSize: 28,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}