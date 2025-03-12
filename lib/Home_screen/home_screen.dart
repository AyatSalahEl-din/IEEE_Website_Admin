import 'package:flutter/material.dart';
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
    return Scaffold(backgroundColor: WebsiteColors.whiteColor);
  }
}
