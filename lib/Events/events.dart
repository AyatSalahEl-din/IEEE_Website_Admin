import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/Themes/website_colors.dart';
import 'package:intl/intl.dart';
import 'event_widgets/add_event_admin.dart';
import 'event_widgets/build_add_event_widget.dart';
import 'event_widgets/build_delete_event_widget.dart';
import 'event_widgets/build_edit_event_widget.dart';
import 'event_widgets/custom_elevated_button.dart';
import 'package:ieee_website/Events/managereq.dart';
import 'package:ieee_website/Events/proposals.dart';

class Events extends StatefulWidget {
  static const String routeName = 'admin';
  final TabController? tabController;

  Events({super.key, this.tabController});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
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

  String get _selectedMonth => _selectedDate != null ? DateFormat.MMMM().format(_selectedDate!) : '';

  int _selectedIndex = 0;

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
      _nameController.clear();
      _categoryController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _timeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin - Manage Events',
          style: TextStyle(
            color: WebsiteColors.whiteColor,
            fontSize: isSmallScreen ? 18.sp : 20.sp,
          ),
        ),
        backgroundColor: WebsiteColors.primaryBlueColor,
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16.sp : 20.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Button Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomElevatedButton(
                    label: 'Add Event',
                    onPressed: () => setState(() => _selectedIndex = 0),
                    isActive: _selectedIndex == 0,
                  ),
                  SizedBox(width: isSmallScreen ? 8.sp : 10.sp),
                  CustomElevatedButton(
                    label: 'Edit Event',
                    onPressed: () => setState(() => _selectedIndex = 1),
                    isActive: _selectedIndex == 1,
                  ),
                  SizedBox(width: isSmallScreen ? 8.sp : 10.sp),
                  CustomElevatedButton(
                    label: 'Delete Event',
                    onPressed: () => setState(() => _selectedIndex = 2),
                    isActive: _selectedIndex == 2,
                  ),
                  SizedBox(width: isSmallScreen ? 8.sp : 10.sp),
                  CustomElevatedButton(
                    label: 'Manage Requests',
                    onPressed: () => setState(() => _selectedIndex = 3),
                    isActive: _selectedIndex == 3,
                  ),
                  SizedBox(width: isSmallScreen ? 8.sp : 10.sp),
                  CustomElevatedButton(
                    label: 'Proposals',
                    onPressed: () => setState(() => _selectedIndex = 4),
                    isActive: _selectedIndex == 4,
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 16.sp : 20.sp),

            // Main Content Area
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  SingleChildScrollView(
                    child: AddEventForm(
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
                      addEvent: addEvent,
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
                      appNameController: TextEditingController(),
                      appTimeController: TextEditingController(),
                      appUrlController: TextEditingController(),
                      isOnlineEvent: false,
                      selectedApp: null,
                    ),
                  ),
                  const EditEventWidget(),
                  const BuildDeleteEventWidget(),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return const ManageRequestsWidget();
                    },
                  ),
                  const ManageProposalsWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}