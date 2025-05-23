import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/About%20Us/about.dart';
import 'package:ieee_website/Contact_us/contact.dart';
import 'package:ieee_website/Events/events.dart';
import 'package:ieee_website/FAQ/faq.dart';
import 'package:ieee_website/Home_screen/home_screen.dart';
import 'package:ieee_website/Home_screen/members/models/url_helper.dart';
import 'package:ieee_website/Home_screen/members/models/url_helper.dart';
import 'package:ieee_website/Join_us/join.dart';
import 'package:ieee_website/Projects/projects_page.dart';
import 'package:ieee_website/Projects/projects_page.dart';
import 'package:ieee_website/Themes/website_colors.dart';

class Base extends StatefulWidget {
  static const String routeName = 'base';

  Base({super.key});

  @override
  State<Base> createState() => _BaseState();
}

class _BaseState extends State<Base> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor:
          WebsiteColors.whiteColor, // Explicitly set background color
      appBar: AppBar(
        toolbarHeight: 120.sp,
        backgroundColor: WebsiteColors.primaryBlueColor.withOpacity(0.9),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(color: WebsiteColors.primaryBlueColor),
        ),
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // IEEE Logo
              Image.asset(
                'assets/images/whitehoriz.png',
                height: 170.sp,
                width: 160.sp,
              ),

              // TabBar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: WebsiteColors.whiteColor,
                unselectedLabelStyle: Theme.of(context).textTheme.displayMedium,
                labelStyle: Theme.of(context).textTheme.displaySmall,
                tabs: const [
                  Tab(text: "Home"),
                  Tab(text: "About Us"),
                  Tab(text: "Events"),
                  Tab(text: "Projects"),
                  Tab(text: "Contact Us"),
                  Tab(text: "FAQ"),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          HomeScreen(tabController: _tabController),
          AboutUs(tabController: _tabController),
          Events(tabController: _tabController),
          Projects(
            tabController: _tabController,
          ), // Pass TabController to Projects
          Contact(tabController: _tabController),
          FAQ(tabController: _tabController),
        ],
      ),
    );
  }
}