import 'dart:io';

import 'package:aditya_birla/Constant/const_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GetStorage _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (kIsWeb) {
        _storage.read("authToken") != null
            ? Get.offAllNamed('/exit_web_screen')
            : Get.offAllNamed("/login_web_screen");
      } else if (Platform.isAndroid || Platform.isIOS) {
        if (_storage.read("authToken") != null) {
          // Check user role for appropriate navigation
          final String? role = _storage.read('role');
          final String? status = _storage.read('status');

          // Check if user is active
          if (status != 'active') {
            Get.offAllNamed('/login_screen');
            return;
          }

          // Navigate based on user role
          if (role == 'master') {
            Get.offAllNamed('/master_first_screen');
          } else if (role == 'admin') {
            Get.offAllNamed('/admin_first_screen');
          } else {
            // Regular user
            Get.offAllNamed('/first_screen');
          }
        } else {
          Get.offAllNamed("/login_screen");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Container(
            color: ConstColors.green,
          ),
          Center(
            child: CircleAvatar(
              radius: kIsWeb ? 25.sp : 70.sp,
              backgroundColor: ConstColors.white,
              child: Center(
                  child: Container(
                height: kIsWeb ? 120 : 117.h,
                width: kIsWeb ? 125 : 150.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(
                      "assets/images/icon.png",
                    ),
                  ),
                ),
              )),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Powered By ',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: ConstColors.black,
                        fontSize: kIsWeb ? 8.sp : 12.sp,
                      ),
                    ),
                    TextSpan(
                      text: 'Rugved Belkundkar.',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: ConstColors.white,
                        fontSize: kIsWeb ? 8.sp : 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
