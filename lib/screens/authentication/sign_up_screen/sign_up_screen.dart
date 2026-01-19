import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/screens/authentication/login_screen/log_in_screen.dart';
import 'package:restaurant_management_fierbase/screens/authentication/sign_up_screen/sign_up_controller.dart';
import 'package:restaurant_management_fierbase/utils/const_images_key.dart';
import 'package:restaurant_management_fierbase/widgets/custom_button.dart';
import 'package:restaurant_management_fierbase/widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  SignUpController signUpController = Get.put(SignUpController());

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
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(40.r),bottomRight: Radius.circular(40.r))
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hello!Welcome",textAlign: TextAlign.start,style: StyleHelper.customStyle(color: AppColors.black, size: 16.sp, family: semiBold)).paddingOnly(top: 25.h,left: 8.w),
                    Column(
                      children: [
                        CustomTextField(
                          controller: signUpController.nameController,
                          topMargin: 16.h,
                          fillColor: AppColors.white,
                          filled: true,
                          labelText: 'Name',
                          labelStyle: StyleHelper.customStyle(color: AppColors.black,size: 6.sp),
                        ),
                        CustomTextField(
                          controller: signUpController.mobileController,
                          topMargin: 6.h,
                          height: 50.h,
                          fillColor: AppColors.white,
                          maxLength: 10,
                          keyboardType: Platform.isIOS ? TextInputType.phone : TextInputType.number,
                          filled: true,
                          labelText: 'Mobile',
                          labelStyle: StyleHelper.customStyle(color: AppColors.black,size: 6.sp),
                        ).paddingSymmetric(vertical: 16.h),
                        CustomTextField(
                          controller: signUpController.emailController,
                          height: 50.h,
                          topMargin: 6.h,
                          fillColor: AppColors.white,
                          filled: true,
                          labelText: 'E-mail',
                          labelStyle: StyleHelper.customStyle(color: AppColors.black,size: 6.sp),
                        ),
                        CustomTextField(
                          controller: signUpController.passwordController,
                          topMargin: 6.h,
                          fillColor: AppColors.white,
                          obscureText: signUpController.isPass.value,
                          filled: true,
                          labelText: 'Password',
                          suffixIcon: GestureDetector(
                            onTap: () {
                              signUpController.isPass.toggle();
                            },
                            child: Icon(
                              signUpController.isPass.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: 10.sp,
                              color: AppColors.black,
                            ).paddingOnly(right: 2.w),
                          ),
                          labelStyle: StyleHelper.customStyle(color: AppColors.black,size: 6.sp),
                        ).paddingSymmetric(vertical: 16.h),
                        CustomTextField(
                          controller: signUpController.confirmPasswordController,
                          topMargin: 6.h,
                          fillColor: AppColors.white,
                          obscureText: signUpController.isConfirmPass.value,
                          filled: true,
                          labelText: 'Confirm Password',
                          suffixIcon: GestureDetector(
                            onTap: () {
                              signUpController.isConfirmPass.toggle();
                            },
                            child: Icon(
                              signUpController.isConfirmPass.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: 10.sp,
                              color: AppColors.black,
                            ).paddingOnly(right: 2.w),
                          ),
                          labelStyle: StyleHelper.customStyle(color: AppColors.black,size: 6.sp),
                        ),
                        Obx(
                              () => Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  signUpController.userType.value = 'Manager';
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      signUpController.userType.value == 'Manager' ? Icons.radio_button_checked_sharp : Icons.radio_button_off,
                                      size: 10.sp,
                                      color: AppColors.black,
                                    ),
                                    Text(
                                      'Manager',
                                      style: StyleHelper.customStyle(color: AppColors.black, size: 6.sp, family: semiBold),
                                    ).paddingOnly(right: 16.w, left: 8.w),
                                  ],
                                ),
                              ),

                              GestureDetector(
                                onTap: () {
                                  signUpController.userType.value = 'Cashier';
                                },
                                child: Row(
                                  children: [
                                    Icon(signUpController.userType.value == 'Cashier' ? Icons.radio_button_checked_sharp : Icons.radio_button_off, size: 10.sp, color: AppColors.black),
                                    Text('Cashier', style: StyleHelper.customStyle(color: AppColors.black, size: 6.sp, family: semiBold)).paddingOnly(left: 8.w),
                                  ],
                                ),
                              ),
                            ],
                          ).paddingOnly(top: 16.h),
                        ),
                        CustomButton(
                          onTap: () {
                            if(signUpController.isValid()){
                              signUpController.addUser();
                            }
                          },
                          color: AppColors.black,
                          topMargin: 30.h,
                          height: 60.h,
                          text: 'Signup'.toUpperCase(),
                          textStyle: StyleHelper.customStyle(color: AppColors.white, size: 8.sp, family: semiBold),
                        ),
                        Center(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: StyleHelper.customStyle(color: AppColors.black, size: 4.sp),
                                textAlign: TextAlign.center,
                              ).paddingOnly(top: 10.h),
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => LogInScreen());
                                },
                                child: Text('Log in', style: StyleHelper.customStyle(color: AppColors.primaryColor, size:4.sp, family: semiBold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 16.w),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: Get.height,
                width: Get.width,
                decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage(AppImages.splashImg))
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
