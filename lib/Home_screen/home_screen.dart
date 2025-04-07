import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/Home_screen/links/links_screen.dart';
import 'package:ieee_website/Home_screen/members/member_admin_screen.dart';
import 'package:ieee_website/Themes/website_colors.dart';

class HomeScreen extends StatefulWidget {
  final TabController? tabController;

  HomeScreen({super.key, this.tabController});

  static const String routeName = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WebsiteColors.whiteColor,
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.group, size: 40.sp),
            title: Text(
              'Manage Team Members',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: WebsiteColors.primaryBlueColor,
              ),
            ),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MemberAdminScreen()),
                ),
          ),
          ListTile(
            leading: Icon(Icons.handshake, size: 40.sp),
            title: Text(
              'Manage Join Us Link',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: WebsiteColors.primaryBlueColor,
              ),
            ),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LinksScreen()),
                ),
          ),
          // You can add more features here later
        ],
      ),
    );
  }
}
