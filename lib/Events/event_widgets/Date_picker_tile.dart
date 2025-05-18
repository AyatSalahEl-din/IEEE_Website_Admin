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
    return ListTile(
      tileColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text(
        initialDate != null ? DateFormat.yMMMd().format(initialDate!) : "Pick a date",
        style: TextStyle(fontSize: 22.sp, color: WebsiteColors.primaryBlueColor), // Smaller for safety
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.calendar_month_outlined, color: WebsiteColors.primaryBlueColor),
      onTap: () async {
        final screenHeight = MediaQuery.of(context).size.height;

        DateTime? newDateTime = await showRoundedDatePicker(
          context: context,
          customWeekDays: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"],
          theme: ThemeData(
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            hintColor: WebsiteColors.darkBlueColor,
            primaryColor: WebsiteColors.darkBlueColor,
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: WebsiteColors.darkBlueColor),
            ),
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
              background: Colors.white,
            ),
          ),
          imageHeader: const AssetImage("assets/images/IEEE.jpg"),
          lastDate: DateTime(2100),
          firstDate: DateTime(2000),
          borderRadius: 16.0.sp,
          height: screenHeight * 0.6, // 🛠 Dynamically adjust height to fit the screen
          styleDatePicker: MaterialRoundedDatePickerStyle(
            textStyleDayButton: TextStyle(fontSize: 24.sp, color: WebsiteColors.whiteColor),
            textStyleYearButton: TextStyle(fontSize: 32.sp, color: WebsiteColors.whiteColor),
            textStyleDayOnCalendar: TextStyle(fontSize: 22.sp, color: Colors.black),
            textStyleDayOnCalendarSelected: TextStyle(
              fontSize: 24.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textStyleDayOnCalendarDisabled: TextStyle(
              fontSize: 20.sp,
              color: Colors.white.withOpacity(0.1),
            ),
            sizeArrow: 22.sp,
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
    );
  }
}
