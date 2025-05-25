import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/Home_screen/account/account.dart';
import 'package:ieee_website/Home_screen/admins/admins.dart';
import 'package:ieee_website/Home_screen/links/links_screen.dart';
import 'package:ieee_website/Home_screen/members/member_admin_screen.dart';
import 'package:ieee_website/Home_screen/members/widgets/home_action_card.dart';
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
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HomeActionCard(
                    icon: Icons.group,
                    title: 'Manage Team\nMembers',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MemberAdminScreen()),
                      );
                    },
                  ),
                  SizedBox(width: 24.w),
                  HomeActionCard(
                    icon: Icons.handshake,
                    title: 'Manage Join\nUs Link',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LinksScreen()),
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HomeActionCard(
                    icon: Icons.admin_panel_settings,
                    title: 'New Admins',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Admins()),
                      );
                    },
                  ),
                  SizedBox(width: 24.w),
                  HomeActionCard(
                    icon: Icons.lock,
                    title: 'Manage Your Account',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Account()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
