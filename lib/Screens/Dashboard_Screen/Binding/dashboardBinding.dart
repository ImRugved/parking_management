import 'package:aditya_birla/Screens/Login_Screen/Controller/loginController.dart';
import 'package:get/get.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LoginController>(LoginController(), permanent: true);
  }
}
