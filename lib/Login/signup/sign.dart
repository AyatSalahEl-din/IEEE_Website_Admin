import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/Login/auth/custom_text_form_field.dart';
import 'package:ieee_website/Themes/website_colors.dart';

class SignUpScreen extends StatefulWidget {
  static const String routeName = 'signup_screen';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController passController = TextEditingController();

  final TextEditingController unameController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  // Sign-up function
  Future<void> _handleSignUp() async {
    if (formKey.currentState?.validate() ?? false) {
      final email = nameController.text.trim();
      final password = passController.text.trim();
      final name = unameController.text.trim();
      final phone = mobileController.text.trim();

      try {
        final firestore = FirebaseFirestore.instance;

        // 🔍 Check if email exists in adminUsers collection (as a field)
        final adminQuery =
            await firestore
                .collection('adminUsers')
                .where('email', isEqualTo: email)
                .limit(1)
                .get();

        if (adminQuery.docs.isNotEmpty) {
          await showDialog(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  backgroundColor: WebsiteColors.gradeintBlueColor,
                  title: Text(
                    'Account Already Exists',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 40.sp,
                      color: WebsiteColors.primaryBlueColor,
                    ),
                  ),
                  content: Text(
                    'This email already has admin access.',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w200,
                      fontSize: 25.sp,
                      color: WebsiteColors.visionColor,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'OK',
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w200,
                          fontSize: 25.sp,
                          color: WebsiteColors.primaryBlueColor,
                        ),
                      ),
                    ),
                  ],
                ),
          );
          return;
        }

        // 🔍 Check if email already requested access in pendingAdmins
        final pendingQuery =
            await firestore
                .collection('pendingAdmins')
                .where('email', isEqualTo: email)
                .limit(1)
                .get();

        if (pendingQuery.docs.isNotEmpty) {
          await showDialog(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  backgroundColor: WebsiteColors.gradeintBlueColor,
                  title: Text(
                    'Request Already Sent',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 40.sp,
                      color: WebsiteColors.primaryBlueColor,
                    ),
                  ),
                  content: Text(
                    'This email has already requested access. Please wait for approval.',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w200,
                      fontSize: 25.sp,
                      color: WebsiteColors.visionColor,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'OK',
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w200,
                          fontSize: 25.sp,
                          color: WebsiteColors.primaryBlueColor,
                        ),
                      ),
                    ),
                  ],
                ),
          );
          return;
        }

        // ✅ Save request if not in adminUsers or pendingAdmins
        await firestore.collection('pendingAdmins').doc(email).set({
          'email': email,
          'name': name,
          'phone': phone,
          'password': password,
          'requestedAt': FieldValue.serverTimestamp(),
          'approved': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request sent. Await admin approval.')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

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
                  height: 5000.h,
                  width: 900.w,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Request Access',
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
                            if (text.length < 6) {
                              return 'Password must be at least 6 Characters.';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),
                        CustomTextFormField(
                          label: 'Confirm Password',
                          controller: confirmpassController,
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
                              return 'Please Confirm Password.';
                            }
                            if (text.length < 6) {
                              return 'Password must be at least 6 Characters.';
                            }
                            if (text != passController.text) {
                              return "Passwords Doesn't match";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        CustomTextFormField(
                          label: 'Name',
                          controller: unameController,
                          obscureText: false,
                          validator: (text) {
                            if (text == null || text.trim().isEmpty) {
                              return 'Please Enter Your Name.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        CustomTextFormField(
                          label: 'Phone Number',
                          controller: mobileController,
                          obscureText: false,
                          validator: (text) {
                            if (text == null || text.trim().isEmpty) {
                              return 'Please Enter Your Phone Number.';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.phone,
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
                              _handleSignUp();
                            }
                          },
                          child: Text(
                            'Request Acesss',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: WebsiteColors.gradeintBlueColor,
                              fontSize: 39.sp,
                            ),
                          ),
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
}
