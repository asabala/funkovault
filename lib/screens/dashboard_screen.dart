import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const selectedCollection = 'Entire Family Collection';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('FunkoVault'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Welcome Arthur',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Viewing Collection',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black26,
                      ),
                      child: const Text(
                        selectedCollection,
                        style: TextStyle(fontSize: 16),
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
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: const [
                DashboardCard(
                  title: 'Total Pops',
                  value: '0',
                ),
                DashboardCard(
                  title: 'Collection Value',
                  value: '\$0',
                ),
                DashboardCard(
                  title: 'Wishlist',
                  value: '0',
                ),
                DashboardCard(
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
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Scan Pop'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.add_box),
                title: const Text('Add Pop Manually'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Wishlist'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Collection Health',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Column(
                children: const [
                  ListTile(
                    title: Text('Missing Photos'),
                    trailing: Text('0'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    title: Text('Missing Purchase Prices'),
                    trailing: Text('0'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    title: Text('Pending Approvals'),
                    trailing: Text('0'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No recent activity',
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections),
            label: 'Collections',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}