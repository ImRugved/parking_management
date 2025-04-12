import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final token = GetStorage().read("authToken");
    // If no token, redirect to login page
    if (token == null) {
      return const RouteSettings(name: '/login_web_screen');
    }
    return null;
  }
}
