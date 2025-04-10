import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/About%20Us/about.dart';
import 'package:ieee_website/Base/base.dart';
import 'package:ieee_website/Contact_us/contact.dart';
import 'package:ieee_website/Events/events.dart';
import 'package:ieee_website/FAQ/faq.dart';
import 'package:ieee_website/Home_screen/home_screen.dart';
import 'package:ieee_website/Join_us/join.dart';
import 'package:ieee_website/Projects/projects.dart';
import 'package:ieee_website/Themes/my_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1912, 6743),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'IEEE PUA SB',
          theme: MyTheme.theme,
          initialRoute: Base.routeName,
          routes: {
            HomeScreen.routeName: (context) => HomeScreen(),
            AboutUs.routeName: (context) => AboutUs(),
            Events.routeName: (context) => Events(),
            Projects.routeName: (context) => Projects(),
            Contact.routeName: (context) => Contact(),
            JoinUs.routeName: (context) => JoinUs(),
            Base.routeName: (context) => Base(),
            FAQ.routeName: (context) => FAQ(),
          },
        );
      },
    );
  }
}
