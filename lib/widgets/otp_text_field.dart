import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';

class OtpInputRow extends StatefulWidget {
  const OtpInputRow({super.key});

  @override
  State<OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<OtpInputRow> {
  final int otpLength = 4;
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers =
        List.generate(otpLength, (index) => TextEditingController());
    focusNodes = List.generate(otpLength, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next field
      if (index + 1 < otpLength) {
        FocusScope.of(context).requestFocus(focusNodes[index + 1]);
      } else {
        focusNodes[index].unfocus(); // last field, dismiss keyboard
      }
    } else {
      // If empty, move to previous field
      if (index > 0) {
        FocusScope.of(context).requestFocus(focusNodes[index - 1]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        otpLength,
            (index) => Container(
              height: 60.h,
              width: 60.w,
              padding: EdgeInsets.symmetric( horizontal:30.w,vertical: 16.h),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.gray1,
                borderRadius: BorderRadius.circular(12.r),
              ),
          child: TextFormField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            textAlign: TextAlign.left,
            style:  TextStyle(color: Colors.white, fontSize: 20.sp),
            keyboardType: TextInputType.number,
            maxLength: 1,
            cursorColor: Colors.white,
           /* decoration: InputDecoration(
              counterText: "",
              filled: true,
              hintText: '0',
              hintStyle: StyleHelper.customStyle(color: AppColors.white),
              fillColor: Colors.grey.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),*/
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              hintText: '0',
              hintStyle: StyleHelper.customStyle(color: AppColors.white),
              fillColor: Colors.grey.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),

            ),

            onChanged: (value) => _onChanged(value, index),
          ),
        ),
      ),
    );
  }
}
