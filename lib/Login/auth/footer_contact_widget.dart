import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ieee_website/Themes/website_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterContactWidget extends StatelessWidget {
  final String whatsappNumber; // Format: with country code, e.g., +201234567890
  final String email;

  const FooterContactWidget({
    super.key,
    required this.whatsappNumber,
    required this.email,
  });

  void _launchWhatsApp() async {
    final url = Uri.parse("https://wa.me/$whatsappNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _launchEmail() async {
    final Uri url = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=IEEE%20Website%20Support&body=Hello%2C%20I%20need%20assistance...',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch email app';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Divider(color: WebsiteColors.primaryBlueColor, thickness: 1.2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: _launchWhatsApp,
                child: Row(
                  children: [
                    Icon(Icons.call, color: Colors.green),
                    SizedBox(width: 10.w),
                    Text(
                      whatsappNumber,
                      style: TextStyle(
                        color: WebsiteColors.primaryBlueColor,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 40.w),
              InkWell(
                onTap: _launchEmail,
                child: Row(
                  children: [
                    Icon(Icons.email, color: Colors.red, size: 40.sp),
                    SizedBox(width: 10.w),
                    Text(
                      email,
                      style: TextStyle(
                        color: WebsiteColors.primaryBlueColor,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
