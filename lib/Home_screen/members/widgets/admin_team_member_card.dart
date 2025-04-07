import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/Home_screen/members/widgets/team_member_card.dart';
import 'package:ieee_website/Themes/website_colors.dart';
import '../models/team_member.dart';

class AdminTeamMemberCard extends StatelessWidget {
  final TeamMember member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminTeamMemberCard({
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400.sp,
      child: Stack(
        children: [
          TeamMemberCard(
            imagePath: member.pic,
            name: member.name,
            jobTitle: member.position,
          ),
          Positioned(
            top: 10.sp,
            right: 10.sp,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: WebsiteColors.gradeintBlueColor,
                    borderRadius: BorderRadius.circular(50.sp),
                  ),
                  child: IconButton(
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit,
                      color: WebsiteColors.primaryYellowColor,
                      size: 45.sp,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: WebsiteColors.gradeintBlueColor,
                    borderRadius: BorderRadius.circular(50.sp),
                  ),
                  child: IconButton(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete, color: Colors.red, size: 45.sp),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
