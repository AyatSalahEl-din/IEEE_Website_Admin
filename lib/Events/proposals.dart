import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/Themes/website_colors.dart';

class ProposalsWidget extends StatelessWidget {
  const ProposalsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Proposals',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: WebsiteColors.primaryBlueColor,
              fontSize: 30.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.sp),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('proposals')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text("An error occurred while loading proposals."),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No proposals found."));
                }

                final proposals = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: proposals.length,
                  itemBuilder: (context, index) {
                    final proposal = proposals[index];
                    final data = proposal.data() as Map<String, dynamic>;

                    final name = data['name'] ?? 'No Name';
                    final description = data['description'] ?? 'No Description';
                    final date = (data['proposedDate'] as Timestamp).toDate();

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10.sp),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                      ),
                      child: ListTile(
                        title: Text(
                          name,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: WebsiteColors.primaryBlueColor,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              description,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                fontSize: 18.sp,
                                color: WebsiteColors.darkBlueColor,
                              ),
                            ),
                            Text(
                              'Date: ${date.toLocal()}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                fontSize: 18.sp,
                                color: WebsiteColors.greyColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
