import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/About%20Us/about.dart';
import 'package:ieee_website/Base/base.dart';
import 'package:ieee_website/Contact_us/contact.dart';
import 'package:ieee_website/Events/events.dart';
import 'package:ieee_website/FAQ/faq.dart';
import 'package:ieee_website/Home_screen/home_screen.dart';
import 'package:ieee_website/Login/login.dart';
import 'package:ieee_website/Login/signup/sign.dart';
import 'package:ieee_website/Projects/projects_page.dart';
import 'package:ieee_website/Themes/my_theme.dart';
import 'utils/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully'); // Debug log
  } catch (e) {
    debugPrint('Error initializing Firebase: $e'); // Debug log
  }
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
          initialRoute: LoginScreen.routeName,
          routes: {
            LoginScreen.routeName: (context) => LoginScreen(),
            SignUpScreen.routeName: (context) => SignUpScreen(),
            HomeScreen.routeName: (context) => HomeScreen(),
            AboutUs.routeName: (context) => AboutUs(),
            AdminEventPage.routeName: (context) => AdminEventPage(),
            Projects.routeName: (context) => Projects(),
            Contact.routeName: (context) => Contact(),
            Base.routeName: (context) => Base(),
            FAQ.routeName: (context) => FAQ(),
          },
        );
      },
    );
  }
}
