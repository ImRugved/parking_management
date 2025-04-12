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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (kIsWeb) {
        GetStorage().read("authToken") != null
            ? Get.offAllNamed('/exit_web_screen')
            : Get.offAllNamed("/login_web_screen");
      } else if (Platform.isAndroid || Platform.isIOS) {
        GetStorage().read("authToken") != null
            ? Get.offAllNamed('/first_screen')
            : Get.offAllNamed("/login_screen");
      } else {}
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
              radius: kIsWeb ? 25.sp : 55.sp,
              backgroundColor: ConstColors.white,
              child: Center(
                  child: Image.asset(
                "assets/images/ablogo.png",
                height: kIsWeb ? 120 : 55.h,
                width: kIsWeb ? 125 : 100.w,
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
                      text: 'DAccess Security Systems Pvt. Ltd.',
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
