import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../Login_Screen/Controller/loginController.dart';

class AdminFirstScreen extends StatefulWidget {
  const AdminFirstScreen({Key? key}) : super(key: key);

  @override
  State<AdminFirstScreen> createState() => _AdminFirstScreenState();
}

class _AdminFirstScreenState extends State<AdminFirstScreen> {
  final LoginController _loginController = Get.put(LoginController());
  final GetStorage _storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Name: ${_storage.read('name') ?? 'Unknown'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Organization: ${_storage.read('organization') ?? 'Unknown'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Admin Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.car_rental),
              title: const Text('Car Management'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/carScreen');
              },
            ),
            ListTile(
              leading: const Icon(Icons.two_wheeler),
              title: const Text('Bike Management'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/bikeScreen');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings page
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                _loginController.signOut();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Admin Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionCard(
                  'Car Management',
                  Icons.car_rental,
                  () {
                    Get.toNamed('/carScreen');
                  },
                ),
                _buildActionCard(
                  'Bike Management',
                  Icons.two_wheeler,
                  () {
                    Get.toNamed('/bikeScreen');
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionCard(
                  'Reports',
                  Icons.bar_chart,
                  () {
                    // Navigate to reports
                  },
                ),
                _buildActionCard(
                  'Settings',
                  Icons.settings,
                  () {
                    // Navigate to settings
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Container(
          width: 140,
          height: 140,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
