import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aditya_birla/Constant/const_colors.dart';
import 'package:aditya_birla/Constant/custom_textstyle.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define bottomSheet height to account for it in the padding
    final bottomSheetHeight = 60.h;

    // Check if user is admin
    final userRole = GetStorage().read('role') ?? 'user';
    final bool isAdmin = userRole == 'admin';
    final String organizationName =
        GetStorage().read('organization') ?? 'Parking System';
    final String userName = GetStorage().read('name') ?? 'User';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(Get.width, 65.h),
        child: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                "assets/images/ablogo.png",
                height: 50.h,
                width: 70.w,
              ),
              Flexible(
                child: Text(
                  organizationName,
                  style: getTextTheme().headlineLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await GetStorage().erase();
                  Get.offAllNamed('/login_screen');
                },
                icon: Icon(
                  Icons.logout_outlined,
                  color: ConstColors.black,
                  size: 25.sp,
                ),
              ),
            ],
          ),
          backgroundColor: ConstColors.white,
          surfaceTintColor: ConstColors.backgroundColor,
        ),
      ),
      backgroundColor: ConstColors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, bottomSheetHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isAdmin)
                    SizedBox(
                      height: 36.h,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showAdminCodeDialog(context);
                        },
                        icon: Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                        label: Text(
                          "Admin",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ConstColors.green,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                "Welcome to ${organizationName}",
                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: ConstColors.green,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              entryCard(),
              SizedBox(height: 20.h),
              exitCard(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        width: Get.width,
        height: bottomSheetHeight,
        color: ConstColors.white,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: 'Powered By ',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: ConstColors.black,
                  fontSize: 12.sp,
                ),
              ),
              TextSpan(
                text: 'DAccess Security Systems Pvt. Ltd.',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: ConstColors.green,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Admin verification dialog
  void _showAdminCodeDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();
    final String adminCode = "myparkingadmin";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Admin Verification"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Please enter admin code to access admin dashboard:"),
              SizedBox(height: 16),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Admin Code",
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (codeController.text == adminCode) {
                  Navigator.of(context).pop();
                  // Store admin access in GetStorage
                  GetStorage().write('adminAccess', true);
                  // Navigate to admin dashboard
                  Get.toNamed("/admin_dashboard");
                } else {
                  Get.snackbar(
                    "Error",
                    "Incorrect admin code",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              child: Text("Verify"),
              style: ElevatedButton.styleFrom(
                backgroundColor: ConstColors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  // Show admin options
  void _showAdminOptions(BuildContext context) {
    final String userName = GetStorage().read('name') ?? 'User';
    final String organizationName =
        GetStorage().read('organization') ?? 'Parking System';

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Admin Options",
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: ConstColors.green,
                ),
              ),
              SizedBox(height: 10.h),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Welcome, ",
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: ConstColors.black,
                      ),
                    ),
                    TextSpan(
                      text: userName,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: ConstColors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                organizationName,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              Divider(height: 20.h, thickness: 1),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: _adminOptionButton(
                      icon: Icons.settings,
                      title: "Parking Settings",
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed("/admin_settings");
                      },
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: _adminOptionButton(
                      icon: Icons.insert_chart,
                      title: "Parking Reports",
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed("/admin_reports");
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  // Admin option button
  Widget _adminOptionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          color: ConstColors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: ConstColors.green,
              size: 40.sp,
            ),
            SizedBox(height: 10.h),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: ConstColors.green,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget entryCard() {
    return GestureDetector(
      onTap: () {
        Get.toNamed("/home_screen");
      },
      child: Container(
        width: Get.width,
        padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
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
          children: [
            Image.asset(
              'assets/images/car.png',
              height: 100.h,
              width: 100.w,
            ),
            SizedBox(height: 15.h),
            Text(
              "Vehicle Entry",
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: ConstColors.green,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "Register new vehicle entries and generate QR codes",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget exitCard() {
    return GestureDetector(
      onTap: () {
        Get.toNamed("/exit_screen");
      },
      child: Container(
        width: Get.width,
        padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
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
          children: [
            Image.asset(
              'assets/images/bike.png',
              height: 100.h,
              width: 100.w,
            ),
            SizedBox(height: 15.h),
            Text(
              "Vehicle Exit",
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: ConstColors.green,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "Process vehicle exits and calculate parking charges",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
