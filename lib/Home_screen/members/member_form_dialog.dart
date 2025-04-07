import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/Home_screen/members/models/team_member.dart';
import 'package:ieee_website/Themes/website_colors.dart';

class MemberEditScreen extends StatefulWidget {
  final TeamMember? member;
  const MemberEditScreen({this.member});

  @override
  State<MemberEditScreen> createState() => _MemberEditScreenState();
}

class _MemberEditScreenState extends State<MemberEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController positionController;
  late TextEditingController numberController;
  late TextEditingController picController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.member?.name);
    positionController = TextEditingController(text: widget.member?.position);
    numberController = TextEditingController(
      text: widget.member?.number.toString(),
    );
    picController = TextEditingController(text: widget.member?.pic);
  }

  @override
  void dispose() {
    nameController.dispose();
    positionController.dispose();
    numberController.dispose();
    picController.dispose();
    super.dispose();
  }

  void saveMember() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': nameController.text.trim(),
      'position': positionController.text.trim(),
      'number': int.parse(numberController.text.trim()),
      'pic': picController.text.trim(),
    };

    final members = FirebaseFirestore.instance.collection('Members');
    if (widget.member == null) {
      await members.add(data);
    } else {
      await members.doc(widget.member!.id).update(data);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.member == null ? "Add Member" : "Edit Member",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: positionController,
                decoration: InputDecoration(
                  labelText: 'Position',
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: numberController,
                decoration: InputDecoration(
                  labelText: 'Order Number',
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: picController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 50.sp),
                  Text(
                    "Warning : The Image URL must be from GitHub and stored in a public repository.",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 35.sp,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 50.sp),
                  Text(
                    "Private repos or non-GitHub links are not allowed.",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 35.sp,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveMember,
                child: Text(
                  "Save",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
