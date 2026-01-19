import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/screens/authentication/login_screen/log_in_screen.dart';
import 'package:restaurant_management_fierbase/screens/main_screen/main_screen.dart';
import 'package:restaurant_management_fierbase/utils/const_images_key.dart';
import 'package:restaurant_management_fierbase/utils/const_keys.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  ///  Navigate next
  void navigateNext() {
    bool isLogin = getStorage.read(IS_LOGIN) ?? false;
    Future.delayed(const Duration(seconds: 2), () {
      if (isLogin) {
        Get.offAll(() => const MainScreen());
      } else {
        Get.offAll(() => const LogInScreen());
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    navigateNext();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(child: Image.asset(AppImages.splashImg,fit: BoxFit.fill,)),
    );
  }

}
