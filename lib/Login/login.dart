import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/Base/base.dart';
import 'package:ieee_website/Login/auth/custom_text_form_field.dart';
import 'package:ieee_website/Login/auth/dialog_utils.dart';
import 'package:ieee_website/Login/signup/sign.dart';
import 'package:ieee_website/Themes/website_colors.dart';
import 'package:ieee_website/utils/shared_prefs_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController passController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              WebsiteColors.primaryBlueColor,
              WebsiteColors.gradeintBlueColor,
              WebsiteColors.visionColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              color: WebsiteColors.gradeintBlueColor,
              child: Padding(
                padding: EdgeInsets.all(30.w),
                child: SizedBox(
                  height: 3800.h,
                  width: 900.w,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Login',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            color: WebsiteColors.primaryBlueColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        CustomTextFormField(
                          label: 'Email',
                          controller: nameController,
                          obscureText: false,
                          validator: (text) {
                            ////trim bt filter spaces 2bl w b3d
                            if (text == null || text.trim().isEmpty) {
                              return 'Please Enter Email.';
                            }
                            final bool emailValid = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                            ).hasMatch(text);
                            if (!emailValid) {
                              return 'Please Enter Valid Email.';
                            }
                            return null;
                          },

                          ///el @ tzhar fe el key board
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 16.h),
                        CustomTextFormField(
                          label: 'Password',
                          controller: passController,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: WebsiteColors.primaryBlueColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (text) {
                            if (text == null || text.trim().isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30.h),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WebsiteColors.primaryBlueColor,
                            foregroundColor: WebsiteColors.gradeintBlueColor,
                            minimumSize: Size(200.w, 350.h),
                          ),
                          onPressed: () {
                            if (formKey.currentState?.validate() ?? false) {
                              login();
                            }
                          },
                          child: Text(
                            'Login',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: WebsiteColors.gradeintBlueColor,
                              fontSize: 39.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 100.h),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WebsiteColors.whiteColor,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              SignUpScreen.routeName,
                            );
                          },

                          child: Text(
                            'Request an Access',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: WebsiteColors.primaryBlueColor,
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 150.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Forget Password? Please contact',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color: WebsiteColors.primaryBlueColor,
                                fontSize: 25.sp,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final Uri emailLaunchUri = Uri(
                                  scheme: 'mailto',
                                  path:
                                      'ayat.salah.eldin@gmail.com', // Change to full valid email
                                  query: Uri.encodeFull(
                                    'subject=IEEE Support&body=Hello Ayat, I need help with getting my password back , my email is ...',
                                  ),
                                );

                                if (await canLaunchUrl(emailLaunchUri)) {
                                  await launchUrl(emailLaunchUri);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Could not open email app.",
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                'IEEE Support Team',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color: WebsiteColors.primaryBlueColor,
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void login() async {
    final email = nameController.text.trim();
    final password = passController.text;

    DialogUtils.showLoading(context: context, loadingLabel: 'Loading...');

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('adminUsers')
              .doc(email)
              .get();

      if (!doc.exists) {
        DialogUtils.hideLoading(context);
        DialogUtils.showMessage(
          context: context,
          content: "Email is not Authorized!",
          posActionName: "Try Again",
        );
        return;
      }

      final storedPassword = doc.data()?['password'];

      if (storedPassword == null || storedPassword.isEmpty) {
        DialogUtils.hideLoading(context);
        DialogUtils.showMessage(
          context: context,
          content: "No password found for this account!",
          posActionName: "Try Again",
        );
        return;
      }

      if (storedPassword != password) {
        DialogUtils.hideLoading(context);
        DialogUtils.showMessage(
          context: context,
          content: "Incorrect Password!",
          posActionName: "Try Again",
        );
        return;
      }

      // Save email to SharedPreferences
      await SharedPrefsHelper.saveLoggedInEmail(email);

      DialogUtils.hideLoading(context);
      DialogUtils.showMessage(
        context: context,
        content: "Login Successfully",
        posActionName: "OK",
        posAction: () {
          Navigator.of(context).pushReplacementNamed(Base.routeName);
        },
      );
    } catch (e) {
      DialogUtils.hideLoading(context);
      print('Login error: $e');
      DialogUtils.showMessage(
        context: context,
        content: "An error occurred. Please try again.",
        posActionName: "OK",
      );
    }
  }
}
