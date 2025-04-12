import 'package:aditya_birla/Constant/const_colors.dart';
import 'package:aditya_birla/Screens/ExitWeb_Screen/Controller/exitWeb_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

// Note: Removed ScreenUtil for better web compatibility
class ExitWebScreen extends GetView<ExitWebController> {
  const ExitWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive values
    // final contentWidth = screenWidth * 0.8;
    final qrScannerHeight = screenHeight * 0.3;
    final qrScannerWidth = screenWidth * 0.4;

    return GetBuilder(
      init: ExitWebController(),
      id: "ExitWebScreen",
      builder: (_) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(screenWidth, 75),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: AppBar(
                centerTitle: true,
                // leading: Image.asset(
                //   "assets/images/parkingLogo.png",
                //   fit: BoxFit.fill,
                // ),
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Image.asset(
                          "assets/images/ablogo.png",
                          width: 80,
                          height: 70,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          "Parking Management",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D2D2D),
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () async {
                              await GetStorage().remove("authToken");
                              await GetStorage().erase();

                              if (kIsWeb) {
                                Get.offAllNamed("/login_web_screen");
                              } else {
                                Get.offAllNamed("/login_screen");
                              }
                              //Get.offAllNamed('/login_web_screen');
                            },
                            icon: const Icon(
                              Icons.logout_outlined,
                              color: ConstColors.black,
                              size: 22,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Logout",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF2D2D2D),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // actions: [
                //   Padding(
                //     padding: EdgeInsets.only(right: 20),
                //     child: IconButton(
                //       onPressed: () {
                //         Get.offAllNamed('/login_web_screen');
                //       },
                //       icon: Icon(
                //         Icons.logout_outlined,
                //         color: ConstColors.black,
                //         size: 25,
                //       ),
                //     ),
                //   ),
                // ],
                backgroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ),
          backgroundColor: const Color(0xFFF5F5F5),
          body: Container(
            margin: EdgeInsets.symmetric(vertical: 20.h),
            width: screenWidth,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // QR Scanner Section
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => controller.scan(),
                      child: Container(
                        height: qrScannerHeight,
                        width: qrScannerWidth,
                        margin: EdgeInsets.symmetric(vertical: 0.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "TAP HERE TO SCAN QR...",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: const Color(0xFF2D2D2D),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Vehicle Number Input
                  Container(
                    margin: EdgeInsets.only(top: 20.h),
                    constraints: BoxConstraints(maxWidth: screenWidth * 0.4),
                    child: TextFormField(
                      controller: controller.outputController,
                      inputFormatters: [
                        //LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]')),
                      ],
                      decoration: InputDecoration(
                        hintText: "Please enter vehicle number",
                        hintStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        suffixIcon: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: IconButton(
                            icon:
                                const Icon(Icons.search, color: Colors.black87),
                            onPressed: () =>
                                controller.getVehicleEntryData(false),
                          ),
                        ),
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.green, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        controller.outputController.text =
                            value.trim().toUpperCase();

                        controller.outputController.selection =
                            TextSelection.fromPosition(
                          TextPosition(
                              offset: controller.outputController.text.length),
                        );

                        // controller.update(['ExitWebScreen']);
                      },
                      onFieldSubmitted: (value) =>
                          kIsWeb ? controller.getVehicleEntryData(false) : null,
                      // onSaved: (value) {
                      //   controller.outputController.text =
                      //       value!.trim().toUpperCase();
                      // },
                    ),
                  ),

                  // Payment Section
                  if (controller.paymentAmount.text.isNotEmpty)
                    Container(
                      constraints: BoxConstraints(maxWidth: screenWidth * 0.4),
                      child: Column(
                        children: [
                          const Gap(24),
                          TextField(
                            controller: controller.paymentAmount,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: "Amount to pay:",
                              labelStyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                              border: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                            ),
                          ),
                          const Gap(20),
                          // Payment Type Dropdown

                          DropdownButtonFormField<String>(
                            value: controller.paymentType,
                            decoration: const InputDecoration(
                              labelText: 'Please select payment type:',
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                            ),
                            items: controller.paymentsTypeList
                                .map((value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              controller.paymentType = value!;
                              controller.update(["ExitWebScreen"]);
                            },
                          ),
                          const Gap(30),
                          // Checkout Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: (controller.paymentType != null &&
                                      controller
                                          .outputController.text.isNotEmpty)
                                  ? () => controller.getVehicleEntryData(true)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Check Out',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (controller.paymentAmount.text.isEmpty)
                    Lottie.asset(
                        repeat: true,
                        'assets/lottie/parking.json',
                        filterQuality: FilterQuality.high,
                        height: Get.height / 2.5),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
