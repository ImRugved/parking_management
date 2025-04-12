import 'package:get/get.dart';
import 'package:aditya_birla/Screens/ExitWeb_Screen/Controller/exitWeb_controller.dart';

class ExitWebBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExitWebController>(
      () => ExitWebController(),
    );
  }
}
