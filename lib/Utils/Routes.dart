import 'package:aditya_birla/Screens/Admin_Reports/Binding/adminReportsBinding.dart';
import 'package:aditya_birla/Screens/Admin_Reports/View/adminReportsView.dart';
import 'package:aditya_birla/Screens/Admin_Settings/Binding/adminSettingsBinding.dart';
import 'package:aditya_birla/Screens/Admin_Settings/View/adminSettingsView.dart';
import 'package:aditya_birla/Screens/Admin_Dashboard/Binding/adminDashboardBinding.dart';
import 'package:aditya_birla/Screens/Admin_Dashboard/View/adminDashboardView.dart';
import 'package:aditya_birla/Screens/Dashboard_Screen/Binding/dashboardBinding.dart';
import 'package:aditya_birla/Screens/Dashboard_Screen/first_Screen.dart';
import 'package:aditya_birla/Screens/ExitScreen/Binding/exitBinding.dart';
import 'package:aditya_birla/Screens/ExitScreen/View/exitScreen.dart';
import 'package:aditya_birla/Screens/ExitWeb_Screen/Binding/exitWeb_binding.dart';
import 'package:aditya_birla/Screens/ExitWeb_Screen/Controller/auth_middleware.dart';
import 'package:aditya_birla/Screens/ExitWeb_Screen/View/exitWeb_page.dart';
import 'package:aditya_birla/Screens/HomeScreen/Binding/homeBinding.dart';
import 'package:aditya_birla/Screens/HomeScreen/Body/bike_screen.dart';
import 'package:aditya_birla/Screens/HomeScreen/Body/car_screen.dart';
import 'package:aditya_birla/Screens/HomeScreen/View/homeScreen.dart';
import 'package:aditya_birla/Screens/LoginWeb_Screen/Binding/loginWeb_binding.dart';
import 'package:aditya_birla/Screens/LoginWeb_Screen/View/loginWeb_page.dart';
import 'package:aditya_birla/Screens/Login_Screen/Binding/loginBinding.dart';
import 'package:aditya_birla/Screens/Login_Screen/View/loginPage.dart';
import 'package:aditya_birla/Screens/Signup_Screen/Binding/signupBinding.dart';
import 'package:aditya_birla/Screens/Signup_Screen/View/signupPage.dart';
import 'package:aditya_birla/Screens/Splash_Screen/splashScreen.dart';
import 'package:aditya_birla/Screens/Master_First_Screen/master_first_screen.dart';
import 'package:aditya_birla/Screens/Master_First_Screen/Controller/masterBinding.dart';
import 'package:aditya_birla/Screens/Admin_First_Screen/admin_first_screen.dart';
import 'package:get/get.dart';

class Routes {
  static final pages = [
    //Splash screen
    GetPage(name: '/splash_screen', page: () => const SplashScreen()),

    //First Dashboard screen
    GetPage(
        name: '/first_screen',
        page: () => const FirstScreen(),
        binding: DashboardBinding()),

    //Master First Screen
    GetPage(
        name: '/master_first_screen',
        page: () => const MasterFirstScreen(),
        binding: MasterBinding()),

    //Admin First Screen
    GetPage(name: '/admin_first_screen', page: () => const AdminFirstScreen()),

    //Home page screen
    GetPage(
        name: '/home_screen',
        page: () => const HomeScreen(),
        binding: HomeBinding()),

    //bike page screen
    GetPage(
        name: '/bike_screen',
        page: () => BikeScreenPage(),
        binding: HomeBinding()),

    //car page screen
    GetPage(
        name: '/car_screen',
        page: () => CarScreenPage(),
        binding: HomeBinding()),

    //Login page Screen
    GetPage(
        name: '/login_screen',
        page: () => const LoginPageScreen(),
        binding: LoginBinding()),

    //Signup page Screen
    GetPage(
        name: '/signup',
        page: () => const SignUpPageScreen(),
        binding: SignupBinding()),

    //Login web screen
    GetPage(
        name: '/login_web_screen',
        page: () => const LoginWebPageScreen(),
        binding: LoginWebBinding()),

    //Exit page screen
    GetPage(
        name: '/exit_screen',
        page: () => const ExitScreen(),
        binding: ExitBinding()),

    //Exit web screen
    GetPage(
        name: '/exit_web_screen',
        page: () => const ExitWebScreen(),
        binding: ExitWebBinding(),
        middlewares: [AuthMiddleware()]),

    //Admin Settings Screen
    GetPage(
        name: '/admin_settings',
        page: () => const AdminSettingsView(),
        binding: AdminSettingsBinding()),

    //Admin Reports Screen
    GetPage(
        name: '/admin_reports',
        page: () => const AdminReportsView(),
        binding: AdminReportsBinding()),

    //Admin Dashboard Screen
    GetPage(
        name: '/admin_dashboard',
        page: () => const AdminDashboardView(),
        binding: AdminDashboardBinding()),
  ];
}

// why agian the diaog box is showng when i navigate back form admin screen without login i dont want agian to enter admin access code for seeing the admin functionaty i shuld directly navigate to admin acces screen till i logout form admin access screen
