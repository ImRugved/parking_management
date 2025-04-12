import 'package:get/get.dart';
import 'package:aditya_birla/Screens/Login_Screen/Controller/loginController.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LoginController>(LoginController(), permanent: true);
  }
}
