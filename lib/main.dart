import 'dart:io' as i;

import 'package:aditya_birla/Utils/Routes.dart';
import 'package:aditya_birla/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  if (kIsWeb) {
    // Web-specific orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  } else if (i.Platform.isAndroid || i.Platform.isIOS) {
    // Mobile-specific orientation (portrait)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } else {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final box = GetStorage();

  @override
  void initState() {
    super.initState();

    // //  Add a listener to the beforeunload event
    // html.window.onBeforeUnload.listen((event) {
    //   // Clear GetStorage when the window or tab is being closed
    //   box.erase(); // This clears all stored data in GetStorage
    // });
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      child: ScreenUtilInit(
        //designSize: const Size(1920, 1080),
        useInheritedMediaQuery: true,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, state) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Parking Management System",
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            initialRoute: '/splash_screen',
            getPages: Routes.pages,
            //home: ExitWebScreen(),
          );
        },
      ),
    );
  }
}
