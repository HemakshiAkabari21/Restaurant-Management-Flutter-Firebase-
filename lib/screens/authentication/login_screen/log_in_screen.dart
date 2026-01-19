import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/screens/authentication/login_screen/login_controller.dart';
import 'package:restaurant_management_fierbase/screens/authentication/sign_up_screen/sign_up_screen.dart';
import 'package:restaurant_management_fierbase/utils/const_images_key.dart';
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
      backgroundColor: AppColors.black,
      body: SingleChildScrollView(
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: Get.height,
                width: Get.width,
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage(AppImages.splashImg))
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: Get.height,
                decoration: BoxDecoration(
                  color: AppColors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r),bottomLeft: Radius.circular(40.r))
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Hello!Again",style: StyleHelper.customStyle(color: AppColors.black,size: 16.sp,family: semiBold),),
                    CustomTextField(
                      controller: loginController.emailController,
                      height: 50.h,
                      topMargin: 26.h,
                      fillColor: AppColors.white,
                      filled: true,
                      labelText: 'E-mail',
                      labelStyle: StyleHelper.customStyle(color: AppColors.black,size: 8.sp),
                    ),
                    Obx(()=> CustomTextField(
                      controller: loginController.passwordController,
                      topMargin: 6.h,
                      height: 50.h,
                      fillColor: AppColors.white,
                      filled: true,
                      labelText: 'Password',
                      obscureText: loginController.isPass.value,
                      suffixIcon: GestureDetector(
                        onTap: (){
                          loginController.isPass.toggle();
                        },
                        child: Icon(  loginController.isPass.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,size: 10.sp,color: AppColors.black,).paddingOnly(right: 2.w),
                      ),
                      labelStyle: StyleHelper.customStyle(color: AppColors.black,size: 8.sp),
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
                      bottomMargin: 10.h,
                      height: 60.h,
                      text: 'Login'.toUpperCase(),
                      textStyle: StyleHelper.customStyle(color: AppColors.white,size: 10.sp,family: semiBold),
                    ),
                    Center(child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Don\'t have an account? ',style: StyleHelper.customStyle(color: AppColors.black,size: 6.sp,),textAlign: TextAlign.center,).paddingOnly(top: 10.h),
                        GestureDetector(
                            onTap: (){Get.to(()=>SignUpScreen(),transition: Transition.leftToRightWithFade,duration: Duration(milliseconds: 1000));},
                            child: Text('Sign up',style: StyleHelper.customStyle(color: AppColors.primaryColor,size: 6.sp,family: semiBold),))
                      ],
                    ))
                  ],
                ).paddingSymmetric(horizontal: 16.w,),
              ),
            )
          ],
        ),
      ),
    );
  }
}
