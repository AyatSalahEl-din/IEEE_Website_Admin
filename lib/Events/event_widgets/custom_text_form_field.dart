import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/Themes/website_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
<<<<<<< HEAD
  final IconData? icon;
  final bool isMultiline;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? minLines;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final String? hintText;
  final TextStyle? hintStyle;
  final Widget? suffix;
  final bool readOnly;
  final VoidCallback? onTap;
=======
  final IconData icon;
  final bool isMultiline;
  final FormFieldValidator<String>? validator;
>>>>>>> 6d52d1a9d504456e9b0cc888201745ae3e0e7282

  const CustomTextFormField({
    Key? key,
    required this.controller,
    required this.labelText,
<<<<<<< HEAD
    this.icon,
    this.isMultiline = false,
    this.obscureText = false,
    this.validator,
    required this.keyboardType,
    this.onChanged,
    this.maxLines,
    this.minLines,
    this.contentPadding,
    this.textStyle,
    this.labelStyle,
    this.hintText,
    this.hintStyle,
    this.suffix,
    this.readOnly = false,
    this.onTap,
=======
    required this.icon,
    this.isMultiline = false,
    this.validator,
>>>>>>> 6d52d1a9d504456e9b0cc888201745ae3e0e7282
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
<<<<<<< HEAD
      maxLines: isMultiline ? (maxLines ?? null) : (obscureText ? 1 : (maxLines ?? 1)),
      minLines: isMultiline ? (minLines ?? 3) : null,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: hintStyle ?? TextStyle(
          color: WebsiteColors.greyColor,
          fontSize: 16.sp,
        ),
        labelStyle: labelStyle ?? TextStyle(
          color: WebsiteColors.primaryBlueColor,
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
        ),
        prefixIcon: icon != null ? Icon(
          icon,
          color: WebsiteColors.primaryBlueColor,
        ) : null,
        suffixIcon: suffix,
        contentPadding: contentPadding ?? EdgeInsets.symmetric(
          vertical: 16.sp,
          horizontal: 16.sp,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.sp),
          borderSide: BorderSide(
            color: WebsiteColors.primaryBlueColor,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.sp),
          borderSide: BorderSide(
            color: WebsiteColors.primaryBlueColor.withOpacity(0.7),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.sp),
          borderSide: BorderSide(
            color: WebsiteColors.primaryBlueColor,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.sp),
          borderSide: BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.sp),
          borderSide: BorderSide(
            color: Colors.red.shade700,
            width: 2.0,
          ),
        ),
      ),
      style: textStyle ?? TextStyle(
        fontSize: 16.sp,
        color: Colors.black87,
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
    );
  }
}
=======
      maxLines: isMultiline ? null : 1, // allows multiline if needed
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: WebsiteColors.primaryBlueColor,
          fontWeight: FontWeight.bold,
          fontSize: 25.sp,
        ),
        prefixIcon: Icon(icon, color: WebsiteColors.primaryBlueColor), // Custom icon color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.sp),
          borderSide: BorderSide(color: WebsiteColors.primaryBlueColor, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.sp),
          borderSide: BorderSide(color: WebsiteColors.primaryBlueColor, width: 2.0),
        ),
      ),
      style: TextStyle(fontSize: 31.sp),
    );
  }
}
>>>>>>> 6d52d1a9d504456e9b0cc888201745ae3e0e7282
