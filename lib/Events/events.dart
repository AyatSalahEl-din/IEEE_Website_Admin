import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/Themes/website_colors.dart';
import 'package:intl/intl.dart';
import 'event_widgets/add_event_admin.dart'; // Ensure this imports the addEvent function
import 'event_widgets/build_add_event_widget.dart';
import 'event_widgets/build_delete_event_widget.dart';
import 'event_widgets/build_edit_event_widget.dart';
import 'event_widgets/custom_elevated_button.dart';
import 'package:ieee_website/Events/managereq.dart';
import 'package:ieee_website/Events/proposals.dart'; // Import the proposals widget
//import 'package:cloud_firestore/cloud_firestore.dart'as firestore; // Alias added

class AdminEventPage extends StatefulWidget {
  static const String routeName = 'admin';
  final TabController? tabController; // ✅ Make TabController optional

  AdminEventPage({super.key, this.tabController});

  @override
  State<AdminEventPage> createState() => _AdminEventPageState();
}

class _AdminEventPageState extends State<AdminEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _timeController = TextEditingController();
  final _imageUrlController = TextEditingController();

  DateTime? _selectedDate;
  List<String> _imageUrls = [];
  bool _isLoading = false;
  //String? _editingEventId;

  String get _selectedMonth =>
      _selectedDate != null ? DateFormat.MMMM().format(_selectedDate!) : '';

  int _selectedIndex = 0; // To keep track of the selected tab

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2014),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _setLoading(bool loading) {
    setState(() => _isLoading = loading);
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _imageUrls.clear();
      _selectedDate = null;
      _isLoading = false;
      //_editingEventId = null;
      _nameController.clear();
      _categoryController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _timeController.clear();
    });
  }

  /*Future<void> _loadEventData(String eventId) async {
    final doc =
        await firestore.FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _editingEventId = eventId;
        _nameController.text = data['name'] ?? '';
        _categoryController.text = data['category'] ?? '';
        _descriptionController.text = data['details'] ?? '';
        _locationController.text = data['location'] ?? '';
        _timeController.text = data['time'] ?? '';
        _imageUrls = List<String>.from(data['imageUrls'] ?? []);
        _selectedDate =
            data['date'] != null
                ? (data['date'] as firestore.Timestamp).toDate()
                : null;
      });
    }
  }*/

  /*Future<void> _deleteEvent(String eventId) async {
    await firestore.FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .delete();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin - Manage Events',
          style: TextStyle(color: WebsiteColors.whiteColor),
        ),
        backgroundColor: WebsiteColors.primaryBlueColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tab buttons to switch between Add, Edit, Delete, Manage Requests, and Proposals
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomElevatedButton(
                    label: 'Add Event',
                    onPressed: () => setState(() => _selectedIndex = 0),
                  ),
                  SizedBox(width: 10.sp),
                  CustomElevatedButton(
                    label: 'Edit Event',
                    onPressed: () => setState(() => _selectedIndex = 1),
                  ),
                  SizedBox(width: 10.sp),
                  CustomElevatedButton(
                    label: 'Delete Event',
                    onPressed: () => setState(() => _selectedIndex = 2),
                  ),
                  SizedBox(width: 10.sp),
                  CustomElevatedButton(
                    label: 'Manage Requests',
                    onPressed: () => setState(() => _selectedIndex = 3),
                  ),
                  SizedBox(width: 10.sp),
                  CustomElevatedButton(
                    label: 'Proposals',
                    onPressed: () => setState(() => _selectedIndex = 4),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Show content based on the selected tab
              if (_selectedIndex == 0)
                AddEventForm(
                  formKey: _formKey,
                  nameController: _nameController,
                  categoryController: _categoryController,
                  descriptionController: _descriptionController,
                  locationController: _locationController,
                  timeController: _timeController,
                  imageUrlController: _imageUrlController,
                  imageUrls: _imageUrls,
                  selectedDate: _selectedDate,
                  selectedMonth: _selectedMonth,
                  isLoading: _isLoading,
                  setLoading: _setLoading,
                  resetForm: _resetForm,
                  pickDate: _pickDate,
                  addEvent: addEvent, // Ensure addEvent is correctly imported
                  ticketPriceController: TextEditingController(),
                  discountController: TextEditingController(),
                  discountForController: TextEditingController(),
                  busTicketPriceController: TextEditingController(),
                  busSeatsController: TextEditingController(),
                  busSourceController: TextEditingController(),
                  busDestinationController: TextEditingController(),
                  tripExplanationController: TextEditingController(),
                  contactNumberController: TextEditingController(),
                  contactEmailController: TextEditingController(),
                  isTicketAvailable: false,
                  isTicketLimited: false,
                  ticketLimit: null,
                  numberOfBuses: null,
                  seatsPerBus: null,
                  isSeatBookingAvailable: false,
                  busDepartureTimeController: TextEditingController(),
                  busArrivalTimeController: TextEditingController(),
                ),
              if (_selectedIndex == 1) EditEventWidget(),
              if (_selectedIndex == 2) BuildDeleteEventWidget(),
              if (_selectedIndex == 3)
                const BuildManageReq(), // Ensure this widget is properly initialized
              if (_selectedIndex == 4)
                const ProposalsWidget(), // Ensure this widget is properly initialized
            ],
          ),
        ),
      ),
    );
  }
}
