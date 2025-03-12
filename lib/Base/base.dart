import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/About%20Us/about.dart';
import 'package:ieee_website/Contact_us/contact.dart';
import 'package:ieee_website/Events/events.dart';
import 'package:ieee_website/FAQ/faq.dart';
import 'package:ieee_website/Home_screen/home_screen.dart';
import 'package:ieee_website/Join_us/join.dart';
import 'package:ieee_website/Projects/projects.dart';
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
      backgroundColor: WebsiteColors.whiteColor,

      // ✅ Custom AppBar with TabBar
      appBar: AppBar(
        toolbarHeight: 120.sp,

        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: WebsiteColors.primaryBlueColor.withOpacity(0.7),
          ),
        ),
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // IEEE Logo
              Image.asset(
                'assets/images/whitehoriz.png',
                height: 170.sp,
                width: 160.sp,
              ),

              // ✅ TabBar instead of Text links
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

              // "Join Us" Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: WebsiteColors.whiteColor,
                  foregroundColor: WebsiteColors.primaryBlueColor,
                  fixedSize: Size(170.sp, 50.sp),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => JoinUs()),
                  );
                },
                child: Text(
                  'Join Us',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 20.sp,
                    color: WebsiteColors.primaryBlueColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ✅ Remove Footer from Base
      body: TabBarView(
        controller: _tabController,
        children: [
          HomeScreen(tabController: _tabController),
          AboutUs(tabController: _tabController),
          Events(tabController: _tabController),
          Projects(tabController: _tabController),
          Contact(tabController: _tabController),
          FAQ(tabController: _tabController),
        ],
      ),
    );
  }
}
