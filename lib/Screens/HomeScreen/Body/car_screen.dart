import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aditya_birla/Screens/HomeScreen/Controller/HomeController.dart';

class CarScreenPage extends GetView<HomeController> {
  const CarScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: HomeController(),
        id: "carScreen",
        builder: (_) {
          return const Placeholder();
        });
  }
}
