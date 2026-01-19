import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../apptheme/app_colors.dart';
import '../apptheme/stylehelper.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'common_widget.dart';


class CustomTextField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final String? initialValue;
  final String? title;
  final Color? borderColor;
  final Color? errorBorderColor;
  final Color? fillColor;
  final TextEditingController? controller;
  final TextCapitalization? textCapitalization;
  final double? height;
  final double? titleMargin;
  final double? width;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? titleStyle;
  final double? horizontalMargin;
  final double? topMargin;
  final double? bottomMargin;
  final int? maxLines;
  final bool? obscureText;
  final bool? filled;
  final bool? enabled;
  final bool? readOnly;
  final bool? alignLabelWithHint;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final int? maxLength;
  final double? borderRadius;
  final double? suffixIconMaxWidth;
  final double? suffixIconMinWidth;
  final Function(String)? onChanged;
  final Function()? onTap;
  final Function? validator;
  final TextStyle? hintStyle;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final TextAlign? textAlign;
  final FocusNode? focusNode;
  final EdgeInsets? contentPadding;
  final bool? isError;
  final String? errorText;
  final FloatingLabelBehavior? floatingLabelBehavior;

  const CustomTextField({
    super.key,
    this.prefix,
    this.hintText,
    this.labelText,
    this.initialValue,
    this.title,
    this.hintStyle,
    this.borderColor,
    this.validator,
    this.height,
    this.width,
    this.titleMargin,
    this.onChanged,
    this.textCapitalization,
    this.filled,
    this.alignLabelWithHint,
    this.fillColor,
    this.errorBorderColor,
    this.borderRadius,
    this.suffixIconMaxWidth,
    this.suffixIconMinWidth,
    this.textStyle,
    this.labelStyle,
    this.titleStyle,
    this.controller,
    this.obscureText,
    this.suffixIcon,
    this.maxLines,
    this.onTap,
    this.readOnly,
    this.textInputAction,
    this.keyboardType,
    this.horizontalMargin,
    this.contentPadding,
    this.topMargin,
    this.bottomMargin,
    this.inputFormatters,
    this.maxLength,
    this.enabled,
    this.focusNode,
    this.textAlign,
    this.isError,
    this.errorText,
    this.floatingLabelBehavior,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: horizontalMargin ?? 0,
          right: horizontalMargin ?? 0,
          top: topMargin ?? 5.h,
          bottom: bottomMargin ?? 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(title!=null)
            Text(title!.tr, style: titleStyle ?? StyleHelper.customStyle(family: medium)),
          Container(
            height: height ?? 45.h,
            width: width ?? Get.width,
            alignment: Alignment.center,
            margin:EdgeInsets.only(top: titleMargin ??  3.h),
            child: KeyboardActions(
              overscroll: 40.h,
              config: buildKeyboardActionsConfig(context,focusNode),
              disableScroll: true,
              child: TextFormField(
                focusNode: focusNode,
                cursorHeight: 20.h,
                textAlign: textAlign ?? TextAlign.start,
                initialValue: initialValue,
                inputFormatters: inputFormatters ?? [],
                controller: controller,
                obscureText: obscureText ?? false,
                obscuringCharacter: "●",
                enabled: enabled ?? true,
                textAlignVertical: TextAlignVertical.center,
                textInputAction: textInputAction ?? TextInputAction.next,
                keyboardType: keyboardType ?? TextInputType.text,
                textCapitalization: textCapitalization ?? TextCapitalization.sentences,
                onTap: onTap,
                onChanged: onChanged,
                validator: (value) {
                  if (validator != null) {
                    validator!.call(value);
                  }
                  return null;
                },
                maxLength: maxLength,
                style: textStyle ?? StyleHelper.customStyle(color: AppColors.black,size: 6.sp),
                readOnly: readOnly ?? false,
                decoration: InputDecoration(
                  hintText: hintText,
                  counterText: '',
                  labelText: labelText,
                  labelStyle: labelStyle ?? StyleHelper.customStyle(color: AppColors.black),
                  floatingLabelBehavior: floatingLabelBehavior,
                  alignLabelWithHint: alignLabelWithHint ?? false,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
                      borderSide: BorderSide(width: 1.w, color: borderColor ?? AppColors.primaryColor)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
                      borderSide: BorderSide(width: 1.w, color: isError ?? false ? AppColors.errorColor : AppColors.primaryColor)),
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
                      borderSide: BorderSide(width: 1.w, color: errorBorderColor ?? AppColors.primaryColor)),
                  focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(width: 1.w, color: errorBorderColor ?? AppColors.primaryColor)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
                      borderSide: BorderSide(width: 1.w, color: borderColor ?? AppColors.slateGray)),
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
                      borderSide: BorderSide(width: 1.w, color: borderColor ?? AppColors.black)),
                  fillColor: fillColor ?? AppColors.white,
                  filled: filled ?? false,
                  prefixIcon: prefix,
                  // prefixIconConstraints: BoxConstraints(maxWidth: prefix==null?15.w:40.w, minWidth: prefix==null?0:40.w),
                  suffixIcon: suffixIcon,
                  suffixIconConstraints: BoxConstraints(maxWidth: suffixIconMaxWidth ?? 40.w, minWidth: suffixIconMinWidth ?? 30.w),
                  contentPadding: contentPadding ?? EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  hintStyle: hintStyle ?? StyleHelper.customStyle(color: AppColors.darkGray,family: regular,size: 8.sp),
                ),
                maxLines: maxLines ?? 1,
                cursorColor: borderColor ?? AppColors.black,
              ),
            ),
          ),
          if(isError ?? false)Text(errorText ?? "",softWrap: true,maxLines: null,style: StyleHelper.customStyle(color: AppColors.errorColor,size: 12.sp,family: regular),),
        ],
      ),
    );
  }
}

KeyboardActionsConfig buildKeyboardActionsConfig(BuildContext context,FocusNode? focusNode) {
  return KeyboardActionsConfig(
    keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
    keyboardBarColor: Colors.grey,
    actions: [
      KeyboardActionsItem(
          focusNode: focusNode??FocusNode(),
          toolbarButtons: [
                (node) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => node.nextFocus(),
                    child: Text("next".tr, style: StyleHelper.customStyle()),
                  ),

                  GestureDetector(
                    onTap: () => node.unfocus(),
                    child: PaddingHorizontal15(child: Text("done".tr, style: StyleHelper.customStyle())),
                  )
                ],
              );
            },
          ]
      ),
    ],
  );
}