import 'package:aditya_birla/Constant/const_colors.dart';
import 'package:aditya_birla/Constant/custom_textstyle.dart';
import 'package:aditya_birla/Constant/loading.dart';
import 'package:aditya_birla/Constant/rounded_button.dart';
import 'package:aditya_birla/Screens/LoginWeb_Screen/Controllr/loginWeb_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginWebPageScreen extends GetView<LoginWebController> {
  const LoginWebPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: LoginWebController(),
        id: "homeScreen",
        builder: (_) {
          return Scaffold(
            // backgroundColor: ConstColors.white,
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: const AssetImage(
                  'assets/images/aditya_birla_bg.jpg',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5), BlendMode.darken),
              )),
              // margin: REdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image.asset(
                      //   "assets/images/parkingLogo.png",
                      //   height: 80.h,
                      //   width: 100.w,
                      // ),
                      Center(
                        child: Text(
                          'Aditya Birla Memorial Hospital',
                          style: getTextTheme().bodyMedium,
                        ),
                      ),
                      Gap(20.h),
                      TextFormField(
                        controller: controller.userId,
                        obscureText: false,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp('[a-zA-Z0-9@#£_&-+.()\$/*":;!?€¥¢^=-]'))
                        ],
                        keyboardType: TextInputType.text,
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          color: ConstColors.white.withOpacity(0.80),
                          fontSize: 6.sp,
                        ),
                        cursorColor: ConstColors.green,
                        cursorHeight: 25.h,
                        decoration: InputDecoration(
                          label: Text(
                            "Login Id",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              color: ConstColors.white,
                              fontSize: 7.sp,
                            ),
                          ),
                          //hintText: customText,

                          hintStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 6.sp,
                            color: ConstColors.white,
                          ),
                          errorStyle: TextStyle(
                            height: 0.sp,
                            color: ConstColors.red,
                            fontSize: 5.sp,
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                          ),
                          //filled: true,
                          //fillColor: ConstColors.backgroundColor,

                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15.h, horizontal: 0),
                          focusedBorder: UnderlineInputBorder(
                            //borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                width: 1.sp, color: ConstColors.green),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            //borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                width: 1.sp, color: ConstColors.modelSheet),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            //borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                width: 1.sp, color: ConstColors.modelSheet),
                          ),
                          border: UnderlineInputBorder(
                            //borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                width: 1.sp, color: ConstColors.modelSheet),
                          ),
                          errorBorder: UnderlineInputBorder(
                            //borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide:
                                BorderSide(width: 1.sp, color: ConstColors.red),
                          ),
                          focusedErrorBorder: UnderlineInputBorder(
                            //borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide:
                                BorderSide(width: 1.sp, color: ConstColors.red),
                          ),
                        ),
                        onChanged: (value) {
                          controller.update(["homeScreen"]);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Login Id';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          controller.password.text = value!;
                          controller.update(["homeScreen"]);
                        },
                      ),
                      // CustomTextFormField(
                      //   isBool: true,
                      //   customText: "Login Id",
                      //   label: "Login Id",
                      //   controller: controller.userId,
                      //   keyoardType: TextInputType.text,
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter Login Id';
                      //     }
                      //     return null;
                      //   },
                      //   inputFormatters: const [],
                      //   onChanged: (value) {
                      //     // controller.userId.text = value;
                      //     controller.update(["homeScreen"]);
                      //   },
                      //   onSaved: (value) {
                      //     controller.password.text = value!;
                      //     controller.update(["homeScreen"]);
                      //   },
                      // ),
                      Gap(20.h),
                      TextFormField(
                        controller: controller.password,
                        obscureText: !controller.isVisible.value,
                        textInputAction: TextInputAction.go,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp('[a-zA-Z0-9@#£_&-+.()\$/*":;!?€¥¢^=-]')),
                          LengthLimitingTextInputFormatter(20),
                        ],
                        keyboardType: TextInputType.text,
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          color: ConstColors.white.withOpacity(0.80),
                          fontSize: 6.sp,
                        ),
                        cursorColor: ConstColors.green,
                        cursorHeight: 25.h,
                        decoration: InputDecoration(
                          label: Text(
                            "Password",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              color: ConstColors.white,
                              fontSize: 7.sp,
                            ),
                          ),
                          //hintText: customText,

                          hintStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 6.sp,
                            color: ConstColors.white,
                          ),
                          errorStyle: TextStyle(
                            height: 0.sp,
                            color: ConstColors.red,
                            fontSize: 6.sp,
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                          ),

                          isDense: true,
                          suffixIcon: GestureDetector(
                              onTap: () {
                                controller.isVisible.value =
                                    !controller.isVisible.value;
                                controller.update(["homeScreen"]);
                              },
                              onDoubleTap: () {},
                              child: !controller.isVisible.value
                                  ? Icon(Icons.visibility_off_sharp,
                                      color: ConstColors.modelSheet,
                                      size: 10.sp)
                                  : Icon(Icons.visibility_outlined,
                                      color: ConstColors.modelSheet,
                                      size: 10.sp)),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15.h, horizontal: 0),
                          focusedBorder: UnderlineInputBorder(
                            //borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                width: 1.sp, color: ConstColors.green),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            //borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                width: 1.sp, color: ConstColors.modelSheet),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            //borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                width: 1.sp, color: ConstColors.modelSheet),
                          ),
                          border: UnderlineInputBorder(
                            //borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                                width: 1.sp, color: ConstColors.modelSheet),
                          ),
                          errorBorder: UnderlineInputBorder(
                            //borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide:
                                BorderSide(width: 1.sp, color: ConstColors.red),
                          ),
                          focusedErrorBorder: UnderlineInputBorder(
                            //borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide:
                                BorderSide(width: 1.sp, color: ConstColors.red),
                          ),
                        ),
                        onChanged: (value) {
                          controller.update(["homeScreen"]);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Password';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) {
                          if (controller.userId.text.isNotEmpty &&
                              controller.password.text.isNotEmpty) {
                            controller.loginApiCall();
                          }
                          // else {
                          //   Get.snackbar("Invalid Credentials",
                          //       "Please enter Userid or Password");
                          // }
                        },
                        onSaved: (value) {
                          controller.password.text = value!;
                          controller.update(["homeScreen"]);
                        },
                      ),
                      // CustomTextFormField(
                      //   isBool: true,
                      //   customText: "Password",
                      //   label: "Password",
                      //   obsercureText: !controller.isVisible.value,
                      //   controller: controller.password,
                      //   iconss: GestureDetector(
                      //       onTap: () {
                      //         controller.isVisible.value =
                      //             !controller.isVisible.value;
                      //         controller.update(["homeScreen"]);
                      //       },
                      //       onDoubleTap: () {},
                      //       child: !controller.isVisible.value
                      //           ? Icon(Icons.visibility_off_sharp,
                      //               color: ConstColors.modelSheet, size: 25.sp)
                      //           : Icon(Icons.visibility_outlined,
                      //               color: ConstColors.modelSheet, size: 25.sp)),
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter your Password';
                      //     }
                      //     return null;
                      //   },
                      //   inputFormatters: [
                      //     FilteringTextInputFormatter.allow(
                      //         RegExp('[a-zA-Z0-9@#£_&-+.()\$/*":;!?€¥¢^=-]')),
                      //     LengthLimitingTextInputFormatter(20),
                      //   ],
                      //   readOnly: false,
                      //   onChanged: (value) {
                      //     // controller.password.text = value;
                      //     controller.update(["homeScreen"]);
                      //   },
                      //   onSaved: (value) {
                      //     controller.password.text = value!;
                      //     controller.update(["homeScreen"]);
                      //   },
                      // ),
                      // const Spacer(),
                      const Gap(50),
                      RoundedButton(
                        radius: 12,
                        press: (controller.userId.text.isNotEmpty &&
                                controller.password.text.isNotEmpty)
                            ? () {
                                controller.loginApiCall();
                              }
                            : null,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: (controller.userId.text.isNotEmpty &&
                                  controller.password.text.isNotEmpty)
                              ? ConstColors.white.withOpacity(0.90)
                              : ConstColors.white.withOpacity(0.30),
                          fontSize: 10.sp,
                        ),
                        bordercolor: (controller.userId.text.isNotEmpty &&
                                controller.password.text.isNotEmpty)
                            ? ConstColors.green
                            : ConstColors.black.withOpacity(0.30),
                        text: "Log In",
                      ).toProgress(controller.isLoading, h: 30, w: 30),
                      Gap(20.h)
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
