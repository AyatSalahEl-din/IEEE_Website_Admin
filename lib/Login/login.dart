import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/Base/base.dart';
import 'package:ieee_website/Home_screen/home_screen.dart';
import 'package:ieee_website/Login/auth/custom_text_form_field.dart';
import 'package:ieee_website/Login/auth/dialog_utils.dart';
import 'package:ieee_website/Login/auth/footer_contact_widget.dart';
import 'package:ieee_website/Themes/website_colors.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController(
    text: 'ayat.salah.eldin@gmail.com',
  );

  final TextEditingController passController = TextEditingController(
    text: 'ayt261',
  );

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
                padding: EdgeInsets.all(24.w),
                child: SizedBox(
                  height: 2900.h,
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

                        Text(
                          'New Chairman? Please contact',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: WebsiteColors.primaryBlueColor,
                            fontSize: 24.sp,
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            // Forgot password logic here
                          },
                          child: Text(
                            'IEEE PUA Website Support Team',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: WebsiteColors.primaryBlueColor,
                              fontSize: 25.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        FooterContactWidget(
                          whatsappNumber: '+201278726607',
                          email: 'ayat.salah.eldin@gmail.com',
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
    //show loading
    DialogUtils.showLoading(context: context, loadingLabel: 'Loading..');
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: nameController.text,
        password: passController.text,
      );
      //hide loading
      DialogUtils.hideLoading(context);
      //show message
      DialogUtils.showMessage(
        context: context,
        content: "Login Succefully",
        posActionName: "OK",
        posAction: () {
          Navigator.of(context).pushReplacementNamed(Base.routeName);
        },
      );
      print("Login Succefully");
      print(credential.user?.uid ?? "");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        //hide loading
        DialogUtils.hideLoading(context);
        //show message invalid
        DialogUtils.showMessage(
          context: context,
          content: "Email is not Authorized!",
          posActionName: "Try Again",
        );
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        //hide loading
        DialogUtils.hideLoading(context);
        //show message invalid
        DialogUtils.showMessage(
          context: context,
          content: "Incorrect Password!",
          posActionName: "Try Again",
        );
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      //hide loading
      //show message invalid
      print(e.toString());
    }
  }
}
