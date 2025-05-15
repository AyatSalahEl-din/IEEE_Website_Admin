import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/Themes/website_colors.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageProposalsWidget extends StatefulWidget {
  const ManageProposalsWidget({Key? key}) : super(key: key);

  @override
  State<ManageProposalsWidget> createState() => _ManageProposalsWidgetState();
}

class _ManageProposalsWidgetState extends State<ManageProposalsWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          child: Column(
            children: [
              // Search and Filter Row
              Padding(
                padding: EdgeInsets.all(16.sp),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search proposals...',
                          hintStyle: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: WebsiteColors.greyColor),
                          prefixIcon: Icon(Icons.search, size: 30.sp),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.sp),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged:
                            (value) => setState(
                              () => _searchQuery = value.toLowerCase(),
                            ),
                      ),
                    ),
                    SizedBox(width: 10.sp),
                    DropdownButton<String>(
                      value: _selectedStatus,
                      dropdownColor: Colors.white,
                      style: TextStyle(
                        fontSize: 25.sp,
                        color: WebsiteColors.darkBlueColor,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'All',
                          child: Text('All', style: TextStyle(fontSize: 25.sp)),
                        ),
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text(
                            'Pending',
                            style: TextStyle(fontSize: 25.sp),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'approved',
                          child: Text(
                            'Approved',
                            style: TextStyle(fontSize: 25.sp),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'rejected',
                          child: Text(
                            'Rejected',
                            style: TextStyle(fontSize: 25.sp),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Main Content Area
              Expanded(
                child: Container(child: _buildProposalList(constraints)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProposalList(BoxConstraints constraints) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('event_proposals')
              .orderBy('proposedDate', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: WebsiteColors.primaryBlueColor,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "No proposals found.",
              style: TextStyle(fontSize: 30.sp),
            ),
          );
        }

        final filteredProposals =
            snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final matchesSearch =
                  _searchQuery.isEmpty ||
                  (data['eventName'] ?? '').toString().toLowerCase().contains(
                    _searchQuery,
                  ) ||
                  (data['organizerName'] ?? '')
                      .toString()
                      .toLowerCase()
                      .contains(_searchQuery);

              final matchesStatus =
                  _selectedStatus == 'All' ||
                  (data['status'] ?? 'pending') == _selectedStatus;

              return matchesSearch && matchesStatus;
            }).toList();

        if (filteredProposals.isEmpty) {
          return Center(
            child: Text(
              "No matching proposals found.",
              style: TextStyle(fontSize: 30.sp),
            ),
          );
        }

        final crossAxisCount = (constraints.maxWidth / 350).floor().clamp(1, 3);

        return GridView.builder(
          padding: EdgeInsets.all(8.sp),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8.sp,
            mainAxisSpacing: 8.sp,
            childAspectRatio: 1.2,
          ),
          itemCount: filteredProposals.length,
          itemBuilder: (context, index) {
            final proposal = filteredProposals[index];
            final data = proposal.data() as Map<String, dynamic>;
            return buildProposalCard(context, data, proposal.id);
          },
        );
      },
    );
  }

  Widget buildProposalCard(
    BuildContext context,
    Map<String, dynamic> data,
    String proposalId,
  ) {
    final proposedDate =
        data['proposedDate'] is Timestamp
            ? (data['proposedDate'] as Timestamp).toDate()
            : DateTime.now();
    final isOnline = data['isOnlineEvent'] ?? false;

    return Card(
      color: Colors.white,
      elevation: 2,
      margin: EdgeInsets.all(4.sp),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.sp)),
      child: Padding(
        padding: EdgeInsets.all(10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with delete button and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.delete, size: 22.sp),
                  color: Colors.red,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: () => _confirmDeletion(context, proposalId),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.sp,
                    vertical: 6.sp,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(data['status']),
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  child: Text(
                    (data['status'] ?? 'pending').toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.sp),

            // Event name
            Text(
              data['eventName'] ?? 'No Event Name',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: WebsiteColors.primaryBlueColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 10.sp),

            // Organizer details
            _buildDetailRow(
              Icons.person_outline,
              data['organizerName'] ?? 'No Organizer',
              fontSize: 18.sp,
            ),
            _buildDetailRow(
              Icons.phone_iphone,
              data['phone'] ?? 'No Phone',
              isPhone: true,
              phoneData: data,
              fontSize: 18.sp,
            ),
            _buildDetailRow(
              Icons.email_outlined,
              data['email'] ?? 'No Email',
              fontSize: 18.sp,
            ),
            SizedBox(height: 10.sp),

            // Event details
            _buildDetailRow(
              Icons.calendar_month,
              DateFormat('MMM dd, yyyy').format(proposedDate),
              fontSize: 18.sp,
            ),
            _buildDetailRow(
              Icons.location_on,
              isOnline
                  ? 'Online Event'
                  : data['proposedLocation'] ?? 'No Location',
              fontSize: 18.sp,
            ),
            _buildDetailRow(
              Icons.people,
              'Expected: ${data['expectedAttendees'] ?? 'N/A'} attendees',
              fontSize: 18.sp,
            ),
            SizedBox(height: 10.sp),

            // Description preview
            Text(
              data['eventDescription'] ?? 'No description provided',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Spacer(),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'APPROVE',
                    Colors.green,
                    () => _confirmStatusChange(
                      context,
                      proposalId,
                      'approved',
                      data,
                      'Approve Proposal',
                      'Approve this event proposal?',
                    ),
                  ),
                ),
                SizedBox(width: 4.sp),
                Expanded(
                  child: _buildActionButton(
                    'REJECT',
                    Colors.red,
                    () => _confirmStatusChange(
                      context,
                      proposalId,
                      'rejected',
                      data,
                      'Reject Proposal',
                      'Reject this event proposal?',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String text, {
    bool isPhone = false,
    Map<String, dynamic>? phoneData,
    double fontSize =20,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.sp),
      child: InkWell(
        onTap: isPhone ? () => _launchWhatsAppForDetails(phoneData!) : null,
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: isPhone ? Colors.green : WebsiteColors.primaryBlueColor,
            ),
            SizedBox(width: 6.sp),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  color: isPhone ? Colors.blue : WebsiteColors.darkBlueColor,
                  decoration: isPhone ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.sp),
        ),
        padding: EdgeInsets.symmetric(vertical: 4.sp),
        minimumSize: Size(0, 28.sp),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone app')),
      );
    }
  }

  Future<void> _confirmStatusChange(
    BuildContext context,
    String proposalId,
    String newStatus,
    Map<String, dynamic> data,
    String dialogTitle,
    String dialogContent,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(dialogTitle),
            content: Text(dialogContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: WebsiteColors.darkBlueColor),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      newStatus == 'approved' ? Colors.green : Colors.red,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('CONFIRM'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _updateProposalStatus(proposalId, newStatus);

      if (data['phone'] != null) {
        final eventName = data['eventName'] ?? 'the proposed event';
        final message =
            newStatus == 'approved'
                ? '''
Dear ${data['organizerName'] ?? 'Organizer'},

We are pleased to inform you that your event proposal for *$eventName* has been approved! 

Our team will contact you shortly to discuss the next steps. For further details, feel free to request a meeting, either virtual or in person.

Best regards,
IEEE PUA SB
'''
                : '''
Dear ${data['organizerName'] ?? 'Organizer'},

After careful consideration, we regret to inform you that your event proposal for *$eventName* has not been approved at this time.

We appreciate your interest in collaborating with IEEE PUA SB. For further details or to discuss future opportunities, feel free to request a meeting, either virtual or in person.

Best regards,
IEEE PUA SB
''';

        await _launchWhatsApp(data['phone'], message);
      }
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber, String message) async {
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final formattedNumber =
        cleanedNumber.startsWith('+') ? cleanedNumber : '+$cleanedNumber';
    final whatsappUrl =
        "https://wa.me/$formattedNumber?text=${Uri.encodeComponent(message)}";

    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error launching WhatsApp: $e')));
    }
  }

  Future<void> _launchWhatsAppForDetails(Map<String, dynamic> data) async {
    final phoneNumber = data['phone'];
    if (phoneNumber == null || phoneNumber.isEmpty) return;

    final organizerName = data['organizerName'] ?? 'Organizer';
    final eventName = data['eventName'] ?? 'the proposed event';

    final message = '''
Hello $organizerName,

Thank you for your interest in collaborating with IEEE PUA SB. We would like to request further details regarding your event proposal for *$eventName*.

Please let us know a suitable time for a meeting, either virtual or in person, to discuss this further.

Best regards,
IEEE PUA SB
''';

    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final formattedNumber =
        cleanedNumber.startsWith('+') ? cleanedNumber : '+$cleanedNumber';
    final whatsappUrl =
        "https://wa.me/$formattedNumber?text=${Uri.encodeComponent(message)}";

    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error launching WhatsApp: $e')));
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateProposalStatus(
    String proposalId,
    String newStatus,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('event_proposals')
          .doc(proposalId)
          .update({'status': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Proposal $newStatus!'),
          backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update proposal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDeletion(BuildContext context, String proposalId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Proposal',
              style: TextStyle(color: WebsiteColors.primaryBlueColor),
            ),
            content: Text(
              'Are you sure you want to delete this proposal? This action cannot be undone.',
              style: TextStyle(color: WebsiteColors.darkBlueColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: WebsiteColors.darkBlueColor),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('DELETE'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _deleteProposal(proposalId);
    }
  }

  Future<void> _deleteProposal(String proposalId) async {
    try {
      await FirebaseFirestore.instance
          .collection('event_proposals')
          .doc(proposalId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proposal deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete proposal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
