import 'dart:developer';

import 'package:aditya_birla/Constant/const_colors.dart';
import 'package:aditya_birla/Constant/constumDropDown.dart';
import 'package:aditya_birla/Constant/custom_textstyle.dart';
import 'package:aditya_birla/Constant/loading.dart';
import 'package:aditya_birla/Constant/rounded_button.dart';
import 'package:aditya_birla/Screens/HomeScreen/Controller/HomeController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: HomeController(),
        id: "homeScreen",
        builder: (_) {
          log("selected vehicle is ${_.selectedVehicle.value}");
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size(Get.width, 65.h),
              child: AppBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "Parking Management",
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
              child: Column(
                children: [
                  Gap(20.h),
                  Text(
                    controller.currentDateWithDay.value,
                    style: getTextTheme().headlineLarge,
                  ),
                  rateWidget(),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                    child: TextField(
                      controller: controller.vehicleNo,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9]'),
                        )
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Enter Vehicle Number',

                        // border: UnderLineInputBorder(),
                      ),
                      onChanged: (value) {
                        controller.vehicleNo.text = value.trim().toUpperCase();
                        controller.update(["homeScreen"]);
                      },
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  locationList(),
                  typeVehicle(),
                  RoundedButton(
                          width: 150.w,
                          press: (controller.vehicleNo.text.trim().isNotEmpty &&
                                  controller.selectedVehicle.value != 0 &&
                                  controller.locationType != null &&
                                  (controller.locationType != 'Other' ||
                                      controller.customLocationController.text
                                          .trim()
                                          .isNotEmpty))
                              ? () async {
                                  controller.insertVehicleEntry();
                                }
                              : () {
                                  if (controller.vehicleNo.text
                                      .trim()
                                      .isEmpty) {
                                    Get.snackbar(
                                      'Input Required',
                                      "Please enter a vehicle number",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFFFFF9C4),
                                      colorText: const Color(0xFF212121),
                                      duration: const Duration(seconds: 3),
                                    );
                                  } else if (controller.selectedVehicle.value ==
                                      0) {
                                    Get.snackbar(
                                      'Selection Required',
                                      "Please select a vehicle type",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFFFFF9C4),
                                      colorText: const Color(0xFF212121),
                                      duration: const Duration(seconds: 3),
                                    );
                                  } else if (controller.locationType == null) {
                                    Get.snackbar(
                                      'Selection Required',
                                      "Please select a location",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFFFFF9C4),
                                      colorText: const Color(0xFF212121),
                                      duration: const Duration(seconds: 3),
                                    );
                                  } else if (controller.locationType ==
                                          'Other' &&
                                      controller.customLocationController.text
                                          .trim()
                                          .isEmpty) {
                                    Get.snackbar(
                                      'Input Required',
                                      "Please enter custom location",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFFFFF9C4),
                                      colorText: const Color(0xFF212121),
                                      duration: const Duration(seconds: 3),
                                    );
                                  }
                                },
                          text: "Print")
                      .toProgress(controller.isPdfLoading),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 70.h),
                      child: RichText(
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
                              text: 'Rugved Belkundkar.',
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
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget rateWidget() {
    return GetBuilder(
        init: HomeController(),
        id: "rate",
        builder: (_) {
          return controller.isLoading.value == true
              ? Center(
                  child: SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        DataTable(
                          columnSpacing: 15.w,
                          border: TableBorder.all(color: ConstColors.black),
                          columns: const [
                            DataColumn(label: Text('Vehicle Type')),
                            DataColumn(label: Text('First 2 Hrs charge')),
                            DataColumn(
                                label: Text('After 2 Hrs,hourly charges')),
                            DataColumn(label: Text('Rate for 24 hrs')),
                          ],
                          rows: controller.vehicleRates.map((rate) {
                            return DataRow(
                              cells: [
                                DataCell(Text(rate.vehicleTypeId ?? '')),
                                DataCell(Text('₹${rate.hoursRate ?? ''}')),
                                DataCell(Text('₹${rate.everyHoursRate ?? ''}')),
                                DataCell(Text('₹${rate.hours24Rate ?? ''}')),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
        });
  }

  Widget locationList() {
    return GetBuilder(
        init: HomeController(),
        id: "locations",
        builder: (_) {
          return controller.isOfficeLoading.value == true
              ? Center(
                  child: SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
                      child: CustomDropDown(
                        value: controller.locationType,
                        items: controller.locationTypeList
                            .map((value) => DropdownMenuItem(
                                  value: value.name,
                                  child: Text(value.name ?? "Unknown"),
                                ))
                            .toList(),
                        label: "Select Location *",
                        hintText: 'Please select location name',
                        style: getTextTheme().headlineMedium,
                        onChanged: (value) {
                          controller.onLocationSelected(value);
                        },
                      ),
                    ),
                    if (controller.isOtherLocationSelected.value)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 5.h),
                        child: TextField(
                          controller: controller.customLocationController,
                          decoration: const InputDecoration(
                            labelText: 'Enter Custom Location',
                            hintText: 'Please specify the location',
                          ),
                          onChanged: (value) {
                            controller.update(["locations"]);
                          },
                        ),
                      ),
                  ],
                );
        });
  }

  Widget typeVehicle() {
    return GetBuilder(
      init: HomeController(),
      id: "typeOfVehicle",
      builder: (_) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onDoubleTap: () {},
              onTap: () {
                controller.selectVehicle('bike');
              },
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/bike.png',
                    width: 50.w,
                    height: 100.h,
                  ),
                  IconButton(
                      onPressed: () {
                        controller.selectVehicle('bike');
                      },
                      icon: Icon(
                        controller.selectedVehicle.value == 2
                            ? Icons.circle
                            : Icons.circle_outlined,
                        color: controller.selectedVehicle.value == 2
                            ? Colors.green
                            : Colors.black,
                        size: 25.sp,
                      ))
                ],
              ),
            ),
            GestureDetector(
              onDoubleTap: () {},
              onTap: () {
                controller.selectVehicle('car');
              },
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/car.png',
                    width: 50.w,
                    height: 100.h,
                  ),
                  IconButton(
                    onPressed: () {
                      controller.selectVehicle('car');
                    },
                    icon: Icon(
                      controller.selectedVehicle.value == 4
                          ? Icons.circle
                          : Icons.circle_outlined,
                      color: controller.selectedVehicle.value == 4
                          ? Colors.green
                          : Colors.black,
                      size: 25.sp,
                    ),
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
