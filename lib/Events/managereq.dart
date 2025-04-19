import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/Themes/website_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class BuildManageReq extends StatefulWidget {
  const BuildManageReq({super.key});

  @override
  State<BuildManageReq> createState() => _BuildManageReqState();
}

class _BuildManageReqState extends State<BuildManageReq> {
  final String paymentNumber =
      "1234567890"; // Replace with the actual payment number

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage Requests',
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
                  FirebaseFirestore.instance.collection('requests').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text("An error occurred while loading requests."),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No requests found."));
                }

                final requests = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    final data = request.data() as Map<String, dynamic>;

                    final userName = data['userName'] ?? 'No Name';
                    //final userPhone = data['userPhone'] ?? 'No Phone';
                    //final userEmail = data['userEmail'] ?? 'No Email';
                    final eventName = data['eventName'] ?? 'No Event';
                    final requestDate =
                        (data['requestDate'] as Timestamp).toDate();

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10.sp),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                      ),
                      child: ListTile(
                        title: Text(
                          userName,
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
                              'Event: $eventName',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                fontSize: 18.sp,
                                color: WebsiteColors.darkBlueColor,
                              ),
                            ),
                            Text(
                              'Date: ${requestDate.toLocal()}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                fontSize: 18.sp,
                                color: WebsiteColors.greyColor,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.info,
                            color: WebsiteColors.primaryBlueColor,
                          ),
                          onPressed:
                              () => _showRequestDetails(
                                context,
                                data,
                                request.id,
                              ),
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

  /// Show Request Details in a Dialog
  void _showRequestDetails(
    BuildContext context,
    Map<String, dynamic> data,
    String requestId,
  ) {
    final userName = data['userName'] ?? 'No Name';
    final userPhone = data['userPhone'] ?? 'No Phone';
    final userEmail = data['userEmail'] ?? 'No Email';
    final eventName = data['eventName'] ?? 'No Event';
    final requestDate = (data['requestDate'] as Timestamp).toDate();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Request Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: WebsiteColors.primaryBlueColor,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: $userName'),
                SizedBox(height: 10.sp),
                GestureDetector(
                  onTap: () => _launchWhatsApp(userPhone),
                  child: Text(
                    'Phone: $userPhone',
                    style: TextStyle(
                      color: Colors.green,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 10.sp),
                GestureDetector(
                  onTap: () => _launchEmail(userEmail),
                  child: Text(
                    'Email: $userEmail',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 10.sp),
                Text('Event: $eventName'),
                SizedBox(height: 10.sp),
                Text('Date: ${requestDate.toLocal()}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed:
                    () => _acceptRequest(
                      context,
                      requestId,
                      userEmail,
                      userPhone,
                      eventName,
                    ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Accept Request'),
              ),
              ElevatedButton(
                onPressed:
                    () =>
                        _denyRequest(context, requestId, userEmail, userPhone),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Deny Request'),
              ),
            ],
          ),
    );
  }

  /// Accept Request and Notify User
  Future<void> _acceptRequest(
    BuildContext context,
    String requestId,
    String userEmail,
    String userPhone,
    String eventName,
  ) async {
    // Update Firestore
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .update({'status': 'accepted'});

    // Notify User via Email and WhatsApp
    final message = '''
Your request for the event "$eventName" has been accepted. 
Please transfer the ticket payment to the following number:

Payment Number: $paymentNumber

Once the payment is completed, please send a confirmation message to this number.

Thank you!
''';

    _launchEmail(
      userEmail,
      subject: 'Request Accepted - Payment Details',
      body: message,
    );
    _launchWhatsApp(userPhone, message: message);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request accepted and user notified.')),
    );
  }

  /// Deny Request with Reason
  Future<void> _denyRequest(
    BuildContext context,
    String requestId,
    String userEmail,
    String userPhone,
  ) async {
    TextEditingController reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Deny Request'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please provide a reason for denying this request:'),
                SizedBox(height: 10.sp),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter reason here...',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Deny'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final reason = reasonController.text.trim();
      if (reason.isNotEmpty) {
        // Update Firestore
        await FirebaseFirestore.instance
            .collection('requests')
            .doc(requestId)
            .update({'status': 'denied', 'rejectReason': reason});

        // Notify User via Email and WhatsApp
        _launchEmail(
          userEmail,
          subject: 'Request Denied',
          body:
              'Your request has been denied for the following reason: $reason',
        );
        _launchWhatsApp(
          userPhone,
          message:
              'Your request has been denied for the following reason: $reason',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request denied and user notified.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reason cannot be empty.')),
        );
      }
    }
  }

  /// Launch WhatsApp with the provided phone number and message
  Future<void> _launchWhatsApp(String phone, {String? message}) async {
    final url =
        'https://wa.me/$phone?text=${Uri.encodeComponent(message ?? '')}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }

  /// Launch Email with the provided email address, subject, and body
  Future<void> _launchEmail(
    String email, {
    String? subject,
    String? body,
  }) async {
    final url =
        'mailto:$email?subject=${Uri.encodeComponent(subject ?? '')}&body=${Uri.encodeComponent(body ?? '')}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email client')),
      );
    }
  }
}
