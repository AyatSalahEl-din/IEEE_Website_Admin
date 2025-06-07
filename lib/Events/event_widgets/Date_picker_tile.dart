import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:ieee_website/Themes/website_colors.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatelessWidget {
  final Function(DateTime?) onDatePicked;
  final DateTime? initialDate;

  const CustomDatePicker({
    super.key,
    required this.onDatePicked,
    this.initialDate,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen height for dynamic sizing
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
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
                buttonTheme: const ButtonThemeData(
                  textTheme: ButtonTextTheme.primary,
                ),
                hintColor: WebsiteColors.darkBlueColor,
                primaryColor: WebsiteColors.darkBlueColor,
                textTheme: TextTheme(
                  bodyMedium: TextStyle(color: WebsiteColors.darkBlueColor),
                ),
                colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: Colors.blue,
                ).copyWith(background: Colors.white),
              ),
              imageHeader: const AssetImage("assets/images/IEEE.jpg"),
              lastDate: DateTime(2100),
              firstDate: DateTime(2000),
              // Set dynamic height to prevent overflow
              height: screenHeight * 0.45, // Use 45% of screen height
              borderRadius: 16.0,
              styleDatePicker: MaterialRoundedDatePickerStyle(
                textStyleDayButton: TextStyle(
                  fontSize: 36,
                  color: WebsiteColors.whiteColor,
                ),
                textStyleYearButton: TextStyle(
                  fontSize: 52,
                  color: WebsiteColors.whiteColor,
                ),
                textStyleDayOnCalendar: TextStyle(
                  fontSize: 32,
                  color: Colors.black,
                ),
                textStyleDayOnCalendarSelected: TextStyle(
                  fontSize: 35,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textStyleDayOnCalendarDisabled: TextStyle(
                  fontSize: 28,
                  color: Colors.white.withOpacity(0.1),
                ),
                sizeArrow: 30,
                colorArrowNext: Colors.black,
                colorArrowPrevious: Colors.black,
                marginLeftArrowPrevious: 16,
                marginTopArrowPrevious: 16,
                marginTopArrowNext: 32,
                marginRightArrowNext: 32,
              ),
            );

            if (newDateTime != null) {
              onDatePicked(newDateTime);
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  initialDate != null
                      ? DateFormat.yMMMd().format(initialDate!)
                      : "Pick a date",
                  style: TextStyle(
                    fontSize: 30,
                    color: WebsiteColors.primaryBlueColor,
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  color: WebsiteColors.primaryBlueColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
