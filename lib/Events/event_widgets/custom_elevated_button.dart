import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Themes/website_colors.dart';

class CustomElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isActive;

  const CustomElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Transform.scale(
        scale: isActive ? 1.05 : 1.0,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? WebsiteColors.primaryBlueColor : WebsiteColors.greyColor.withOpacity(0.2),
            foregroundColor: isActive ? WebsiteColors.whiteColor : WebsiteColors.darkBlueColor,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 30.sp : 35.sp,
              vertical: isSmallScreen ? 25.sp : 28.sp,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.sp),
              side: BorderSide(
                color: isActive ? WebsiteColors.primaryBlueColor : Colors.transparent,
                width: isActive ? 2.sp : 0,
              ),
            ),
            elevation: isActive ? 6 : 2,
            shadowColor: isActive ? WebsiteColors.primaryBlueColor.withOpacity(0.4) : Colors.grey.withOpacity(0.3),
            textStyle: TextStyle(
              fontSize: isSmallScreen ? 18.sp : 20.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
            minimumSize: Size(isSmallScreen ? 120.sp : 140.sp, isSmallScreen ? 44.sp : 48.sp),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? WebsiteColors.whiteColor : WebsiteColors.darkBlueColor,
              fontSize: isSmallScreen ? 18.sp : 20.sp,
            ),
          ),
        ),
      ),
    );
  }
}