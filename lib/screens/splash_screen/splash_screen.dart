import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/screens/authentication/login_screen/log_in_screen.dart';
import 'package:restaurant_management_fierbase/screens/main_layout_screen/main_layout_screen.dart';
import 'package:restaurant_management_fierbase/screens/manager_screen/manager_screen.dart';
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
        if(getStorage.read(USER_TYPE) == 'Manager'){
         Get.offAll(()=>ManagerScreen());
        }else{
          Get.offAll(() => const MainLayoutScreen());
        }
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
