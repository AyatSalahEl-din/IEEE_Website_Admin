import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'Date_picker_tile.dart';
import 'custom_text_form_field.dart';
import 'custom_elevated_button.dart';
import 'package:ieee_website/Themes/website_colors.dart';

class EditEventPage extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const EditEventPage({
    super.key,
    required this.eventId,
    required this.eventData,
  });

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _timeController;
  List<String> _imageUrls = [];
  DateTime? _selectedDate;
  // ignore: unused_field
  bool _isLoading = false;
  late TextEditingController _ticketPriceController;
  late TextEditingController _discountController;
  late TextEditingController _discountForController;
  late TextEditingController _busTicketPriceController;
  late TextEditingController _busSeatsController;
  late TextEditingController _busSourceController;
  late TextEditingController _busDestinationController;
  late TextEditingController _tripExplanationController;
  late TextEditingController _contactNumberController;
  late TextEditingController _contactEmailController;
  late TextEditingController _busDepartureTimeController;
  late TextEditingController _busArrivalTimeController;
  bool _isBusAvailable = false;
  bool _isTicketAvailable = false;
  bool _isTicketLimited = false;
  bool _isSeatBookingAvailable = false;
  int? _ticketLimit;
  int? _numberOfBuses;
  int? _seatsPerBus;
  bool _isOnlineEvent = false;
  String? _selectedApp;
  late TextEditingController _appTimeController;
  late TextEditingController _appUrlController;
  late TextEditingController _appNameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.eventData['name']);
    _categoryController = TextEditingController(
      text: widget.eventData['category'],
    );
    _descriptionController = TextEditingController(
      text: widget.eventData['details'],
    );
    _locationController = TextEditingController(
      text: widget.eventData['location'],
    );
    _timeController = TextEditingController(text: widget.eventData['time']);
    _imageUrls = List<String>.from(widget.eventData['imageUrls'] ?? []);
    _selectedDate = (widget.eventData['date'] as Timestamp).toDate();
    _ticketPriceController = TextEditingController(
      text: widget.eventData['ticketPrice']?.toString() ?? '',
    );
    _discountController = TextEditingController(
      text: widget.eventData['discount'] ?? '',
    );
    _discountForController = TextEditingController(
      text: widget.eventData['discountFor'] ?? '',
    );
    _busTicketPriceController = TextEditingController(
      text: widget.eventData['busDetails']?['ticketPrice']?.toString() ?? '',
    );
    _busSeatsController = TextEditingController(
      text: widget.eventData['busDetails']?['seats']?.toString() ?? '',
    );
    _busSourceController = TextEditingController(
      text: widget.eventData['busDetails']?['source'] ?? '',
    );
    _busDestinationController = TextEditingController(
      text: widget.eventData['busDetails']?['destination'] ?? '',
    );
    _tripExplanationController = TextEditingController(
      text: widget.eventData['busDetails']?['tripExplanation'] ?? '',
    );
    _contactNumberController = TextEditingController(
      text: widget.eventData['contact']?['number'] ?? '',
    );
    _contactEmailController = TextEditingController(
      text: widget.eventData['contact']?['email'] ?? '',
    );
    _busDepartureTimeController = TextEditingController(
      text: widget.eventData['busDetails']?['departureTime'] ?? '',
    );
    _busArrivalTimeController = TextEditingController(
      text: widget.eventData['busDetails']?['arrivalTime'] ?? '',
    );
    _isBusAvailable = widget.eventData['busDetails'] != null;
    _isTicketAvailable = widget.eventData['isTicketAvailable'] ?? false;
    _isTicketLimited = widget.eventData['isTicketLimited'] ?? false;
    _isSeatBookingAvailable =
        widget.eventData['busDetails']?['isSeatBookingAvailable'] ?? false;
    _ticketLimit = widget.eventData['ticketLimit'];
    _numberOfBuses = widget.eventData['busDetails']?['numberOfBuses'];
    _seatsPerBus = widget.eventData['busDetails']?['seatsPerBus'];
    _isOnlineEvent = widget.eventData['isOnlineEvent'] ?? false;
    _appTimeController = TextEditingController(
      text: widget.eventData['appTime'] ?? '',
    );
    _appUrlController = TextEditingController(
      text: widget.eventData['appUrl'] ?? '',
    );
    _selectedApp = widget.eventData['appName'] ?? '';
    _appNameController = TextEditingController(
      text: _selectedApp == 'Other' ? widget.eventData['appName'] : '',
    );
  }

  @override
  void dispose() {
    _appTimeController.dispose();
    _appUrlController.dispose();
    _appNameController.dispose();
    super.dispose();
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Convert category to uppercase
      final category = _categoryController.text.trim().toUpperCase();

      // Check if the category already exists in Firestore
      final existingCategories =
          await FirebaseFirestore.instance
              .collection('events')
              .where('category', isEqualTo: category)
              .get();

      if (existingCategories.docs.isNotEmpty) {
        // If the category exists, use the existing category name
        _categoryController.text = existingCategories.docs.first['category'];
      } else {
        // Otherwise, save the category in uppercase
        _categoryController.text = category;
      }

      final updatedData = {
        'name': _nameController.text,
        'category': _categoryController.text.trim(),
        'details': _descriptionController.text,
        'location': _locationController.text,
        'time': _timeController.text,
        'date': _selectedDate,
        'month': DateFormat.MMMM().format(_selectedDate!),
        'imageUrls': _imageUrls,
        'ticketPrice':
            double.tryParse(_ticketPriceController.text.trim()) ?? 0.0,
        'discount': _discountController.text.trim(),
        'discountFor': _discountForController.text.trim(),
        'isTicketAvailable': _isTicketAvailable,
        'isTicketLimited': _isTicketLimited,
        'ticketLimit': _isTicketLimited ? _ticketLimit : null,
        'busDetails':
            _isBusAvailable
                ? {
                  'numberOfBuses': _numberOfBuses,
                  'seatsPerBus': _seatsPerBus,
                  'isSeatBookingAvailable': _isSeatBookingAvailable,
                  'ticketPrice':
                      double.tryParse(_busTicketPriceController.text.trim()) ??
                      0.0,
                  'seats': int.tryParse(_busSeatsController.text.trim()) ?? 0,
                  'source': _busSourceController.text.trim(),
                  'destination': _busDestinationController.text.trim(),
                  'tripExplanation': _tripExplanationController.text.trim(),
                  'departureTime': _busDepartureTimeController.text.trim(),
                  'arrivalTime': _busArrivalTimeController.text.trim(),
                }
                : null,
        'contact': {
          'number': _contactNumberController.text.trim(),
          'email': _contactEmailController.text.trim(),
        },
        'isOnlineEvent': _isOnlineEvent,
        'appTime': _appTimeController.text.trim(),
        'appUrl': _appUrlController.text.trim(),
        'appName':
            _selectedApp == 'Other'
                ? _appNameController.text.trim()
                : _selectedApp,
      };

      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .update(updatedData);

      setState(() => _isLoading = false);
      if (mounted) Navigator.pop(context); // go back after saving
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _addImage() async {
    TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: WebsiteColors.whiteColor,
          title: Text(
            "Enter Image URL",
            style: TextStyle(
              color: WebsiteColors.primaryBlueColor,
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: urlController,
            decoration: InputDecoration(
              hintText: "Enter image URL",
              hintStyle: TextStyle(
                color: WebsiteColors.greyColor,
                fontSize: 32.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0.sp),
                borderSide: BorderSide(color: WebsiteColors.primaryBlueColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0.sp),
                borderSide: BorderSide(color: WebsiteColors.primaryBlueColor),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: 10.sp,
                  horizontal: 15.sp,
                ),
                foregroundColor: Colors.black,
                backgroundColor: Colors.grey,
              ),
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                final url = urlController.text.trim();
                if (url.isNotEmpty) {
                  setState(() => _imageUrls.add(url));
                }
                Navigator.pop(context); // Close dialog
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: 6.sp,
                  horizontal: 10.sp,
                ),
                foregroundColor: WebsiteColors.whiteColor,
                backgroundColor: WebsiteColors.primaryBlueColor,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Event"),
        backgroundColor: WebsiteColors.primaryBlueColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 25.sp),
              CustomTextFormField(
                controller: _nameController,
                labelText: "Event Name",
                icon: Icons.event,
              ),
              SizedBox(height: 25.sp),
              CustomTextFormField(
                controller: _categoryController,
                labelText: "Category",
                icon: Icons.category,
              ),
              SizedBox(height: 25.sp),
              CustomTextFormField(
                controller: _descriptionController,
                labelText: "Description",
                icon: Icons.description,
                isMultiline: true,
              ),
              SizedBox(height: 25.sp),
              CustomTextFormField(
                controller: _locationController,
                labelText: "Location",
                icon: Icons.location_on,
              ),
              SizedBox(height: 25.sp),
              CustomTextFormField(
                controller: _timeController,
                labelText: "Time",
                icon: Icons.access_time,
              ),
              SizedBox(height: 25.sp),

              // Use CustomDatePicker widget here
              CustomDatePicker(
                initialDate: _selectedDate,
                onDatePicked: (newDateTime) {
                  setState(() {
                    _selectedDate = newDateTime;
                  });
                },
              ),

              const SizedBox(height: 20),

              if (_imageUrls.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _imageUrls.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final url = _imageUrls[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            url,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) =>
                                    const Icon(Icons.broken_image, size: 40),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed:
                                  () => setState(
                                    () => _imageUrls.removeAt(index),
                                  ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 16),

              // Add Image Button
              CustomElevatedButton(label: '+ Add Image', onPressed: _addImage),

              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Is Online Event?'),
                value: _isOnlineEvent,
                onChanged: (value) {
                  setState(() {
                    _isOnlineEvent = value;
                    if (_isOnlineEvent) {
                      _isTicketAvailable = false; // Disable tickets if online
                      _isBusAvailable = false; // Disable buses if online
                    }
                  });
                },
              ),
              if (_isOnlineEvent) ...[
                CustomTextFormField(
                  controller: _appTimeController,
                  labelText: 'Exact Time',
                  icon: Icons.access_time,
                ),
                CustomTextFormField(
                  controller: _appUrlController,
                  labelText: 'Pre-URL (Optional)',
                  icon: Icons.link,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedApp,
                  items:
                      ['Zoom', 'Microsoft Teams', 'Google Meet', 'Other'].map((
                        app,
                      ) {
                        return DropdownMenuItem(value: app, child: Text(app));
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedApp = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Select App Hosting',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (_selectedApp == 'Other')
                  CustomTextFormField(
                    controller: _appNameController,
                    labelText: 'App Name',
                    icon: Icons.apps,
                  ),
              ],
              if (!_isOnlineEvent) ...[
                SwitchListTile(
                  title: const Text('Are Tickets Available?'),
                  value: _isTicketAvailable,
                  onChanged: (value) {
                    setState(() {
                      _isTicketAvailable = value;
                      if (!_isTicketAvailable) {
                        _isBusAvailable =
                            false; // Reset bus availability if tickets are unavailable
                      }
                    });
                  },
                ),
                if (_isTicketAvailable) ...[
                  SwitchListTile(
                    title: const Text('Are Tickets Limited?'),
                    value: _isTicketLimited,
                    onChanged: (value) {
                      setState(() {
                        _isTicketLimited = value;
                      });
                    },
                  ),
                  if (_isTicketLimited)
                    CustomTextFormField(
                      controller: TextEditingController(
                        text: _ticketLimit?.toString() ?? '',
                      ),
                      labelText: 'Ticket Limit',
                      icon: Icons.confirmation_number,
                    ),
                  CustomTextFormField(
                    controller: _ticketPriceController,
                    labelText: 'Ticket Price',
                    icon: Icons.attach_money,
                  ),
                  CustomTextFormField(
                    controller: _discountController,
                    labelText: 'Discount',
                    icon: Icons.discount,
                  ),
                  CustomTextFormField(
                    controller: _discountForController,
                    labelText: 'Discount For',
                    icon: Icons.group,
                  ),
                  SwitchListTile(
                    title: const Text('Is Bus Available?'),
                    value: _isBusAvailable,
                    onChanged: (value) {
                      setState(() {
                        _isBusAvailable = value;
                      });
                    },
                  ),
                  if (_isBusAvailable) ...[
                    CustomTextFormField(
                      controller: TextEditingController(
                        text: _numberOfBuses?.toString() ?? '',
                      ),
                      labelText: 'Number of Buses',
                      icon: Icons.directions_bus,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Enter number of buses'
                                  : null,
                    ),
                    CustomTextFormField(
                      controller: TextEditingController(
                        text: _seatsPerBus?.toString() ?? '',
                      ),
                      labelText: 'Seats Per Bus',
                      icon: Icons.event_seat,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Enter seats per bus'
                                  : null,
                    ),
                    CustomTextFormField(
                      controller: _busTicketPriceController,
                      labelText: 'Bus Ticket Price',
                      icon: Icons.directions_bus,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Enter bus ticket price'
                                  : null,
                    ),
                    CustomTextFormField(
                      controller: _busSourceController,
                      labelText: 'Bus Source',
                      icon: Icons.location_on,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Enter bus source'
                                  : null,
                    ),
                    CustomTextFormField(
                      controller: _busDestinationController,
                      labelText: 'Bus Destination',
                      icon: Icons.location_on,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Enter bus destination'
                                  : null,
                    ),
                    CustomTextFormField(
                      controller: _busDepartureTimeController,
                      labelText: 'Bus Departure Time',
                      icon: Icons.access_time,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Enter departure time'
                                  : null,
                    ),
                    CustomTextFormField(
                      controller: _busArrivalTimeController,
                      labelText: 'Bus Arrival Time',
                      icon: Icons.access_time,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Enter arrival time'
                                  : null,
                    ),
                    CustomTextFormField(
                      controller: _tripExplanationController,
                      labelText: 'Program Details',
                      icon: Icons.info,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Enter program details'
                                  : null,
                    ),
                  ],
                ],
              ],
              CustomTextFormField(
                controller: _contactNumberController,
                labelText: 'Contact Number',
                icon: Icons.phone,
              ),
              CustomTextFormField(
                controller: _contactEmailController,
                labelText: 'Contact Email',
                icon: Icons.email,
              ),
              CustomElevatedButton(
                label: 'Update Event',
                onPressed: _updateEvent,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
