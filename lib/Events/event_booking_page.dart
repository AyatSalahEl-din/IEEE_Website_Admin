import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EventBookingPage extends StatefulWidget {
  @override
  _EventBookingPageState createState() => _EventBookingPageState();
}

class _EventBookingPageState extends State<EventBookingPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _userPhoneController = TextEditingController();
  Event? _selectedEvent;
  int _numberOfTickets = 1;
  int _numberOfBusTickets = 0;
  String _userType = 'Regular';
  double _totalPrice = 0.0;

  @override
  void dispose() {
    _userNameController.dispose();
    _userEmailController.dispose();
    _userPhoneController.dispose();
    super.dispose();
  }

  Future<void> _sendBookingRequest() async {
    if (_selectedEvent == null) return;

    // Ensure all personal details are filled
    if (_userNameController.text.trim().isEmpty ||
        _userEmailController.text.trim().isEmpty ||
        _userPhoneController.text.trim().isEmpty) {
      _showError('Please fill in all personal details (Name, Email, Phone).');
      return;
    }

    try {
      // Generate a unique order number
      final orderNumber = DateTime.now().millisecondsSinceEpoch.toString();

      final bookingData = {
        'orderNumber': orderNumber, // Add order number to the request
        'userName': _userNameController.text.trim(),
        'userEmail': _userEmailController.text.trim(),
        'userPhone': _userPhoneController.text.trim(),
        'eventName': _selectedEvent!.name,
        'requestDate': Timestamp.now(),
        'status': 'pending',
        'busRequired': _numberOfBusTickets > 0,
        'numberOfTickets': _numberOfTickets,
        'userType': _userType,
        'totalPrice': _totalPrice,
      };

      // Save booking details to Firebase
      await FirebaseFirestore.instance.collection('requests').add(bookingData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking request sent successfully! Order Number: $orderNumber',
          ),
        ),
      );

      // Show confirmation dialog with order number
      _showOrderConfirmationDialog(orderNumber);

      // Send WhatsApp message with order number
      _sendWhatsAppMessage(_selectedEvent!, orderNumber);
    } catch (e) {
      _showError('Failed to send booking request: $e');
    }
  }

  Future<void> _sendWhatsAppMessage(Event event, String orderNumber) async {
    final message = '''
Hello, I would like to confirm my booking for the following event:

Event Details:
- Name: ${event.name}
- Date: ${DateFormat('yyyy-MM-dd').format(event.date)}
- Location: ${event.location}
- Time: ${event.time}

Booking Details:
- Order Number: $orderNumber
- Name: ${_userNameController.text}
- Email: ${_userEmailController.text}
- Phone: ${_userPhoneController.text}
- Number of Tickets: $_numberOfTickets
${_numberOfBusTickets > 0 ? '- Bus Tickets: $_numberOfBusTickets\n' : ''}
- Total Price: \$${_totalPrice.toStringAsFixed(2)}

Admin Contact:
- Phone: ${event.contactNumber ?? "Not provided"}
- Email: ${event.contactEmail ?? "Not provided"}

Please let me know the next steps for payment.
''';

    final whatsappUrl = Uri.parse(
      "https://wa.me/${event.contactNumber}?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      _showError('Could not launch WhatsApp');
    }
  }

  void _showOrderConfirmationDialog(String orderNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Booking Confirmation'),
          content: Text(
            'Your booking request has been sent successfully! Your order number is $orderNumber.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Event selection and personal details form
            // ...
            ElevatedButton(
              onPressed: _sendBookingRequest,
              child: Text('Send Booking Request'),
            ),
          ],
        ),
      ),
    );
  }
}

class Event {
  final String name;
  final DateTime date;
  final String location;
  final String time;
  final String? contactNumber;
  final String? contactEmail;

  Event({
    required this.name,
    required this.date,
    required this.location,
    required this.time,
    this.contactNumber,
    this.contactEmail,
  });
}
