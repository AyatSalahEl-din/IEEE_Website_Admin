import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ieee_website/Events/event_widgets/customdropdown.dart';
import 'package:ieee_website/Events/event_widgets/event_model.dart';
import 'package:ieee_website/Themes/website_colors.dart';
import 'package:ieee_website/widgets/customtextfield.dart';
import 'package:ieee_website/widgets/sectiontitle.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EventBookingPage extends StatefulWidget {
  const EventBookingPage({Key? key}) : super(key: key);

  @override
  State<EventBookingPage> createState() => _EventBookingPageState();
}

class _EventBookingPageState extends State<EventBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _userEmailController = TextEditingController();
  final _userPhoneController = TextEditingController();

  String? _selectedEventId;
  int _numberOfTickets = 1;
  int _numberOfBusTickets = 0;
  String? _userType;
  bool _isLoading = true;
  List<Event> _upcomingEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchUpcomingEvents();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _userEmailController.dispose();
    _userPhoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchUpcomingEvents() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('events')
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()),
              )
              .orderBy('date')
              .get();

      setState(() {
        _upcomingEvents =
            snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
        _isLoading = false;
      });
    } catch (e) {
      _showError('Failed to load events: $e');
      setState(() => _isLoading = false);
    }
  }

  Event? get _selectedEvent {
    if (_selectedEventId == null) return null;
    return _upcomingEvents.firstWhere((event) => event.id == _selectedEventId);
  }

  double get _totalPrice {
    if (_selectedEvent == null) return 0.0;

    final event = _selectedEvent!;
    double total =
        event.isOnlineEvent
            ? 0.0
            : (event.baseTicketPrice ?? 0) * _numberOfTickets;

    // Apply discount if eligible (case-insensitive comparison)
    if (_userType != null &&
        event.discountFor != null &&
        _userType!.toLowerCase() == event.discountFor!.toLowerCase() &&
        event.discount != null) {
      total -= (event.discount! / 100) * total;
    }

    if (!event.isOnlineEvent && event.busDetails != null) {
      total += event.busDetails!.busTicketPrice * _numberOfBusTickets;
    }

    return total.clamp(0.0, double.infinity);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendBookingRequest() async {
    if (_selectedEvent == null) return;

    if (_userNameController.text.trim().isEmpty ||
        _userEmailController.text.trim().isEmpty ||
        _userPhoneController.text.trim().isEmpty) {
      _showError('Please fill in all personal details before booking.');
      return;
    }

    try {
      final bookingData = {
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
        const SnackBar(content: Text('Booking request sent successfully!')),
      );
    } catch (e) {
      _showError('Failed to send booking request: $e');
    }
  }

  // ignore: unused_element
  Future<void> _sendWhatsAppMessage(Event event) async {
    final message = '''
Hello, I would like to confirm my booking for the following event:

Event Details:
- Name: ${event.name}
- Date: ${DateFormat('yyyy-MM-dd').format(event.date)}
- Location: ${event.location}
- Time: ${event.time}

Booking Details:
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

  void _confirmBooking() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEvent == null) {
      _showError('Please select an event');
      return;
    }

    final event = _selectedEvent!;
    if (event.isOnlineEvent) {
      _confirmOnlineAttendance(event);
    } else {
      _confirmTicketBooking(event);
    }
  }

  void _confirmOnlineAttendance(Event event) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Attendance'),
            content: Text(
              'You are about to confirm your attendance for the online event "${event.name}".\n\n'
              'App: ${event.appName ?? "Not provided"}\n'
              'URL: ${event.appUrl ?? "Not provided"}\n'
              'Time: ${event.appTime ?? "Not provided"}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _sendAttendanceConfirmation(event);
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }

  void _confirmTicketBooking(Event event) {
    if (!_formKey.currentState!.validate()) {
      _showError('Please fill in all required fields.');
      return;
    }

    if (_userNameController.text.trim().isEmpty ||
        _userEmailController.text.trim().isEmpty ||
        _userPhoneController.text.trim().isEmpty) {
      _showError(
        'Please fill in all personal details before confirming the booking.',
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'Confirm Booking',
              style: TextStyle(
                color: WebsiteColors.primaryBlueColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Event Details:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: WebsiteColors.darkBlueColor,
                    ),
                  ),
                  Text(
                    'Name: ${event.name}',
                    style: const TextStyle(
                      color: WebsiteColors.primaryBlueColor,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(event.date)}',
                    style: const TextStyle(
                      color: WebsiteColors.primaryBlueColor,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Location: ${event.location}',
                    style: const TextStyle(
                      color: WebsiteColors.primaryBlueColor,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Time: ${event.time}',
                    style: const TextStyle(
                      color: WebsiteColors.primaryBlueColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Personal Details:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: WebsiteColors.darkBlueColor,
                    ),
                  ),
                  Text(
                    'Name: ${_userNameController.text.trim()}',
                    style: const TextStyle(
                      color: WebsiteColors.primaryBlueColor,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Email: ${_userEmailController.text.trim()}',
                    style: const TextStyle(
                      color: WebsiteColors.primaryBlueColor,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Phone: ${_userPhoneController.text.trim()}',
                    style: const TextStyle(
                      color: WebsiteColors.primaryBlueColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Booking Details:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: WebsiteColors.darkBlueColor,
                    ),
                  ),
                  Text(
                    'Number of Tickets: $_numberOfTickets',
                    style: const TextStyle(
                      color: WebsiteColors.primaryBlueColor,
                      fontSize: 14,
                    ),
                  ),
                  if (_numberOfBusTickets > 0)
                    Text(
                      'Bus Tickets: $_numberOfBusTickets',
                      style: const TextStyle(
                        color: WebsiteColors.primaryBlueColor,
                        fontSize: 14,
                      ),
                    ),
                  Text(
                    'Total Price: \$${_totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: WebsiteColors.primaryBlueColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Admin Contact:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: WebsiteColors.darkBlueColor,
                    ),
                  ),
                  Text(
                    'Phone: ${event.contactNumber ?? "Not provided"}',
                    style: const TextStyle(
                      color: WebsiteColors.primaryBlueColor,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Email: ${event.contactEmail ?? "Not provided"}',
                    style: const TextStyle(
                      color: WebsiteColors.primaryBlueColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: WebsiteColors.primaryBlueColor,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _sendBookingRequest();
                  _launchWhatsApp(event);
                },
                style: TextButton.styleFrom(
                  foregroundColor: WebsiteColors.primaryBlueColor,
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _launchWhatsApp(Event event) async {
    if (_userNameController.text.trim().isEmpty ||
        _userEmailController.text.trim().isEmpty ||
        _userPhoneController.text.trim().isEmpty) {
      _showError(
        'Please fill in all personal details before sending the WhatsApp message.',
      );
      return;
    }

    final message = '''
Hello, I would like to confirm my booking for the following event:

Event Details:
- Name: ${event.name}
- Date: ${DateFormat('yyyy-MM-dd').format(event.date)}
- Location: ${event.location}
- Time: ${event.time}

Personal Details:
- Name: ${_userNameController.text.trim()}
- Email: ${_userEmailController.text.trim()}
- Phone: ${_userPhoneController.text.trim()}

Booking Details:
- Number of Tickets: $_numberOfTickets
${_numberOfBusTickets > 0 ? '- Bus Tickets: $_numberOfBusTickets\n' : ''}
- Total Price: \$${_totalPrice.toStringAsFixed(2)}

Please confirm the payment method and next steps.
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

  Future<void> _sendAttendanceConfirmation(Event event) async {
    try {
      await FirebaseFirestore.instance.collection('attendance').add({
        'userName': _userNameController.text,
        'userEmail': _userEmailController.text,
        'userPhone': _userPhoneController.text,
        'eventName': event.name,
        'confirmationDate': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance confirmed successfully!')),
      );
    } catch (e) {
      _showError('Failed to confirm attendance: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: WebsiteColors.primaryBlueColor,
        elevation: 0,
        title: const Text(
          'Book Your Tickets',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: 'Personal Information'),
                      const SizedBox(height: 16),
                      CustomTextField(
                        fontSize: 16,
                        onChanged: (value) {},
                        controller: _userNameController,
                        label: 'Full Name',
                        prefixIcon: Icons.person,
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Please enter your name'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _userEmailController,
                        label: 'Email Address',
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        fontSize: 16,
                        onChanged: (value) {},
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Please enter your email';
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value!)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _userPhoneController,
                        label: 'Phone Number',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        fontSize: 16,
                        onChanged: (value) {},
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Please enter your phone number'
                                    : null,
                      ),
                      const SizedBox(height: 24),
                      const SectionTitle(title: 'Event Information'),
                      const SizedBox(height: 16),
                      CustomDropdown<Event>(
                        hintText: 'Select Event',
                        value: _selectedEvent,
                        items:
                            _upcomingEvents.map((event) {
                              return DropdownMenuItem<Event>(
                                value: event,
                                child: Text(
                                  '${event.name} - ${DateFormat('MMM d').format(event.date)}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: WebsiteColors.primaryBlueColor,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (event) {
                          setState(() {
                            _selectedEventId = event?.id;
                            _numberOfBusTickets = 0;
                            _userType = null;
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'Please select an event' : null,
                      ),
                      if (_selectedEvent != null) ...[
                        const SizedBox(height: 24),
                        _buildEventDetailsSection(),
                        const SizedBox(height: 24),
                        _buildTicketSelectionSection(),
                        const SizedBox(height: 24),
                        _buildTotalPriceSection(),
                        const SizedBox(height: 24),
                        _buildBookButton(),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildEventDetailsSection() {
    final event = _selectedEvent!;
    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Event Details:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: WebsiteColors.darkBlueColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Name: ${event.name}',
              style: const TextStyle(color: WebsiteColors.darkBlueColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${DateFormat('EEE, MMM d, y').format(event.date)}',
              style: const TextStyle(color: WebsiteColors.darkBlueColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Time: ${event.time}',
              style: const TextStyle(color: WebsiteColors.darkBlueColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Location: ${event.location}',
              style: const TextStyle(color: WebsiteColors.darkBlueColor),
            ),
            const SizedBox(height: 16),
            if (event.isOnlineEvent) ...[
              const Text(
                'This is an online event.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'App: ${event.appName ?? "Not provided"}',
                style: const TextStyle(color: WebsiteColors.darkBlueColor),
              ),
              Text(
                'URL: ${event.appUrl ?? "Not provided"}',
                style: const TextStyle(color: WebsiteColors.darkBlueColor),
              ),
              Text(
                'Time: ${event.appTime ?? "Not provided"}',
                style: const TextStyle(color: WebsiteColors.darkBlueColor),
              ),
            ] else ...[
              Text(
                'Price: \$${event.baseTicketPrice?.toStringAsFixed(2) ?? 'Free'}',
                style: const TextStyle(color: WebsiteColors.darkBlueColor),
              ),
              if (event.discount != null && event.discountFor != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Discount: ${event.discount}% for ${event.discountFor}',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
              if (event.busDetails != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Bus available: \$${event.busDetails!.busTicketPrice.toStringAsFixed(2)} per ticket',
                  style: const TextStyle(color: WebsiteColors.darkBlueColor),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTicketSelectionSection() {
    final event = _selectedEvent!;
    if (event.isOnlineEvent) {
      return const Text(
        'No tickets required for online events. Confirm your attendance below.',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: WebsiteColors.primaryBlueColor,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Ticket Options'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Number of Tickets:',
              style: TextStyle(color: WebsiteColors.primaryBlueColor),
            ),
            DropdownButton<int>(
              value: _numberOfTickets,
              items:
                  List.generate(10, (index) => index + 1)
                      .map(
                        (num) => DropdownMenuItem<int>(
                          value: num,
                          child: Text(
                            num.toString(),
                            style: const TextStyle(
                              color: WebsiteColors.primaryBlueColor,
                            ),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _numberOfTickets = value!;
                  if (_numberOfBusTickets > _numberOfTickets) {
                    _numberOfBusTickets = _numberOfTickets;
                  }
                });
              },
            ),
          ],
        ),
        if (event.discountFor != null) ...[
          const SizedBox(height: 16),
          Text(
            'See if you are  applicable for a discount?:',
            style: TextStyle(color: WebsiteColors.primaryBlueColor),
          ),
          const SizedBox(height: 8),
          CustomDropdown<String>(
            hintText:
                'Please select your category (e.g., Student, Teacher, Other)',
            value: _userType,
            items:
                ['Students', 'Teachers', 'Others']
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: WebsiteColors.primaryBlueColor,
                          ),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _userType = value),
            validator:
                (value) => value == null ? 'Please select your category' : null,
          ),
        ],
        if (event.busDetails != null) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bus Tickets:',
                style: TextStyle(color: WebsiteColors.primaryBlueColor),
              ),
              DropdownButton<int>(
                value: _numberOfBusTickets,
                items:
                    List.generate(_numberOfTickets + 1, (index) => index)
                        .map(
                          (num) => DropdownMenuItem<int>(
                            value: num,
                            child: Text(
                              num.toString(),
                              style: const TextStyle(
                                color: WebsiteColors.primaryBlueColor,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                onChanged:
                    (value) => setState(() => _numberOfBusTickets = value!),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTotalPriceSection() {
    if (_selectedEvent?.isOnlineEvent ?? false) {
      return const Text(
        'No payment required for online events.',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      );
    }

    return Card(
      color: WebsiteColors.primaryBlueColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Price:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: WebsiteColors.darkBlueColor,
              ),
            ),
            Text(
              '\$${_totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: WebsiteColors.primaryBlueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _confirmBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: WebsiteColors.primaryBlueColor, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Book Now',
          style: TextStyle(
            fontSize: 18,
            color: WebsiteColors.primaryBlueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
