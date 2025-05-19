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
  late TextEditingController _ticketLimitController;
  late TextEditingController _numberOfBusesController;
  late TextEditingController _seatsPerBusController;
  bool _isBusAvailable = false;
  bool _isTicketAvailable = false;
  bool _isTicketLimited = false;
  bool _isSeatBookingAvailable = false;
  bool _isOnlineEvent = false;
  String? _selectedApp;
  late TextEditingController _appTimeController;
  late TextEditingController _appUrlController;
  late TextEditingController _appNameController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(
      text: widget.eventData['name'] ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.eventData['category'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.eventData['details'] ?? '',
    );
    _locationController = TextEditingController(
      text: widget.eventData['location'] ?? '',
    );
    _timeController = TextEditingController(
      text: widget.eventData['time'] ?? '',
    );
    _imageUrls = List<String>.from(widget.eventData['imageUrls'] ?? []);
    _selectedDate =
        widget.eventData['date'] != null
            ? (widget.eventData['date'] as Timestamp).toDate()
            : null;

    // Ticket related controllers
    _ticketPriceController = TextEditingController(
      text: widget.eventData['ticketPrice']?.toString() ?? '',
    );
    _discountController = TextEditingController(
      text: widget.eventData['discount']?.toString() ?? '',
    );
    _discountForController = TextEditingController(
      text: widget.eventData['discountFor'] ?? '',
    );
    _isTicketAvailable = widget.eventData['isTicketAvailable'] ?? false;
    _isTicketLimited = widget.eventData['isTicketLimited'] ?? false;
    _ticketLimitController = TextEditingController(
      text: widget.eventData['ticketLimit']?.toString() ?? '',
    );

    // Bus related controllers
    final busDetails = widget.eventData['busDetails'] ?? {};
    _isBusAvailable = busDetails.isNotEmpty;
    _busTicketPriceController = TextEditingController(
      text: busDetails['ticketPrice']?.toString() ?? '',
    );
    _busSeatsController = TextEditingController(
      text: busDetails['seats']?.toString() ?? '',
    );
    _busSourceController = TextEditingController(
      text: busDetails['source'] ?? '',
    );
    _busDestinationController = TextEditingController(
      text: busDetails['destination'] ?? '',
    );
    _tripExplanationController = TextEditingController(
      text: busDetails['tripExplanation'] ?? '',
    );
    _busDepartureTimeController = TextEditingController(
      text: busDetails['departureTime'] ?? '',
    );
    _busArrivalTimeController = TextEditingController(
      text: busDetails['arrivalTime'] ?? '',
    );
    _numberOfBusesController = TextEditingController(
      text: busDetails['numberOfBuses']?.toString() ?? '',
    );
    _seatsPerBusController = TextEditingController(
      text: busDetails['seatsPerBus']?.toString() ?? '',
    );
    _isSeatBookingAvailable = busDetails['isSeatBookingAvailable'] ?? false;

    // Contact controllers
    final contact = widget.eventData['contact'] ?? {};
    _contactNumberController = TextEditingController(
      text: contact['number'] ?? '',
    );
    _contactEmailController = TextEditingController(
      text: contact['email'] ?? '',
    );

    // Online event controllers
    _isOnlineEvent = widget.eventData['isOnlineEvent'] ?? false;
    _appTimeController = TextEditingController(
      text: widget.eventData['appTime'] ?? '',
    );
    _appUrlController = TextEditingController(
      text: widget.eventData['appUrl'] ?? '',
    );

    final appName = widget.eventData['appName'];
    if (appName != null &&
        ['Zoom', 'Microsoft Teams', 'Google Meet', 'Other'].contains(appName)) {
      _selectedApp = appName;
    } else if (appName != null) {
      _selectedApp = 'Other';
      _appNameController = TextEditingController(text: appName);
    } else {
      _appNameController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    _ticketPriceController.dispose();
    _discountController.dispose();
    _discountForController.dispose();
    _busTicketPriceController.dispose();
    _busSeatsController.dispose();
    _busSourceController.dispose();
    _busDestinationController.dispose();
    _tripExplanationController.dispose();
    _contactNumberController.dispose();
    _contactEmailController.dispose();
    _busDepartureTimeController.dispose();
    _busArrivalTimeController.dispose();
    _appTimeController.dispose();
    _appUrlController.dispose();
    _appNameController.dispose();
    _ticketLimitController.dispose();
    _numberOfBusesController.dispose();
    _seatsPerBusController.dispose();
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final category = _categoryController.text.trim().toUpperCase();
      final existingCategories =
          await FirebaseFirestore.instance
              .collection('events')
              .where('category', isEqualTo: category)
              .get();

      if (existingCategories.docs.isNotEmpty) {
        _categoryController.text = existingCategories.docs.first['category'];
      } else {
        _categoryController.text = category;
      }

      final updatedData = {
        'name': _nameController.text.trim(),
        'category': _categoryController.text.trim(),
        'details': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'time': _timeController.text.trim(),
        'date':
            _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
        'month':
            _selectedDate != null
                ? DateFormat.MMMM().format(_selectedDate!)
                : null,
        'imageUrls': _imageUrls,
        'isOnlineEvent': _isOnlineEvent,
        if (_isOnlineEvent) ...{
          'appTime': _appTimeController.text.trim(),
          'appUrl': _appUrlController.text.trim(),
          'appName':
              _selectedApp == 'Other'
                  ? _appNameController.text.trim()
                  : _selectedApp,
        },
        if (!_isOnlineEvent) ...{
          'ticketPrice':
              double.tryParse(_ticketPriceController.text.trim()) ?? 0.0,
          'discount':
              double.tryParse(_discountController.text.trim()) ??
              0.0, // Ensure discount is in percentage
          'discountFor': _discountForController.text.trim(),
          'isTicketAvailable': _isTicketAvailable,
          'isTicketLimited': _isTicketLimited,
          'ticketLimit':
              _isTicketLimited
                  ? int.tryParse(_ticketLimitController.text.trim())
                  : null,
          'busDetails':
              _isBusAvailable
                  ? {
                    'numberOfBuses':
                        int.tryParse(_numberOfBusesController.text.trim()) ?? 0,
                    'seatsPerBus':
                        int.tryParse(_seatsPerBusController.text.trim()) ?? 0,
                    'isSeatBookingAvailable': _isSeatBookingAvailable,
                    'ticketPrice':
                        double.tryParse(
                          _busTicketPriceController.text.trim(),
                        ) ??
                        0.0,
                    'seats': int.tryParse(_busSeatsController.text.trim()) ?? 0,
                    'source': _busSourceController.text.trim(),
                    'destination': _busDestinationController.text.trim(),
                    'tripExplanation': _tripExplanationController.text.trim(),
                    'departureTime': _busDepartureTimeController.text.trim(),
                    'arrivalTime': _busArrivalTimeController.text.trim(),
                  }
                  : null,
        },
        'contact': {
          'number': _contactNumberController.text.trim(),
          'email': _contactEmailController.text.trim(),
        },
      };

      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .update(updatedData);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating event: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addImage() async {
    final urlController = TextEditingController();
    final result = await showDialog<String>(
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
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed:
                  () => Navigator.pop(context, urlController.text.trim()),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() => _imageUrls.add(result));
    }
  }

  Widget _buildImageGrid() {
    if (_imageUrls.isEmpty) return const SizedBox();

    return Column(
      children: [
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
                          () => setState(() => _imageUrls.removeAt(index)),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: 20.sp),
      ],
    );
  }

  Widget _buildOnlineEventFields() {
    if (!_isOnlineEvent) return const SizedBox();

    return Column(
      children: [
        CustomTextFormField(
          controller: _appTimeController,
          labelText: 'Exact Time',
          icon: Icons.access_time,
          keyboardType: TextInputType.text,
          validator:
              (value) => value?.isEmpty ?? true ? 'Enter exact time' : null,
        ),
        SizedBox(height: 20.sp),
        CustomTextFormField(
          controller: _appUrlController,
          labelText: 'Pre-URL (Optional)',
          icon: Icons.link,
          keyboardType: TextInputType.text,
        ),
        SizedBox(height: 20.sp),
        DropdownButtonFormField<String>(
          value: _selectedApp,
          items:
              ['Zoom', 'Microsoft Teams', 'Google Meet', 'Other']
                  .map((app) => DropdownMenuItem(value: app, child: Text(app)))
                  .toList(),
          onChanged: (value) => setState(() => _selectedApp = value),
          decoration: InputDecoration(
            labelText: 'Select App Hosting',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) => value == null ? 'Select an app' : null,
        ),
        if (_selectedApp == 'Other') ...[
          SizedBox(height: 20.sp),
          CustomTextFormField(
            controller: _appNameController,
            labelText: 'App Name',
            icon: Icons.apps,
            keyboardType: TextInputType.text,
            validator:
                (value) => value?.isEmpty ?? true ? 'Enter app name' : null,
          ),
        ],
        SizedBox(height: 20.sp),
      ],
    );
  }

  Widget _buildTicketFields() {
    if (_isOnlineEvent) return const SizedBox();

    return Column(
      children: [
        SwitchListTile(
          title: const Text('Are Tickets Available?'),
          value: _isTicketAvailable,
          onChanged:
              (value) => setState(() {
                _isTicketAvailable = value;
                if (!_isTicketAvailable) {
                  _isBusAvailable = false;
                }
              }),
        ),
        if (_isTicketAvailable) ...[
          SwitchListTile(
            title: const Text('Are Tickets Limited?'),
            value: _isTicketLimited,
            onChanged: (value) => setState(() => _isTicketLimited = value),
          ),
          if (_isTicketLimited)
            CustomTextFormField(
              controller: _ticketLimitController,
              labelText: 'Ticket Limit',
              icon: Icons.confirmation_number,
              keyboardType: TextInputType.number,
              validator:
                  (value) =>
                      value?.isEmpty ?? true ? 'Enter ticket limit' : null,
            ),
          SizedBox(height: 20.sp),
          CustomTextFormField(
            controller: _ticketPriceController,
            labelText: 'Ticket Price',
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
            validator:
                (value) => value?.isEmpty ?? true ? 'Enter ticket price' : null,
          ),
          SizedBox(height: 20.sp),
          CustomTextFormField(
            controller: _discountController,
            labelText: 'Discount',
            icon: Icons.discount,
            keyboardType: TextInputType.number,
            validator:
                (value) => value?.isEmpty ?? true ? 'Enter discount' : null,
          ),
          SizedBox(height: 20.sp),
          CustomTextFormField(
            controller: _discountForController,
            labelText: 'Discount For',
            icon: Icons.group,
            keyboardType: TextInputType.text,
            validator:
                (value) => value?.isEmpty ?? true ? 'Enter discount for' : null,
          ),
          SizedBox(height: 20.sp),
          SwitchListTile(
            title: const Text('Is Bus Available?'),
            value: _isBusAvailable,
            onChanged: (value) => setState(() => _isBusAvailable = value),
          ),
          if (_isBusAvailable) _buildBusFields(),
        ],
      ],
    );
  }

  Widget _buildBusFields() {
    return Column(
      children: [
        CustomTextFormField(
          controller: _numberOfBusesController,
          labelText: 'Number of Buses',
          icon: Icons.directions_bus,
          keyboardType: TextInputType.number,
          validator:
              (value) =>
                  value?.isEmpty ?? true ? 'Enter number of buses' : null,
        ),
        SizedBox(height: 20.sp),
        CustomTextFormField(
          controller: _seatsPerBusController,
          labelText: 'Seats Per Bus',
          icon: Icons.event_seat,
          keyboardType: TextInputType.number,
          validator:
              (value) => value?.isEmpty ?? true ? 'Enter seats per bus' : null,
        ),
        SizedBox(height: 20.sp),
        CustomTextFormField(
          controller: _busTicketPriceController,
          labelText: 'Bus Ticket Price',
          icon: Icons.directions_bus,
          keyboardType: TextInputType.number,
          validator:
              (value) =>
                  value?.isEmpty ?? true ? 'Enter bus ticket price' : null,
        ),
        SizedBox(height: 20.sp),
        CustomTextFormField(
          controller: _busSourceController,
          labelText: 'Bus Source',
          icon: Icons.location_on,
          keyboardType: TextInputType.text,
          validator:
              (value) => value?.isEmpty ?? true ? 'Enter bus source' : null,
        ),
        SizedBox(height: 20.sp),
        CustomTextFormField(
          controller: _busDestinationController,
          labelText: 'Bus Destination',
          icon: Icons.location_on,
          keyboardType: TextInputType.text,
          validator:
              (value) =>
                  value?.isEmpty ?? true ? 'Enter bus destination' : null,
        ),
        SizedBox(height: 20.sp),
        CustomTextFormField(
          controller: _busDepartureTimeController,
          labelText: 'Bus Departure Time',
          icon: Icons.access_time,
          keyboardType: TextInputType.text,
          validator:
              (value) => value?.isEmpty ?? true ? 'Enter departure time' : null,
        ),
        SizedBox(height: 20.sp),
        CustomTextFormField(
          controller: _busArrivalTimeController,
          labelText: 'Bus Arrival Time',
          icon: Icons.access_time,
          keyboardType: TextInputType.text,
          validator:
              (value) => value?.isEmpty ?? true ? 'Enter arrival time' : null,
        ),
        SizedBox(height: 20.sp),
        CustomTextFormField(
          controller: _tripExplanationController,
          labelText: 'Program Details',
          icon: Icons.info,
          keyboardType: TextInputType.text,
          validator:
              (value) =>
                  value?.isEmpty ?? true ? 'Enter program details' : null,
        ),
        SizedBox(height: 20.sp),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Event"),
        backgroundColor: WebsiteColors.primaryBlueColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.sp),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 25.sp),
                CustomTextFormField(
                  controller: _nameController,
                  labelText: "Event Name",
                  icon: Icons.event,
                  keyboardType: TextInputType.text,
                  validator:
                      (value) =>
                          value?.isEmpty ?? true ? 'Enter event name' : null,
                ),
                SizedBox(height: 20.sp),
                CustomTextFormField(
                  controller: _categoryController,
                  labelText: "Category",
                  icon: Icons.category,
                  keyboardType: TextInputType.text,
                  validator:
                      (value) =>
                          value?.isEmpty ?? true ? 'Enter category' : null,
                ),
                SizedBox(height: 20.sp),
                CustomTextFormField(
                  controller: _descriptionController,
                  labelText: "Description",
                  icon: Icons.description,
                  isMultiline: true,
                  keyboardType: TextInputType.multiline,
                  validator:
                      (value) =>
                          value?.isEmpty ?? true ? 'Enter description' : null,
                ),
                SizedBox(height: 20.sp),
                CustomTextFormField(
                  controller: _locationController,
                  labelText: "Location",
                  icon: Icons.location_on,
                  keyboardType: TextInputType.text,
                  validator:
                      (value) =>
                          value?.isEmpty ?? true ? 'Enter location' : null,
                ),
                SizedBox(height: 20.sp),
                CustomTextFormField(
                  controller: _timeController,
                  labelText: "Time",
                  icon: Icons.access_time,
                  keyboardType: TextInputType.text,
                  validator:
                      (value) => value?.isEmpty ?? true ? 'Enter time' : null,
                ),
                SizedBox(height: 20.sp),
                CustomDatePicker(
                  initialDate: _selectedDate,
                  onDatePicked:
                      (newDateTime) =>
                          setState(() => _selectedDate = newDateTime),
                ),
                SizedBox(height: 20.sp),
                _buildImageGrid(),
                CustomElevatedButton(
                  label: '+ Add Image',
                  onPressed: _addImage,
                ),
                SizedBox(height: 20.sp),
                SwitchListTile(
                  title: const Text('Is Online Event?'),
                  value: _isOnlineEvent,
                  onChanged:
                      (value) => setState(() {
                        _isOnlineEvent = value;
                        if (_isOnlineEvent) {
                          _isTicketAvailable = false;
                          _isBusAvailable = false;
                        }
                      }),
                ),
                _buildOnlineEventFields(),
                _buildTicketFields(),
                CustomTextFormField(
                  controller: _contactNumberController,
                  labelText: 'Contact Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'Enter contact number'
                              : null,
                ),
                SizedBox(height: 20.sp),
                CustomTextFormField(
                  controller: _contactEmailController,
                  labelText: 'Contact Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator:
                      (value) =>
                          value?.isEmpty ?? true ? 'Enter contact email' : null,
                ),
                SizedBox(height: 30.sp),
                CustomElevatedButton(
                  label: 'Update Event',
                  onPressed: _updateEvent,
                ),
                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
