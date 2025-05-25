import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ieee_website/Login/auth/dialog_utils.dart';
import 'package:ieee_website/Themes/website_colors.dart';
import 'package:ieee_website/utils/shared_prefs_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Account extends StatefulWidget {
  static const String routeName = 'account_screen';

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final _formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;
  String? email;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('loggedInEmail');
    });
  }

  Future<void> _changePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      DialogUtils.showMessage(
        context: context,
        content: "New passwords do not match.",
        posActionName: "OK",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('loggedInEmail');

      if (email == null || email.isEmpty) {
        throw Exception("No email found in local storage.");
      }

      final docRef = FirebaseFirestore.instance
          .collection('adminUsers')
          .doc(email);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception("User data not found.");
      }

      final storedPassword = doc.data()?['password'];

      if (storedPassword != currentPassword) {
        DialogUtils.showMessage(
          context: context,
          content: "Current password is incorrect.",
          posActionName: "Try Again",
        );
        return;
      }

      // Update Firestore password field
      await docRef.update({'password': newPassword});

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      DialogUtils.showMessage(
        context: context,
        content: "Password updated successfully.",
        posActionName: "OK",
      );
    } catch (e) {
      print('Change password error: $e');
      DialogUtils.showMessage(
        context: context,
        content: "An error occurred: $e",
        posActionName: "OK",
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account Settings',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: WebsiteColors.primaryBlueColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Change Password',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: WebsiteColors.primaryBlueColor,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: Theme.of(context).textTheme.displaySmall
                      ?.copyWith(color: WebsiteColors.primaryBlueColor),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter your current password'
                            : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: Theme.of(context).textTheme.displaySmall
                      ?.copyWith(color: WebsiteColors.primaryBlueColor),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'New password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: Theme.of(context).textTheme.displaySmall
                      ?.copyWith(color: WebsiteColors.primaryBlueColor),
                ),
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _changePassword();
                      }
                    },
                    child: Text(
                      'Update Password',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: WebsiteColors.primaryBlueColor,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
