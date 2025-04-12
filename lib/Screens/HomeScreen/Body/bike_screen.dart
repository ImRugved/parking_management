import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:aditya_birla/Constant/const_colors.dart';
import 'package:aditya_birla/Constant/custom_textstyle.dart';
import 'package:aditya_birla/Screens/HomeScreen/Controller/HomeController.dart';

class BikeScreenPage extends GetView<HomeController> {
  const BikeScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: HomeController(),
        id: "bikeScreen",
        builder: (_) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: ConstColors.backgroundColor,
              surfaceTintColor: ConstColors.backgroundColor,
            ),
            backgroundColor: ConstColors.backgroundColor,
            body: Column(
              children: [
                Image.asset(
                  "assets/images/bike.png",
                  height: 150.h,
                  width: 150.w,
                ),
                Text(
                  "2 \n Wheeler",
                  style: getTextTheme().titleLarge,
                  textAlign: TextAlign.center,
                )
              ],
            ),
          );
        });
  }
}
