import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../Screens/Login_Screen/Controller/loginController.dart';

class MasterFirstScreen extends StatefulWidget {
  const MasterFirstScreen({Key? key}) : super(key: key);

  @override
  State<MasterFirstScreen> createState() => _MasterFirstScreenState();
}

class _MasterFirstScreenState extends State<MasterFirstScreen>
    with SingleTickerProviderStateMixin {
  final LoginController _loginController = Get.put(LoginController());
  final GetStorage _storage = GetStorage();
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _currentIndex == 0 ? 'Master Dashboard' : 'Vehicle Entry/Exit'),
        bottom: _currentIndex == 0
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Create Admin', icon: Icon(Icons.person_add)),
                  Tab(text: 'Manage Users', icon: Icon(Icons.people)),
                ],
              )
            : null,
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
                    'Master Dashboard',
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
              title: const Text('Master Dashboard'),
              selected: _currentIndex == 0,
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Vehicle Entry/Exit'),
              selected: _currentIndex == 1,
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
                Navigator.pop(context);
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
      body: _currentIndex == 0
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildCreateAdminTab(),
                _buildManageUsersTab(),
              ],
            )
          : _buildVehicleEntryExitScreen(),
    );
  }

  Widget _buildCreateAdminTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Admin Account',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _loginController.nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _loginController.userId,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => TextField(
              controller: _loginController.password,
              obscureText: !_loginController.isVisible.value,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _loginController.isVisible.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    _loginController.isVisible.value =
                        !_loginController.isVisible.value;
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _loginController.organizationController,
            decoration: const InputDecoration(
              labelText: 'Organization Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
            ),
          ),
          const SizedBox(height: 24),
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loginController.isLoading.value
                    ? null
                    : () {
                        _loginController.createAdminUser();
                      },
                child: _loginController.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Create Admin Account',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageUsersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _loginController.getAllOrganizations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No organizations found'));
        }

        final organizations = snapshot.data!.docs;

        return ListView.builder(
          itemCount: organizations.length,
          itemBuilder: (context, index) {
            final organization =
                organizations[index].data() as Map<String, dynamic>;
            final userId = organizations[index].id;
            final name = organization['name'] ?? 'Unknown';
            final email = organization['email'] ?? 'No email';
            final role = organization['role'] ?? 'user';
            final status = organization['status'] ?? 'inactive';

            // Skip self (master user) in the list
            if (role == 'master' && userId == _storage.read('authToken')) {
              return const SizedBox.shrink();
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: $email'),
                    Text('Role: $role'),
                    Text(
                      'Status: $status',
                      style: TextStyle(
                        color: status == 'active' ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: Switch(
                  value: status == 'active',
                  activeColor: Colors.green,
                  onChanged: (value) {
                    _loginController.toggleUserStatus(userId, value);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVehicleEntryExitScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 0.2.sh,
            width: 1.sw,
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome to",
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Parking Management App",
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Gap(10.h),
                Text(
                  "Powered by Rugved Belkundkar",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 0.7.sh,
            width: 1.sw,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Gap(20.h),
                Text(
                  "Vehicle Entry/Exit",
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                Gap(20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Get.toNamed('/carScreen');
                      },
                      child: Container(
                        height: 0.25.sh,
                        width: 0.4.sw,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Entry",
                              style: GoogleFonts.poppins(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Get.toNamed('/bikeScreen');
                      },
                      child: Container(
                        height: 0.25.sh,
                        width: 0.4.sw,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Exit",
                              style: GoogleFonts.poppins(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
