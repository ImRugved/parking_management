import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:aditya_birla/Screens/HomeScreen/Controller/HomeController.dart';
import 'package:aditya_birla/Constant/const_colors.dart';
import 'package:aditya_birla/Widgets/custom_textfield.dart';
import 'package:aditya_birla/Models/location_model.dart';

class CarScreenPage extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Text(
          "Car Entry",
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                Gap(20.h),
                Obx(() {
                  if (controller.locations.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(15.w),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 24.sp,
                          ),
                          Gap(10.w),
                          Expanded(
                            child: Text(
                              "No locations available. Please add locations from the admin dashboard.",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return DropdownButtonFormField<String>(
                    value: controller.selectedLocation.value.isEmpty
                        ? null
                        : controller.selectedLocation.value,
                    decoration: InputDecoration(
                      labelText: "Select Location",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 15.w,
                        vertical: 12.h,
                      ),
                    ),
                    items: controller.locations
                        .map((location) => DropdownMenuItem(
                              value: location.id,
                              child: Text(location.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        controller.selectedLocation.value = value;
                        var selectedLoc = controller.locations.firstWhere(
                            (loc) => loc.id == value,
                            orElse: () => ParkingLocation(
                                id: "", name: "Unknown", organizationId: ""));
                        print(
                            "Selected location in dropdown: ${selectedLoc.id} - ${selectedLoc.name}");
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a location';
                      }
                      return null;
                    },
                  );
                }),
                Gap(20.h),
                CustomTextField(
                  controller: controller.vehicleNo,
                  hintText: "Enter Vehicle Number",
                  prefixIcon: Icons.car_rental,
                ),
                Gap(20.h),
                Obx(() => DropdownButtonFormField<int>(
                      value: controller.selectedVehicle.value,
                      decoration: InputDecoration(
                        labelText: "Select Vehicle Type",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15.w,
                          vertical: 12.h,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 1,
                          child: Text("4 Wheeler"),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text("2 Wheeler"),
                        ),
                      ],
                      onChanged: (value) {
                        controller.selectedVehicle.value = value ?? 1;
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a vehicle type';
                        }
                        return null;
                      },
                    )),
                Gap(20.h),
                Obx(() => DropdownButtonFormField<String>(
                      value: controller.selectedCompany.value.isEmpty
                          ? null
                          : controller.selectedCompany.value,
                      decoration: InputDecoration(
                        labelText: "Select Company",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15.w,
                          vertical: 12.h,
                        ),
                      ),
                      items: controller.companies
                          .map((company) => DropdownMenuItem(
                                value: company.id,
                                child: Text(company.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        controller.selectedCompany.value = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a company';
                        }
                        return null;
                      },
                    )),
                Gap(20.h),
                Obx(() => controller.isLoading.value
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          if (controller.formKey.currentState!.validate()) {
                            controller.insertVehicleEntry();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: Size(1.sw, 50.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Submit",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
