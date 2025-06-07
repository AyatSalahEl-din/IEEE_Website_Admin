import 'package:flutter/material.dart';
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
            backgroundColor:
                isActive
                    ? WebsiteColors.primaryBlueColor
                    : WebsiteColors.greyColor.withOpacity(0.2),
            foregroundColor:
                isActive
                    ? WebsiteColors.whiteColor
                    : WebsiteColors.darkBlueColor,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 30 : 35,
              vertical: isSmallScreen ? 25 : 28,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color:
                    isActive
                        ? WebsiteColors.primaryBlueColor
                        : Colors.transparent,
                width: isActive ? 2 : 0,
              ),
            ),
            elevation: isActive ? 6 : 2,
            shadowColor:
                isActive
                    ? WebsiteColors.primaryBlueColor.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.3),
            textStyle: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
            minimumSize: Size(
              isSmallScreen ? 120 : 140,
              isSmallScreen ? 44 : 48,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color:
                  isActive
                      ? WebsiteColors.whiteColor
                      : WebsiteColors.darkBlueColor,
              fontSize: isSmallScreen ? 18 : 20,
            ),
          ),
        ),
      ),
    );
  }
}
