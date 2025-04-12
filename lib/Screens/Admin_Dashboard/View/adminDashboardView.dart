import 'package:aditya_birla/Constant/const_colors.dart';
import 'package:aditya_birla/Constant/custom_textstyle.dart';
import 'package:aditya_birla/Screens/Admin_Dashboard/Controller/adminDashboardController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size(Get.width, 65.h),
        child: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back,
              color: ConstColors.black,
              size: 25.sp,
            ),
          ),
          title: Text(
            "Admin Dashboard",
            style: getTextTheme().headlineLarge,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: ConstColors.white,
          surfaceTintColor: ConstColors.backgroundColor,
          actions: [
            IconButton(
              onPressed: () {
                _showLogoutOptions(context);
              },
              icon: Icon(
                Icons.logout,
                color: Colors.red,
                size: 25.sp,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin profile card
              _buildAdminProfileCard(),
              SizedBox(height: 30.h),

              // Admin options
              Text(
                "Admin Controls",
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: ConstColors.black,
                ),
              ),
              SizedBox(height: 20.h),

              Row(
                children: [
                  Expanded(
                    child: _adminOptionCard(
                      title: "Parking Settings",
                      icon: Icons.settings,
                      color: Colors.blue,
                      onTap: () {
                        Get.toNamed("/admin_settings");
                      },
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: _adminOptionCard(
                      title: "Parking Reports",
                      icon: Icons.insert_chart,
                      color: Colors.green,
                      onTap: () {
                        Get.toNamed("/admin_reports");
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30.h),

              // Regular options section
              Text(
                "Regular Functions",
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: ConstColors.black,
                ),
              ),
              SizedBox(height: 20.h),

              Row(
                children: [
                  Expanded(
                    child: _adminOptionCard(
                      title: "Vehicle Entry",
                      icon: Icons.directions_car,
                      color: ConstColors.green,
                      onTap: () {
                        Get.toNamed("/home_screen");
                      },
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: _adminOptionCard(
                      title: "Vehicle Exit",
                      icon: Icons.exit_to_app,
                      color: Colors.orangeAccent,
                      onTap: () {
                        Get.toNamed("/exit_screen");
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminProfileCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: ConstColors.green.withOpacity(0.2),
                radius: 30.r,
                child: Icon(
                  Icons.person,
                  color: ConstColors.green,
                  size: 30.sp,
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.userName,
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: ConstColors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Administrator",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: ConstColors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Divider(),
          SizedBox(height: 10.h),
          _infoRow(Icons.email, controller.email),
          SizedBox(height: 10.h),
          _infoRow(Icons.business, controller.organization),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: Colors.grey[600],
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _adminOptionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 35.sp,
            ),
            SizedBox(height: 15.h),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: ConstColors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout Options"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Choose how you would like to logout"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.adminLogout();
            },
            child: Text(
              "Exit Admin Mode",
              style: TextStyle(color: Colors.blue),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.fullLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text("Complete Logout"),
          ),
        ],
      ),
    );
  }
}
