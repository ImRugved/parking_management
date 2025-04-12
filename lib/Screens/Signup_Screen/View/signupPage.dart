import 'package:aditya_birla/Constant/const_colors.dart';
import 'package:aditya_birla/Constant/custom_textfield.dart';
import 'package:aditya_birla/Constant/loading.dart';
import 'package:aditya_birla/Constant/rounded_button.dart';
import 'package:aditya_birla/Screens/Login_Screen/Controller/loginController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPageScreen extends GetView<LoginController> {
  const SignUpPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.white,
      body: GetBuilder<LoginController>(
        id: "signupScreen",
        builder: (controller) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(35.h),
                  Center(
                    child: Image.asset(
                      "assets/images/ablogo.png",
                      height: 100.h,
                      width: 140.w,
                    ),
                  ),
                  Center(
                    child: Text(
                      "Parking Management System",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D2D2D),
                        fontSize: 22,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Gap(20.h),
                  Center(
                    child: Text(
                      "Sign Up",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: ConstColors.green,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  Gap(20.h),
                  CustomTextFormField(
                    customText: "Full Name",
                    label: "Full Name",
                    controller: controller.nameController,
                    keyoardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    inputFormatters: const [],
                    onChanged: (value) {
                      controller.nameController.text = value;
                      controller.update(["signupScreen"]);
                    },
                  ),
                  Gap(20.h),
                  CustomTextFormField(
                    customText: "Email",
                    label: "Email",
                    controller: controller.userId,
                    keyoardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Please enter valid email';
                      }
                      return null;
                    },
                    inputFormatters: const [],
                    onChanged: (value) {
                      controller.userId.text = value;
                      controller.update(["signupScreen"]);
                    },
                  ),
                  Gap(20.h),
                  CustomTextFormField(
                    customText: "Password",
                    label: "Password",
                    obsercureText: !controller.isVisible.value,
                    controller: controller.password,
                    iconss: GestureDetector(
                      onTap: () {
                        controller.isVisible.value =
                            !controller.isVisible.value;
                        controller.update(["signupScreen"]);
                      },
                      child: !controller.isVisible.value
                          ? Icon(Icons.visibility_off_sharp,
                              color: ConstColors.modelSheet, size: 25.sp)
                          : Icon(Icons.visibility_outlined,
                              color: ConstColors.modelSheet, size: 25.sp),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp('[a-zA-Z0-9@#£_&-+.()\$/*":;!?€¥¢^=-]')),
                      LengthLimitingTextInputFormatter(20),
                    ],
                    readOnly: false,
                    onChanged: (value) {
                      controller.password.text = value;
                      controller.update(["signupScreen"]);
                    },
                  ),
                  Gap(20.h),
                  CustomTextFormField(
                    customText: "Organization Name",
                    label: "Organization Name",
                    controller: controller.organizationController,
                    keyoardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter organization name';
                      }
                      return null;
                    },
                    inputFormatters: const [],
                    onChanged: (value) {
                      controller.organizationController.text = value;
                      controller.update(["signupScreen"]);
                    },
                  ),
                  Gap(20.h),
                  CustomTextFormField(
                    customText: "Admin Code (Optional)",
                    label: "Admin Code (Optional)",
                    controller: controller.adminCodeController,
                    keyoardType: TextInputType.text,
                    validator: null,
                    inputFormatters: const [],
                    onChanged: (value) {
                      controller.adminCodeController.text = value;
                      controller.update(["signupScreen"]);
                    },
                  ),
                  Gap(30.h),
                  RoundedButton(
                    press: (controller.nameController.text.isNotEmpty &&
                            controller.userId.text.isNotEmpty &&
                            controller.password.text.isNotEmpty)
                        ? () {
                            controller.signUp();
                          }
                        : null,
                    bordercolor: (controller.nameController.text.isNotEmpty &&
                            controller.userId.text.isNotEmpty &&
                            controller.password.text.isNotEmpty)
                        ? ConstColors.green
                        : ConstColors.grey,
                    text: "Sign Up",
                  ).toProgress(controller.isLoading),
                  Gap(20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2D2D2D),
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.offAllNamed("/login_screen");
                        },
                        child: Text(
                          "Login",
                          style: GoogleFonts.poppins(
                            color: ConstColors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(20.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
