import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/Themes/website_colors.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatelessWidget {
  final Function(DateTime?) onDatePicked;
  final DateTime? initialDate;

  const CustomDatePicker({super.key, required this.onDatePicked, this.initialDate});

  @override
  Widget build(BuildContext context) {
    // Get screen height for dynamic sizing
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.sp),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            FocusScope.of(context).unfocus(); // Close any open keyboard
            DateTime? newDateTime = await showRoundedDatePicker(
              customWeekDays: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"],
              context: context,
              theme: ThemeData(
                buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                hintColor: WebsiteColors.darkBlueColor,
                primaryColor: WebsiteColors.darkBlueColor,
                textTheme: TextTheme(
                  bodyMedium: TextStyle(color: WebsiteColors.darkBlueColor),
                ),
                colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(background: Colors.white),
              ),
              imageHeader: const AssetImage("assets/images/IEEE.jpg"),
              lastDate: DateTime(2100),
              firstDate: DateTime(2000),
              // Set dynamic height to prevent overflow
              height: screenHeight * 0.45, // Use 45% of screen height
              borderRadius: 16.0.sp,
              styleDatePicker: MaterialRoundedDatePickerStyle(
                textStyleDayButton: TextStyle(fontSize: 36.sp, color: WebsiteColors.whiteColor),
                textStyleYearButton: TextStyle(fontSize: 52.sp, color: WebsiteColors.whiteColor),
                textStyleDayOnCalendar: TextStyle(fontSize: 32.sp, color: Colors.black),
                textStyleDayOnCalendarSelected: TextStyle(fontSize: 35.sp, color: Colors.white, fontWeight: FontWeight.bold),
                textStyleDayOnCalendarDisabled: TextStyle(fontSize: 28.sp, color: Colors.white.withOpacity(0.1)),
                sizeArrow: 30.sp,
                colorArrowNext: Colors.black,
                colorArrowPrevious: Colors.black,
                marginLeftArrowPrevious: 16.sp,
                marginTopArrowPrevious: 16.sp,
                marginTopArrowNext: 32.sp,
                marginRightArrowNext: 32.sp,
              ),
            );

            if (newDateTime != null) {
              onDatePicked(newDateTime);
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 20.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  initialDate != null ? DateFormat.yMMMd().format(initialDate!) : "Pick a date",
                  style: TextStyle(fontSize: 30.sp, color: WebsiteColors.primaryBlueColor),
                ),
                const Icon(Icons.calendar_month_outlined, color: WebsiteColors.primaryBlueColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}