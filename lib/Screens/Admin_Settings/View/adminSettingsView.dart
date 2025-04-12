import 'package:aditya_birla/Constant/const_colors.dart';
import 'package:aditya_birla/Constant/custom_textstyle.dart';
import 'package:aditya_birla/Constant/loading.dart';
import 'package:aditya_birla/Constant/rounded_button.dart';
import 'package:aditya_birla/Screens/Admin_Settings/Controller/adminSettingsController.dart';
import 'package:aditya_birla/Screens/Admin_Settings/Controller/location_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSettingsView extends GetView<AdminSettingsController> {
  const AdminSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();

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
            "Parking Settings",
            style: getTextTheme().headlineLarge,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: ConstColors.white,
          surfaceTintColor: ConstColors.backgroundColor,
        ),
      ),
      body: GetBuilder<AdminSettingsController>(
        id: "rates",
        builder: (controller) {
          return controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location Management Section
                        Text(
                          "Location Management",
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: ConstColors.black,
                          ),
                        ),
                        Gap(10.h),
                        Text(
                          "Add and manage parking locations",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Gap(20.h),

                        // Add Location Form
                        Container(
                          padding: EdgeInsets.all(15.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Add New Location",
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Gap(15.h),
                              TextField(
                                controller:
                                    locationController.locationNameController,
                                decoration: InputDecoration(
                                  labelText: "Location Name",
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15.w,
                                    vertical: 12.h,
                                  ),
                                ),
                              ),
                              Gap(15.h),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (locationController
                                        .locationNameController
                                        .text
                                        .isNotEmpty) {
                                      locationController.addLocation(
                                          locationController
                                              .locationNameController.text);
                                    } else {
                                      Get.snackbar(
                                        "Error",
                                        "Please enter a location name",
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ConstColors.green,
                                    foregroundColor: Colors.white,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12.h),
                                  ),
                                  child: Text("Add Location"),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Gap(30.h),

                        // Existing Locations List
                        Text(
                          "Existing Locations",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Gap(15.h),
                        Obx(() => locationController.locations.isEmpty
                            ? Center(
                                child: Text(
                                  "No locations added yet",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: locationController.locations.length,
                                itemBuilder: (context, index) {
                                  final location =
                                      locationController.locations[index];
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 10.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        location.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 20.sp,
                                        ),
                                        onPressed: () {
                                          Get.dialog(
                                            AlertDialog(
                                              title: Text("Delete Location"),
                                              content: Text(
                                                  "Are you sure you want to delete this location?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Get.back(),
                                                  child: Text("Cancel"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Get.back();
                                                    locationController
                                                        .deleteLocation(
                                                            location.id);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    foregroundColor:
                                                        Colors.white,
                                                  ),
                                                  child: Text("Delete"),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              )),
                        Gap(40.h),

                        // Parking Rates Section
                        Text(
                          "Parking Rate Settings",
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: ConstColors.black,
                          ),
                        ),
                        Gap(10.h),
                        Text(
                          "Configure parking rates for different vehicle types",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Gap(20.h),

                        // First Hours Bracket Selector
                        Text(
                          "First Hours Bracket",
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: ConstColors.black,
                          ),
                        ),
                        Gap(10.h),
                        Text(
                          "Select the number of hours for the first rate bracket:",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Gap(15.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            5,
                            (index) {
                              final hours = index + 1;
                              return GestureDetector(
                                onTap: () {
                                  controller.updateFirstHoursBracket(hours);
                                },
                                child: Container(
                                  width: 50.w,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    color: controller.firstHoursBracket.value ==
                                            hours
                                        ? ConstColors.green
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: ConstColors.green,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "$hours",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: controller
                                                    .firstHoursBracket.value ==
                                                hours
                                            ? Colors.white
                                            : ConstColors.green,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Gap(25.h),

                        // Two Wheeler Rates
                        ratesSectionTitle("Two Wheeler Rates (₹)"),
                        Gap(15.h),
                        rateInputField(
                          "First ${controller.firstHoursBracket.value} Hours Rate:",
                          controller.twoWheelerFirstHoursRate,
                        ),
                        Gap(10.h),
                        rateInputField(
                          "After ${controller.firstHoursBracket.value} Hours (hourly):",
                          controller.twoWheelerEveryHoursRate,
                        ),
                        Gap(10.h),
                        rateInputField(
                          "24 Hours Rate:",
                          controller.twoWheeler24HoursRate,
                        ),
                        Gap(25.h),

                        // Four Wheeler Rates
                        ratesSectionTitle("Four Wheeler Rates (₹)"),
                        Gap(15.h),
                        rateInputField(
                          "First ${controller.firstHoursBracket.value} Hours Rate:",
                          controller.fourWheelerFirstHoursRate,
                        ),
                        Gap(10.h),
                        rateInputField(
                          "After ${controller.firstHoursBracket.value} Hours (hourly):",
                          controller.fourWheelerEveryHoursRate,
                        ),
                        Gap(10.h),
                        rateInputField(
                          "24 Hours Rate:",
                          controller.fourWheeler24HoursRate,
                        ),
                        Gap(40.h),

                        // Update Button
                        Center(
                          child: RoundedButton(
                            press: () {
                              controller.updateVehicleRates();
                            },
                            text: "Update Rates",
                          ).toProgress(controller.isLoading),
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

  Widget ratesSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: ConstColors.green,
          ),
        ),
        Divider(
          color: ConstColors.green.withOpacity(0.5),
          thickness: 1,
        ),
      ],
    );
  }

  Widget rateInputField(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: ConstColors.black,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ConstColors.green.withOpacity(0.5),
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
