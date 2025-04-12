import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/Themes/website_colors.dart';

class DialogUtils {
  static void showLoading({
    required BuildContext context,
    required String loadingLabel,
  }) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: WebsiteColors.gradeintBlueColor,
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 10),
              Text(
                loadingLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: WebsiteColors.primaryBlueColor,
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void hideLoading(BuildContext context) {
    Navigator.pop(context);
  }

  static void showMessage({
    required BuildContext context,
    required String content,
    String title = '',
    String? posActionName,
    Function? posAction,
    String? negActionName,
    Function? negAction,
  }) {
    List<Widget> actions = [];
    if (posActionName != null) {
      actions.add(
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: WebsiteColors.gradeintBlueColor,
            foregroundColor: WebsiteColors.primaryBlueColor,

            //minimumSize: Size(200.w, 350.h),
          ),
          onPressed: () {
            Navigator.pop(context);
            posAction?.call();
          },
          child: Text(
            posActionName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: WebsiteColors.primaryBlueColor,
              fontSize: 30.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    if (negActionName != null) {
      actions.add(
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: WebsiteColors.gradeintBlueColor,
            foregroundColor: WebsiteColors.primaryBlueColor,

            //minimumSize: Size(200.w, 350.h),
          ),
          onPressed: () {
            Navigator.pop(context);
            negAction?.call();
          },
          child: Text(
            negActionName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: WebsiteColors.primaryBlueColor,
              fontSize: 30.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: WebsiteColors.gradeintBlueColor,
          content: Text(
            content,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: WebsiteColors.primaryBlueColor,
              fontSize: 30.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: WebsiteColors.primaryBlueColor,
              fontSize: 30.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: actions,
        );
      },
    );
  }
}
