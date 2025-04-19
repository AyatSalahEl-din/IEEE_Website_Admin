// lib/widgets/reusable_card.dart
import 'package:flutter/material.dart';
import 'package:ieee_website/Themes/website_colors.dart';

class ReusableCard extends StatelessWidget {
  final Color backgroundColor; 
  final double borderRadius; 
  final Widget child; // Content of the card
  final VoidCallback onTap; 

  const ReusableCard({
    Key? key,
    this.backgroundColor = WebsiteColors.whiteColor, 
    this.borderRadius = 12.0, 
    required this.child, 
    required this.onTap, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: backgroundColor,
          child: child, 
        ),
      ),
    );
  }
}