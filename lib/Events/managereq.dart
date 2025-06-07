import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ieee_website/Themes/website_colors.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageRequestsWidget extends StatefulWidget {
  const ManageRequestsWidget({Key? key}) : super(key: key);

  @override
  State<ManageRequestsWidget> createState() => _ManageRequestsWidgetState();
}

class _ManageRequestsWidgetState extends State<ManageRequestsWidget> {
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
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search requests...',
                          hintStyle: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: WebsiteColors.greyColor),
                          prefixIcon: Icon(Icons.search, size: 30),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged:
                            (value) => setState(
                              () => _searchQuery = value.toLowerCase(),
                            ),
                      ),
                    ),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _selectedStatus,
                      dropdownColor: Colors.white, // White dropdown background
                      style: TextStyle(
                        fontSize: 25,
                        color: WebsiteColors.darkBlueColor,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'All',
                          child: Text('All', style: TextStyle(fontSize: 25)),
                        ),
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text(
                            'Pending',
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'approved',
                          child: Text(
                            'Approved',
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'rejected',
                          child: Text(
                            'Rejected',
                            style: TextStyle(fontSize: 25),
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
              Expanded(child: Container(child: _buildRequestList(constraints))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestList(BoxConstraints constraints) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('requests')
              .orderBy('requestDate', descending: true)
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
              "No requests found.",
              style: TextStyle(fontSize: 30),
            ),
          );
        }

        final filteredRequests =
            snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final matchesSearch =
                  _searchQuery.isEmpty ||
                  (data['userName'] ?? '').toString().toLowerCase().contains(
                    _searchQuery,
                  ) ||
                  (data['eventName'] ?? '').toString().toLowerCase().contains(
                    _searchQuery,
                  );

              final matchesStatus =
                  _selectedStatus == 'All' ||
                  (data['status'] ?? 'pending') == _selectedStatus;

              return matchesSearch && matchesStatus;
            }).toList();

        if (filteredRequests.isEmpty) {
          return Center(
            child: Text(
              "No matching requests found.",
              style: TextStyle(fontSize: 30),
            ),
          );
        }

        final crossAxisCount = (constraints.maxWidth / 200).floor().clamp(1, 5);

        return GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.7, // Square cards
          ),
          itemCount: filteredRequests.length,
          itemBuilder: (context, index) {
            final request = filteredRequests[index];
            final data = request.data() as Map<String, dynamic>;
            return buildCard(context, data, request.id);
          },
        );
      },
    );
  }

  Widget buildCard(
    BuildContext context,
    Map<String, dynamic> data,
    String requestId,
  ) {
    final requestDate =
        data['requestDate'] is Timestamp
            ? (data['requestDate'] as Timestamp).toDate()
            : DateTime.now();

    return Card(
      color: Colors.white, // White background for the card
      elevation: 6,
      margin: EdgeInsets.all(4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with delete button and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Delete button
                IconButton(
                  icon: Icon(Icons.delete, size: 18),
                  color: Colors.red,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: () => _confirmDeletion(context, requestId),
                ),
                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(data['status']),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (data['status'] ?? 'pending').toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),

            // Order number
            Text(
              'Order Number: ${data['orderNumber'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: WebsiteColors.primaryBlueColor,
              ),
            ),
            SizedBox(height: 8),

            // Event name
            Text(
              data['eventName'] ?? 'No Event',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: WebsiteColors.primaryBlueColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),

            // User details
            _buildDetailRow(
              Icons.person_outline,
              data['userName'] ?? 'No Name',
            ),
            _buildDetailRow(
              Icons.phone_iphone,
              data['userPhone'] ?? 'No Phone',
              isPhone: true,
              phoneData: data,
            ),
            _buildDetailRow(
              Icons.email_outlined,
              data['userEmail'] ?? 'No Email',
            ),
            SizedBox(height: 8),

            // Event details
            _buildDetailRow(
              Icons.calendar_month,
              DateFormat('MM/dd/yy').format(requestDate),
            ),
            _buildDetailRow(
              Icons.confirmation_num_outlined,
              '${data['numberOfTickets'] ?? 1} ticket(s)',
            ),
            if (data['busRequired'] == true)
              _buildDetailRow(
                Icons.directions_bus,
                '${data['numberOfBusTickets'] ?? 0} bus seat(s)',
              ),
            _buildDetailRow(
              Icons.payments_outlined,
              'Total: \$${(data['totalPrice'] ?? 0).toStringAsFixed(2)}',
              isBold: true,
            ),
            Spacer(),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'PAID',
                    Colors.green,
                    () => _confirmStatusChange(
                      context,
                      requestId,
                      'paid',
                      data,
                      'Mark as Paid',
                      'Confirm payment for this request?',
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: _buildActionButton(
                    'UNPAID',
                    Colors.orange,
                    () => _confirmStatusChange(
                      context,
                      requestId,
                      'unpaid',
                      data,
                      'Mark as Unpaid',
                      'Mark this request as unpaid?',
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
    bool isBold = false,
    Map<String, dynamic>? phoneData,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: isPhone ? () => _launchPhoneConfirmation(phoneData!) : null,
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isPhone ? Colors.green : WebsiteColors.primaryBlueColor,
            ),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: isPhone ? Colors.blue : WebsiteColors.darkBlueColor,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
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
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.symmetric(vertical: 4),
        minimumSize: Size(0, 28),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _launchPhoneConfirmation(Map<String, dynamic> data) async {
    final phoneNumber = data['userPhone'];
    if (phoneNumber == null || phoneNumber.isEmpty) return;

    final eventName = data['eventName'] ?? 'the event';
    final tickets = data['numberOfTickets'] ?? 1;
    final price = (data['totalPrice'] ?? 0).toStringAsFixed(2);
    final busSeats =
        data['busRequired'] == true ? data['numberOfBusTickets'] ?? 0 : 0;
    final orderNumber = data['orderNumber'] ?? 'N/A';

    final message = '''
Hello ${data['userName'] ?? 'there'},

I'm contacting you from IEEE PUA SB to confirm your booking for *$eventName*:

- Order Number: $orderNumber
- Tickets: $tickets
${busSeats > 0 ? '- Bus seats: $busSeats\n' : ''}
- Total: \$$price

Please confirm if you're still interested in attending.

Best regards,
IEEE PUA SB
''';

    await _launchWhatsApp(phoneNumber, message);
  }

  Future<void> _confirmStatusChange(
    BuildContext context,
    String requestId,
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
                      newStatus == 'paid' ? Colors.green : Colors.orange,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('CONFIRM'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _updateRequestStatus(requestId, newStatus, data);
      if (data['userPhone'] != null) {
        final eventName = data['eventName'] ?? 'our event';
        final price = (data['totalPrice'] ?? 0).toStringAsFixed(2);
        final orderNumber = data['orderNumber'] ?? 'N/A';

        final message =
            newStatus == 'paid'
                ? '''
Thank you for your interest in our *$eventName* event!

Your payment has been confirmed and your spot is now reserved. 
- Order Number: $orderNumber

We look forward to seeing you there!

Best regards,
IEEE PUA SB
'''
                : '''
Hello,

We're contacting you regarding IEEE PUA SB event *$eventName*. 

Your payment of *\$$price* is still pending. 
- Order Number: $orderNumber

Please complete your payment via:
1. Instapay
2. Vodafone Cash
3. Cash in faculty

Payment should be completed within 3 days to secure your spot.

Please send us the payment confirmation once completed.

Best regards,
IEEE PUA SB
''';

        await _launchWhatsApp(data['userPhone'], message);
      }
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber, String message) async {
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final formattedNumber =
        cleanedNumber.startsWith('+') ? cleanedNumber : '+20$cleanedNumber';
    final whatsappUrl =
        "https://wa.me/$formattedNumber?text=${Uri.encodeComponent(message)}";

    try {
      if (await canLaunch(whatsappUrl)) {
        await launch(whatsappUrl);
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
      case 'paid':
        return Colors.green;
      case 'approved':
        return Colors.blue;
      case 'unpaid':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateRequestStatus(
    String requestId,
    String newStatus,
    Map<String, dynamic> data,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({'status': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request marked as $newStatus!'),
          backgroundColor: newStatus == 'paid' ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDeletion(BuildContext context, String requestId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Request',
              style: TextStyle(color: WebsiteColors.primaryBlueColor),
            ),
            content: Text(
              'Are you sure you want to delete this request? This action cannot be undone.',
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
      await _deleteRequest(requestId);
    }
  }

  Future<void> _deleteRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
