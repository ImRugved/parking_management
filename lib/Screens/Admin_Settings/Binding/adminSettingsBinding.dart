import 'package:aditya_birla/Screens/Admin_Settings/Controller/adminSettingsController.dart';
import 'package:get/get.dart';

class AdminSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AdminSettingsController>(AdminSettingsController());
  }
}
