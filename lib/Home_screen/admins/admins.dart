import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/Login/signup/sign.dart';
import 'package:ieee_website/Themes/website_colors.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class Admins extends StatefulWidget {
  static const String routeName = 'admin_screen';

  final String? email;
  final String? password;

  const Admins({this.email, this.password});

  @override
  _AdminsState createState() => _AdminsState();
}

class _AdminsState extends State<Admins> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> approveAdmin(DocumentSnapshot request) async {
    try {
      final email = request['email'].toString().trim();
      final name = request['name'];
      final phone = request['phone'];
      final password = request['password'];

      // Add to adminUsers collection
      await FirebaseFirestore.instance
          .collection('adminUsers')
          .doc(email.toLowerCase())
          .set({
            'email': email,
            'name': name,
            'phone': phone,
            'password': password,
            'addedAt': FieldValue.serverTimestamp(),
          });
      // Remove from pendingAdmins
      await FirebaseFirestore.instance
          .collection('pendingAdmins')
          .doc(email)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin approved and added to adminUsers.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> rejectAdmin(String email) async {
    try {
      await FirebaseFirestore.instance
          .collection('pendingAdmins')
          .doc(email)
          .delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Request removed.')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget buildAdminCard(Map<String, dynamic> data) {
    return Card(
      child: ListTile(
        title: Text(
          data['name'] ?? '',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 40.sp,
            color: WebsiteColors.primaryBlueColor,
          ),
        ),
        subtitle: Text(
          '${data['email']} - ${data['phone']}',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w200,
            fontSize: 25.sp,
            color: WebsiteColors.blackColor,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          tooltip: 'Remove Admin',
          onPressed: () async {
            final shouldRemove = await showDialog<bool>(
              context: context,
              builder:
                  (_) => AlertDialog(
                    backgroundColor: WebsiteColors.gradeintBlueColor,
                    title: Text(
                      'Remove Admin',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 40.sp,
                        color: WebsiteColors.primaryBlueColor,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to remove this admin?',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w200,
                        fontSize: 25.sp,
                        color: WebsiteColors.redColor,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Cancel',
                          style: Theme.of(
                            context,
                          ).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w200,
                            fontSize: 25.sp,
                            color: WebsiteColors.primaryBlueColor,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'Remove',
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

            if (shouldRemove == true) {
              removeAdmin(data['email'], context);
            }
          },
        ),
      ),
    );
  }

  Widget buildRequestCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Card(
      child: ListTile(
        title: Text(
          data['name'] ?? '',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 40.sp,
            color: WebsiteColors.blackColor,
          ),
        ),
        subtitle: Text(
          '${data['email']} - ${data['phone']}',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w200,
            fontSize: 25.sp,
            color: WebsiteColors.primaryYellowColor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check, color: Colors.green, size: 45.sp),
              tooltip: 'Approve',
              onPressed: () => approveAdmin(doc),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red, size: 45.sp),
              tooltip: 'Remove Request',
              onPressed: () async {
                final shouldRemove = await showDialog<bool>(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        backgroundColor: WebsiteColors.gradeintBlueColor,
                        title: Text(
                          'Reject Request',
                          style: Theme.of(
                            context,
                          ).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 40.sp,
                            color: WebsiteColors.primaryBlueColor,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to remove this request?',
                          style: Theme.of(
                            context,
                          ).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w200,
                            fontSize: 25.sp,
                            color: WebsiteColors.redColor,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              'Cancel',
                              style: Theme.of(
                                context,
                              ).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w200,
                                fontSize: 25.sp,
                                color: WebsiteColors.primaryBlueColor,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              'Remove',
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

                if (shouldRemove == true) {
                  rejectAdmin(data['email']);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> removeAdmin(String email, BuildContext context) async {
    try {
      email = email.trim().toLowerCase();

      // Just remove from Firestore
      await FirebaseFirestore.instance
          .collection('adminUsers')
          .doc(email)
          .delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Admin removed from database.')));
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Management',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: 40.sp,
            color: WebsiteColors.primaryBlueColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: 'Current Admins'), Tab(text: 'Requests')],
          labelStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: 30.sp,
            color: WebsiteColors.primaryBlueColor,
          ),
          labelColor: WebsiteColors.primaryBlueColor,
          unselectedLabelStyle: Theme.of(context).textTheme.displaySmall
              ?.copyWith(fontSize: 30.sp, color: WebsiteColors.blackColor),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          /// Tab 1: Current Admins
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('adminUsers').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              final admins = snapshot.data!.docs;
              if (admins.isEmpty)
                return Center(
                  child: Text(
                    "No admins yet.",
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 40.sp,
                      color: WebsiteColors.primaryBlueColor,
                    ),
                  ),
                );
              return ListView(
                children:
                    admins
                        .map(
                          (doc) => buildAdminCard(
                            doc.data() as Map<String, dynamic>,
                          ),
                        )
                        .toList(),
              );
            },
          ),

          /// Tab 2: Pending Requests
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('pendingAdmins')
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              final requests = snapshot.data!.docs;
              if (requests.isEmpty)
                return Center(child: Text("No pending requests."));
              return ListView(
                children: requests.map((doc) => buildRequestCard(doc)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
