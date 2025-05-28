import 'package:flutter/material.dart';
import 'package:ieee_website/Themes/website_colors.dart';

Widget buildErrorState() {
  return Center(
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: WebsiteColors.redColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: WebsiteColors.redColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: WebsiteColors.redColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.error_outline,
              size: 32,
              color: WebsiteColors.redColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load questions',
            style: TextStyle(
              color: WebsiteColors.redColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Please check your connection and try again',
            style: TextStyle(
              color: WebsiteColors.descGreyColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget buildLoadingState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: WebsiteColors.primaryBlueColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
                WebsiteColors.primaryBlueColor),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Loading questions...",
          style: TextStyle(
            fontSize: 14,
            color: WebsiteColors.descGreyColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget buildEmptyState() {
  return Center(
    child: Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: WebsiteColors.primaryBlueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.quiz_outlined,
              size: 48,
              color: WebsiteColors.primaryBlueColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No questions yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: WebsiteColors.darkGreyColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start by adding your first FAQ using the form on the right",
            style: TextStyle(
              fontSize: 14,
              color: WebsiteColors.descGreyColor,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}