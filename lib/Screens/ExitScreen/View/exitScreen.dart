import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:aditya_birla/Constant/const_colors.dart';
import 'package:aditya_birla/Constant/constumDropDown.dart';
import 'package:aditya_birla/Constant/custom_textstyle.dart';
import 'package:aditya_birla/Constant/loading.dart';
import 'package:aditya_birla/Constant/rounded_button.dart';
import 'package:aditya_birla/Screens/ExitScreen/Controller/exitController.dart';

class ExitScreen extends GetView<ExitController> {
  const ExitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: ExitController(),
        id: "ExitScreen",
        builder: (_) {
          return Scaffold(
              appBar: PreferredSize(
                preferredSize: Size(Get.width, 65.h),
                child: AppBar(
                  automaticallyImplyLeading: false,
                  flexibleSpace: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Logo on the left

                          // Title in the center with flexible width
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Text(
                                "Parking Management",
                                style: getTextTheme().headlineLarge,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          // Back button on the right
                          IconButton(
                            onPressed: () {
                              Get.back();
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              color: ConstColors.black,
                              size: 24.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  backgroundColor: ConstColors.white,
                  surfaceTintColor: ConstColors.backgroundColor,
                ),
              ),
              backgroundColor: ConstColors.backgroundColor,
              body: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            controller.scan();
                          },
                          child: Container(
                              height: 100.h,
                              width: 250.w,
                              margin: EdgeInsets.symmetric(
                                  vertical: 15.h, horizontal: 0.w),
                              decoration: BoxDecoration(
                                  color: ConstColors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: ConstColors.green)),
                              child: Center(
                                  child: Text(
                                "TAP HERE TO SCAN QR...",
                                style: getTextTheme().labelLarge,
                              ))),
                        ),
                      ),
                      TextField(
                        controller: controller.outputController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]'),
                          ),
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelStyle: getTextTheme().labelMedium,
                          hintText: "Please enter vehicle number",
                          hintStyle: getTextTheme().labelSmall,
                          suffixIcon: InkWell(
                            onTap: () {
                              if (controller.outputController.text
                                  .trim()
                                  .isNotEmpty) {
                                controller.getVehicleEntryData(false);
                              } else {
                                Get.snackbar(
                                  "Error",
                                  "Please enter a vehicle number",
                                  backgroundColor: ConstColors.white,
                                  colorText: ConstColors.black,
                                );
                              }
                            },
                            child: Icon(
                              Icons.search,
                              size: 25.sp,
                              color: ConstColors.black,
                            ),
                          ),
                          border: const UnderlineInputBorder(
                              borderSide: BorderSide(color: ConstColors.green)),
                        ),
                        onChanged: (value) {
                          controller.outputController.text =
                              value.trim().toUpperCase();
                        },
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            controller.getVehicleEntryData(false);
                          }
                        },
                      ),
                      controller.paymentAmount.text != ""
                          ? Column(
                              children: [
                                Gap(20.h),
                                TextField(
                                  controller: controller.paymentAmount,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    label: Text("Amount to pay :",
                                        style: getTextTheme().labelMedium),
                                    border: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: ConstColors.green,
                                      ),
                                    ),
                                  ),
                                ),
                                Gap(20.h),
                                CustomDropDown(
                                  value: controller.paymentType,
                                  items: controller.paymentsTypeList
                                      .map((value) => DropdownMenuItem(
                                            value: value,
                                            child: Text(value),
                                          ))
                                      .toList(),
                                  label: 'Please select payment type:',
                                  onChanged: (value) {
                                    controller.paymentType = value!;
                                    controller.update(["ExitScreen"]);
                                  },
                                ),
                                Gap(20.h),
                                RoundedButton(
                                        press: (controller.paymentType !=
                                                    null &&
                                                controller.outputController
                                                        .text !=
                                                    "")
                                            ? () {
                                                controller
                                                    .getVehicleEntryData(true);
                                              }
                                            : null,
                                        text: "Check Out")
                                    .toProgress(controller.isLoading),
                              ],
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ));
        });
  }
}
