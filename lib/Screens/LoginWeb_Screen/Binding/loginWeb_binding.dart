import 'package:get/get.dart';
import 'package:aditya_birla/Screens/LoginWeb_Screen/Controllr/loginWeb_controller.dart';

class LoginWebBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginWebController>(
      () => LoginWebController(),
    );
  }
}
