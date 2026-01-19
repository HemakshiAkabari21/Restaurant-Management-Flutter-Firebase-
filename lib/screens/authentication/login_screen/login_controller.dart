import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/screens/main_screen/main_screen.dart';
import 'package:restaurant_management_fierbase/utils/const_keys.dart';
import 'package:restaurant_management_fierbase/widgets/common_widget.dart';


class LoginController extends GetxController{

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  RxBool isPass = false.obs;


  bool isValid(){
    if(emailController.text.trim().isEmpty){
      showErrorSnackBar(title: "Error", message: "Please enter the email");
      return false;
    }
    if(passwordController.text.trim().isEmpty){
      showErrorSnackBar(title: "Error", message: "Please enter the password");
      return false;
    }
    return true;
  }

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final user = await RealtimeDbHelper.instance.getUserByEmail(email);
    debugPrint("user::::::::${user == null}");
    if (user == null) {
      showErrorSnackBar(title: 'Error', message: 'User not found');
      return;
    }
    if (user.password != password) {
      showErrorSnackBar(title: 'Error', message: 'Password is wrong');
      return;
    }
    getStorage.write(USER_ID, user.id);
    getStorage.write(USER_DETAIL, user.toMap());
    getStorage.write(IS_LOGIN, true);

    Get.offAll(() => MainScreen());
    showErrorSnackBar(title: 'Success', message: 'Login successful', color: AppColors.green);
  }

}