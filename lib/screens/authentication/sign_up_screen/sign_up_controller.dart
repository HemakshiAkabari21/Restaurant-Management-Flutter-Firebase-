import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/user_detail_model.dart';
import 'package:restaurant_management_fierbase/screens/main_layout_screen/main_layout_screen.dart';
import 'package:restaurant_management_fierbase/utils/const_keys.dart';
import 'package:restaurant_management_fierbase/widgets/common_widget.dart';

class SignUpController extends GetxController {

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  RxString userType = 'Manager'.obs;

  RxBool isPass = false.obs;
  RxBool isConfirmPass = false.obs;

/*  addUser()async{
    final userId = await RealtimeDbHelper.instance.pushData(
      path: 'users',
      data: {
        'name': nameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'password': passwordController.text.trim(),
        'email': emailController.text.trim(),
        'user_type':userType.value,
        'createdAt': DateTime.now(),
      },
    );
    debugPrint("User ID: $userId");
    if(userId != null || (userId?.isNotEmpty ?? false)){
      getStorage.write(IS_LOGIN, true);
      Get.to(()=>HomeScreen());
    }
  }*/

  Future<void> addUser() async {
    if (!isValid()) return;

    final email = emailController.text.trim();

    final existingUser = await RealtimeDbHelper.instance.getUserByEmail(email);

    if (existingUser != null) {
      showErrorSnackBar(  title: 'Error', message: 'This email is already in use',);
      return;
    }

    final user = UserDetail(
      id: '',
      name: nameController.text.trim(),
      email: email,
      mobile: mobileController.text.trim(),
      password: passwordController.text.trim(),
      userType: userType.value,
      createdAt: DateTime.now().toIso8601String(),
    );

    final userId = await RealtimeDbHelper.instance.pushData(path: 'users', data: user.toMap());

    debugPrint("User ID: $userId");

    if(userId != null || (userId?.isNotEmpty ?? false)){
      final loggedInUser = user.copyWith(id: userId);
      getStorage.write(USER_ID, userId);
      getStorage.write(USER_DETAIL, loggedInUser.toMap());
      debugPrint("Stored user: ${loggedInUser.toMap()}");
      getStorage.write(IS_LOGIN, true);
      debugPrint("UserType Save in Sign Up screen ::::::::: ${getStorage.read(USER_TYPE)}");
      Get.offAll(()=>MainLayoutScreen());
      showErrorSnackBar(title: 'Success', message: 'User registered successfully',color: AppColors.green);
    }
  }

  bool isValid(){
    if(nameController.text.trim().isEmpty){
      showErrorSnackBar(title: "Error", message: "Please enter the name");
      return false;
    }
    if(mobileController.text.trim().isEmpty){
      showErrorSnackBar(title: "Error", message: "Please enter the mobile number");
      return false;
    }
    if(mobileController.text.length != 10){
      showErrorSnackBar(title: "Error", message: "Please enter the valid mobile number");
      return false;
    }
    if(emailController.text.trim().isEmpty){
      showErrorSnackBar(title: "Error", message: "Please enter the email");
      return false;
    }
    if(passwordController.text.trim().isEmpty){
      showErrorSnackBar(title: "Error", message: "Please enter the password");
      return false;
    }
    if(confirmPasswordController.text.trim().isEmpty){
      showErrorSnackBar(title: "Error", message: "Please enter confirm password");
      return false;
    }
    if(passwordController.text.trim() != confirmPasswordController.text.trim()){
      showErrorSnackBar(title: "Error", message: "The password and confirm-password dose not match");
      return false;
    }
    return true;
  }
}