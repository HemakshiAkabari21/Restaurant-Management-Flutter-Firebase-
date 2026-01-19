import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/screens/authentication/login_screen/login_controller.dart';
import 'package:restaurant_management_fierbase/screens/authentication/sign_up_screen/sign_up_screen.dart';
import 'package:restaurant_management_fierbase/widgets/custom_button.dart';
import 'package:restaurant_management_fierbase/widgets/custom_text_field.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {

  LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: Get.height,
          width: Get.width,
          child: Column(
            children: [
              SizedBox(height: 150.h),
              Text("Hello!Again",style: StyleHelper.customStyle(color: AppColors.black,size: 26.sp,family: semiBold),),
              CustomTextField(
                controller: loginController.emailController,
                topMargin: 26.h,
                fillColor: AppColors.white,
                filled: true,
                labelText: 'E-mail',
                labelStyle: StyleHelper.customStyle(color: AppColors.black),
              ),
              Obx(()=> CustomTextField(
                  controller: loginController.passwordController,
                  topMargin: 6.h,
                  fillColor: AppColors.white,
                  filled: true,
                  labelText: 'Password',
                  obscureText: loginController.isPass.value,
                  suffixIcon: GestureDetector(
                    onTap: (){
                      loginController.isPass.toggle();
                    },
                    child: Icon(  loginController.isPass.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,size: 24.sp,color: AppColors.black,).paddingOnly(right: 16.w),
                  ),
                  labelStyle: StyleHelper.customStyle(color: AppColors.black),
                ),
              ),
              CustomButton(
                onTap: (){
                  if(loginController.isValid()){
                    loginController.loginUser();
                  }
                },
                color: AppColors.black,
                topMargin: 50.h,
                height: 40.h,
                text: 'Login'.toUpperCase(),
                textStyle: StyleHelper.customStyle(color: AppColors.white,size: 16.sp,family: semiBold),
              ),
              Center(child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don\'t have an account? ',style: StyleHelper.customStyle(color: AppColors.black,size: 12.sp,),textAlign: TextAlign.center,).paddingOnly(top: 10.h),
                  GestureDetector(
                    onTap: (){Get.to(()=>SignUpScreen());},
                      child: Text('Sign up',style: StyleHelper.customStyle(color: AppColors.primaryColor,size: 12.sp,family: semiBold),))
                ],
              ))
            ],
          ).paddingSymmetric(horizontal: 16.w,),
        ),
      ),
    );
  }
}
