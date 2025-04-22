import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ieee_website/Events/event_widgets/customdropdown.dart';
import 'package:ieee_website/Events/event_widgets/event_model.dart';
import 'package:ieee_website/widgets/customtextfield.dart';
import 'package:ieee_website/widgets/sectiontitle.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Themes/website_colors.dart';

class EventBookingPage extends StatefulWidget {
  const EventBookingPage({Key? key}) : super(key: key);

  @override
  _EventBookingPageState createState() => _EventBookingPageState();
}

class _EventBookingPageState extends State<EventBookingPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedEventId;
  int numberOfTickets = 1;
  bool busRequired = false;
  String? userType; // Student, Teacher, etc.
  String userName = '';
  String userEmail = '';
  String userPhone = '';
  bool isLoading = true;
  List<Event> upcomingEvents = [];

  @override
  void initState() {
    super.initState();
    fetchUpcomingEvents();
  }

  Future<void> fetchUpcomingEvents() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('events')
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()),
              )
              .orderBy('date')
              .get();

      setState(() {
        upcomingEvents =
            snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching events: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  double calculateTotalPrice(Event event) {
    double total = (event.baseTicketPrice ?? 0) * numberOfTickets;
    if (busRequired && event.busDetails != null) {
      total += event.busDetails!.busTicketPrice * numberOfTickets;
    }
    if (userType == event.discountFor) {
      total -= event.discount ?? 0.0;
    }
    return total;
  }

  Future<void> sendBookingRequest(Event event) async {
    final requestData = {
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'eventName': event.name,
      'requestDate': Timestamp.now(),
      'status': 'pending',
      'busRequired': busRequired,
      'numberOfTickets': numberOfTickets,
      'userType': userType,
    };

    await FirebaseFirestore.instance.collection('requests').add(requestData);
  }

  void sendWhatsAppMessage(Event event) async {
    final totalPrice = calculateTotalPrice(event);

    final message = '''
Hello, I would like to book tickets for the following event:

Event Details:
- Name: ${event.name}
- Date: ${event.date}
- Location: ${event.location}
- Time: ${event.time}

${event.getBusDetails()}
${event.getOnlineEventDetails()}

Booking Details:
- Name: $userName
- Email: $userEmail
- Phone: $userPhone
- Number of Tickets: $numberOfTickets
- Total Price: \$${totalPrice.toStringAsFixed(2)}

${event.getContactDetails()}

Please let me know the preferred payment method to proceed.
''';

    final whatsappUrl = Uri.parse(
      "https://wa.me/${event.contactNumber}?text=${Uri.encodeComponent(message)}",
    );
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }

  void confirmBooking(Event event) async {
    if (_formKey.currentState!.validate() && selectedEventId != null) {
      await sendBookingRequest(event);
      sendWhatsAppMessage(event);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking request sent successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WebsiteColors.whiteColor,
      appBar: AppBar(
        backgroundColor: WebsiteColors.primaryBlueColor,
        elevation: 0,
        title: const Text(
          'Book Your Tickets',
          style: TextStyle(color: WebsiteColors.whiteColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: WebsiteColors.whiteColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(title: 'Personal Information'),
                        const SizedBox(height: 15),
                        CustomTextField(
                          label: 'Full Name',
                          fontSize: 24,
                          prefixIcon: Icons.person,
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? 'Please enter your name'
                                      : null,
                          onChanged: (value) => userName = value,
                        ),
                        const SizedBox(height: 15),
                        CustomTextField(
                          label: 'Email Address',
                          fontSize: 24,
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty)
                              return 'Please enter your email';
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          onChanged: (value) => userEmail = value,
                        ),
                        const SizedBox(height: 15),
                        CustomTextField(
                          label: 'Phone Number',
                          fontSize: 24,
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? 'Please enter your phone number'
                                      : null,
                          onChanged: (value) => userPhone = value,
                        ),
                        const SizedBox(height: 30),
                        const SectionTitle(title: 'Event Information'),
                        const SizedBox(height: 15),
                        CustomDropdown<Event>(
                          hintText: 'Select Event',
                          value:
                              selectedEventId != null
                                  ? upcomingEvents.firstWhere(
                                    (event) => event.id == selectedEventId,
                                  )
                                  : null,
                          items:
                              upcomingEvents.map((Event event) {
                                return DropdownMenuItem<Event>(
                                  value: event,
                                  child: Text(
                                    '${event.name} - ${event.date.toLocal()} - ${event.location} - \$${event.baseTicketPrice}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (Event? newValue) {
                            setState(() {
                              selectedEventId = newValue?.id;
                            });
                          },
                        ),
                        if (selectedEventId != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionTitle(title: 'Event Details'),
                                const SizedBox(height: 10),
                                Text('''
Name: ${upcomingEvents.firstWhere((event) => event.id == selectedEventId).name}
Date: ${upcomingEvents.firstWhere((event) => event.id == selectedEventId).date.toLocal()}
Location: ${upcomingEvents.firstWhere((event) => event.id == selectedEventId).location}
Time: ${upcomingEvents.firstWhere((event) => event.id == selectedEventId).time}
Category: ${upcomingEvents.firstWhere((event) => event.id == selectedEventId).category}
Description: ${upcomingEvents.firstWhere((event) => event.id == selectedEventId).details}
Discount: ${upcomingEvents.firstWhere((event) => event.id == selectedEventId).discount ?? 'None'}
Eligible For Discount: ${upcomingEvents.firstWhere((event) => event.id == selectedEventId).discountFor ?? 'None'}
Bus Available: ${upcomingEvents.firstWhere((event) => event.id == selectedEventId).busDetails != null ? 'Yes' : 'No'}
Contact Number: ${upcomingEvents.firstWhere((event) => event.id == selectedEventId).contactNumber ?? 'Not provided'}
Contact Email: ${upcomingEvents.firstWhere((event) => event.id == selectedEventId).contactEmail ?? 'Not provided'}
''', style: const TextStyle(fontSize: 16)),
                                if (upcomingEvents
                                        .firstWhere(
                                          (event) =>
                                              event.id == selectedEventId,
                                        )
                                        .busDetails !=
                                    null)
                                  Text('''
Bus Details:
- Departure Location: ${upcomingEvents.firstWhere((event) => event.id == selectedEventId).busDetails!.departureLocation}
- Arrival Location: ${upcomingEvents.firstWhere((event) => event.id == selectedEventId).busDetails!.arrivalLocation}
- Departure Time: ${upcomingEvents.firstWhere((event) => event.id == selectedEventId).busDetails!.departureTime}
- Ticket Price: \$${upcomingEvents.firstWhere((event) => event.id == selectedEventId).busDetails!.busTicketPrice}
''', style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Text(
                              "Include Bus Ticket?",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: WebsiteColors.darkBlueColor,
                              ),
                            ),
                            Checkbox(
                              value: busRequired,
                              checkColor: WebsiteColors.whiteColor,
                              activeColor: WebsiteColors.primaryBlueColor,
                              onChanged: (value) {
                                setState(() {
                                  busRequired = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        CustomDropdown<String>(
                          hintText: 'Select User Type',
                          value: userType,
                          items:
                              ['Student', 'Teacher', 'Other']
                                  .map(
                                    (type) => DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              userType = value;
                            });
                          },
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate() &&
                                selectedEventId != null) {
                              final selectedEvent = upcomingEvents.firstWhere(
                                (event) => event.id == selectedEventId,
                              );
                              confirmBooking(selectedEvent);
                            }
                          },
                          child: const Text('Confirm Booking'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
