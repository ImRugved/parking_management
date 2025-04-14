import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Constant/const_colors.dart';
import 'Controller/masterController.dart';
import 'Body/CreateAdminScreen.dart';
import 'Body/ManageUsersScreen.dart';

class MasterFirstScreen extends StatelessWidget {
  const MasterFirstScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MasterController>(
      init: MasterController(),
      builder: (controller) {
        return WillPopScope(
          onWillPop: () async {
            // Show confirmation dialog when user tries to exit
            bool? result = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Exit App'),
                content: Text('Are you sure you want to exit the app?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Exit', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            return result ?? false;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Master Dashboard',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
              ),
              backgroundColor: Colors.white,
              actions: [
                IconButton(
                  onPressed: () {
                    controller.signOut();
                  },
                  icon: Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 25.sp,
                  ),
                ),
              ],
            ),
            body: GetBuilder<MasterController>(
              id: 'master_dashboard',
              builder: (_) {
                return Column(
                  children: [
                    _buildNavigation(controller),
                    Expanded(
                      child: _buildCurrentView(controller),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigation(MasterController controller) {
    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _navButton(
              'Manage Users',
              Icons.people,
              controller.currentView.value == 'manage_users',
              () => controller.changeView('manage_users'),
            ),
            SizedBox(width: 8.w),
            _navButton(
              'Create Admin',
              Icons.person_add,
              controller.currentView.value == 'create_admin',
              () => controller.changeView('create_admin'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navButton(
      String title, IconData icon, bool isActive, Function() onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? ConstColors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? ConstColors.green : Colors.grey[400]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey[700],
              size: 16.sp,
            ),
            SizedBox(width: 4.w),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView(MasterController controller) {
    switch (controller.currentView.value) {
      case 'create_admin':
        return CreateAdminScreen(controller: controller);
      case 'manage_users':
      default:
        return ManageUsersScreen(controller: controller);
    }
  }
}
