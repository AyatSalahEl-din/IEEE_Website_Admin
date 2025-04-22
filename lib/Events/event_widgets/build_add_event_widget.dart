// add_event_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Themes/website_colors.dart';
import 'Date_picker_tile.dart';
import 'custom_text_form_field.dart';

class AddEventForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController categoryController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final TextEditingController timeController;
  final TextEditingController imageUrlController;
  final List<String> imageUrls;
  final DateTime? selectedDate;
  final String? selectedMonth;
  final bool isLoading;
  final Function setLoading;
  final Function resetForm;
  final Function pickDate;
  final Function addEvent;
  final TextEditingController ticketPriceController;
  final TextEditingController discountController;
  final TextEditingController discountForController;
  final TextEditingController busTicketPriceController;
  final TextEditingController busSeatsController;
  final TextEditingController busSourceController;
  final TextEditingController busDestinationController;
  final TextEditingController tripExplanationController;
  final TextEditingController contactNumberController;
  final TextEditingController contactEmailController;
  final bool isTicketAvailable;
  final bool isTicketLimited;
  final int? ticketLimit;
  final int? numberOfBuses;
  final int? seatsPerBus;
  final bool isSeatBookingAvailable;
  final TextEditingController busDepartureTimeController;
  final TextEditingController busArrivalTimeController;
  final TextEditingController appNameController; // Added
  final TextEditingController appTimeController; // Added
  final TextEditingController appUrlController; // Added
  final bool isOnlineEvent; // Added
  final String? selectedApp; // Added

  const AddEventForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.categoryController,
    required this.descriptionController,
    required this.locationController,
    required this.timeController,
    required this.imageUrlController,
    required this.imageUrls,
    required this.selectedDate,
    required this.selectedMonth,
    required this.isLoading,
    required this.setLoading,
    required this.resetForm,
    required this.pickDate,
    required this.addEvent,
    required this.ticketPriceController,
    required this.discountController,
    required this.discountForController,
    required this.busTicketPriceController,
    required this.busSeatsController,
    required this.busSourceController,
    required this.busDestinationController,
    required this.tripExplanationController,
    required this.contactNumberController,
    required this.contactEmailController,
    required this.isTicketAvailable,
    required this.isTicketLimited,
    required this.ticketLimit,
    required this.numberOfBuses,
    required this.seatsPerBus,
    required this.isSeatBookingAvailable,
    required this.busDepartureTimeController,
    required this.busArrivalTimeController,
    required this.appNameController, // Added
    required this.appTimeController, // Added
    required this.appUrlController, // Added
    required this.isOnlineEvent, // Added
    required this.selectedApp, // Added
  });

  @override
  State<AddEventForm> createState() => _AddEventFormState();
}

class _AddEventFormState extends State<AddEventForm> {
  DateTime? selectedDate;
  bool isBusAvailable = false;
  bool isTicketAvailable = false;
  bool isTicketLimited = false;
  bool isSeatBookingAvailable = false;
  bool isOnlineEvent = false;
  String? selectedApp;
  TextEditingController appNameController = TextEditingController();
  TextEditingController appUrlController = TextEditingController();
  TextEditingController appTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate; // Initial value from parent
    isTicketAvailable = widget.isTicketAvailable;
    isTicketLimited = widget.isTicketLimited;
    isSeatBookingAvailable = widget.isSeatBookingAvailable;
  }

  @override
  void dispose() {
    appNameController.dispose();
    appUrlController.dispose();
    appTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextFormField(
            controller: widget.nameController,
            labelText: 'Event Name',
            icon: Icons.event,
            validator:
                (value) =>
                    value == null || value.isEmpty ? 'Enter event name' : null,
          ),
          SizedBox(height: 30.sp),
          CustomTextFormField(
            controller: widget.categoryController,
            labelText: 'Category',
            icon: Icons.category_outlined,
            validator:
                (value) =>
                    value == null || value.isEmpty ? 'Enter category' : null,
          ),
          SizedBox(height: 30.sp),
          CustomTextFormField(
            controller: widget.descriptionController,
            labelText: 'Description',
            icon: Icons.description,
            isMultiline: true,
            validator:
                (value) =>
                    value == null || value.isEmpty ? 'Enter description' : null,
          ),
          SizedBox(height: 30.sp),
          CustomTextFormField(
            controller: widget.imageUrlController,
            labelText: 'Image URL',
            icon: Icons.image,
          ),
          SizedBox(height: 60.sp),
          ElevatedButton.icon(
            onPressed: () {
              final url = widget.imageUrlController.text.trim();
              if (url.isNotEmpty) {
                setState(() {
                  widget.imageUrls.add(url);
                  widget.imageUrlController.clear();
                });
              }
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Image URL',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: WebsiteColors.primaryBlueColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.sp),
            ),
          ),
          SizedBox(height: 30.sp),
          if (widget.imageUrls.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Added Images: ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 25.sp,
                    color: WebsiteColors.primaryBlueColor,
                  ),
                ),
                SizedBox(height: 10.sp),
                ...widget.imageUrls.map(
                  (url) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Image.network(
                        url,
                        width: 80.sp,
                        height: 100.sp,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                      ),
                      title: Text(url),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          setState(() => widget.imageUrls.remove(url));
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: 30.sp),
          CustomTextFormField(
            controller: widget.locationController,
            labelText: 'Location',
            icon: Icons.location_on,
          ),
          SizedBox(height: 30.sp),
          CustomTextFormField(
            controller: widget.timeController,
            labelText: 'Time (e.g. 3:00 PM)',
            icon: Icons.access_time,
          ),
          SizedBox(height: 30.sp),
          CustomDatePicker(
            initialDate: selectedDate,
            onDatePicked: (newDateTime) {
              setState(() {
                selectedDate = newDateTime;
              });
            },
          ),
          SizedBox(height: 30.sp),
          SwitchListTile(
            title: const Text('Is Online Event?'),
            value: isOnlineEvent,
            onChanged: (value) {
              setState(() {
                isOnlineEvent = value;
                if (isOnlineEvent) {
                  isTicketAvailable = false; // Disable tickets if online
                  isBusAvailable = false; // Disable buses if online
                }
              });
            },
          ),
          if (isOnlineEvent) ...[
            SizedBox(height: 30.sp),
            CustomTextFormField(
              controller: appTimeController,
              labelText: 'Exact Time (e.g., 3:00 PM)',
              icon: Icons.access_time,
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Enter the exact time'
                          : null,
            ),
            SizedBox(height: 30.sp),
            CustomTextFormField(
              controller: appUrlController,
              labelText: 'Pre-URL (Optional)',
              icon: Icons.link,
            ),
            SizedBox(height: 30.sp),
            DropdownButtonFormField<String>(
              value: selectedApp,
              items:
                  ['Zoom', 'Microsoft Teams', 'Google Meet', 'Other'].map((
                    app,
                  ) {
                    return DropdownMenuItem(value: app, child: Text(app));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedApp = value;
                  if (value != 'Other') {
                    appNameController
                        .clear(); // Clear custom app name if not "Other"
                  }
                });
              },
              decoration: InputDecoration(
                labelText: 'Select App Hosting',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Select an app hosting option'
                          : null,
            ),
            if (selectedApp == 'Other') ...[
              SizedBox(height: 30.sp),
              CustomTextFormField(
                controller: appNameController,
                labelText: 'App Name',
                icon: Icons.apps,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter app name'
                            : null,
              ),
            ],
          ],
          if (!isOnlineEvent) ...[
            if (selectedDate != null &&
                selectedDate!.isAfter(DateTime.now())) ...[
              SwitchListTile(
                title: const Text('Are Tickets Available?'),
                value: isTicketAvailable,
                onChanged: (value) {
                  setState(() {
                    isTicketAvailable = value;
                    if (!isTicketAvailable) {
                      isBusAvailable =
                          false; // Reset bus availability if tickets are unavailable
                    }
                  });
                },
              ),
              if (isTicketAvailable) ...[
                SizedBox(height: 30.sp),
                SwitchListTile(
                  title: const Text('Are Tickets Limited?'),
                  value: isTicketLimited,
                  onChanged: (value) {
                    setState(() {
                      isTicketLimited = value;
                    });
                  },
                ),
                if (isTicketLimited)
                  CustomTextFormField(
                    controller: TextEditingController(
                      text: widget.ticketLimit?.toString() ?? '',
                    ),
                    labelText: 'Ticket Limit',
                    icon: Icons.confirmation_number,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Enter ticket limit'
                                : null,
                  ),
                SizedBox(height: 30.sp),
                CustomTextFormField(
                  controller: widget.ticketPriceController,
                  labelText: 'Ticket Price',
                  icon: Icons.attach_money,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Enter ticket price'
                              : null,
                ),
                SizedBox(height: 30.sp),
                CustomTextFormField(
                  controller: widget.discountController,
                  labelText: 'Discount',
                  icon: Icons.discount,
                ),
                SizedBox(height: 30.sp),
                CustomTextFormField(
                  controller: widget.discountForController,
                  labelText: 'Discount For (e.g., Students)',
                  icon: Icons.group,
                ),
                SizedBox(height: 30.sp),
                SwitchListTile(
                  title: const Text('Is Bus Available?'),
                  value: isBusAvailable,
                  onChanged: (value) {
                    setState(() {
                      isBusAvailable = value;
                    });
                  },
                ),
                if (isBusAvailable) ...[
                  SizedBox(height: 30.sp),
                  CustomTextFormField(
                    controller: TextEditingController(),
                    labelText: 'Number of Buses',
                    icon: Icons.directions_bus,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Enter number of buses'
                                : null,
                  ),
                  SizedBox(height: 30.sp),
                  CustomTextFormField(
                    controller: TextEditingController(),
                    labelText: 'Seats Per Bus',
                    icon: Icons.event_seat,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Enter seats per bus'
                                : null,
                  ),
                  SizedBox(height: 30.sp),
                  CustomTextFormField(
                    controller: widget.busTicketPriceController,
                    labelText: 'Bus Ticket Price Per Seat',
                    icon: Icons.directions_bus,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Enter bus ticket price'
                                : null,
                  ),
                  SizedBox(height: 30.sp),
                  CustomTextFormField(
                    controller: widget.busSourceController,
                    labelText: 'Bus Departure Location',
                    icon: Icons.location_on,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Enter departure location'
                                : null,
                  ),
                  SizedBox(height: 30.sp),
                  CustomTextFormField(
                    controller: widget.busDestinationController,
                    labelText: 'Bus Destination',
                    icon: Icons.location_on,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Enter destination'
                                : null,
                  ),
                  SizedBox(height: 30.sp),
                  CustomTextFormField(
                    controller: widget.busDepartureTimeController,
                    labelText: 'Bus Departure Time',
                    icon: Icons.access_time,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Enter departure time'
                                : null,
                  ),
                  SizedBox(height: 30.sp),
                  CustomTextFormField(
                    controller: widget.busArrivalTimeController,
                    labelText: 'Bus Arrival Time',
                    icon: Icons.access_time,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Enter arrival time'
                                : null,
                  ),
                  SizedBox(height: 30.sp),
                  CustomTextFormField(
                    controller: widget.tripExplanationController,
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
          ],
          SizedBox(height: 30.sp),
          CustomTextFormField(
            controller: widget.contactNumberController,
            labelText: 'Contact Number',
            icon: Icons.phone,
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? 'Enter contact number'
                        : null,
          ),
          SizedBox(height: 30.sp),
          CustomTextFormField(
            controller: widget.contactEmailController,
            labelText: 'Contact Email',
            icon: Icons.email,
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? 'Enter contact email'
                        : null,
          ),
          SizedBox(height: 40.sp),
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: 200.sp),
            child: ElevatedButton(
              onPressed: () async {
                if (!widget.formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields.'),
                    ),
                  );
                  return;
                }

                print("Add Event button pressed");
                print(
                  "Form Data: ${widget.nameController.text}, ${widget.categoryController.text}",
                );

                await widget.addEvent(
                  context: context,
                  formKey: widget.formKey,
                  nameController: widget.nameController,
                  categoryController: widget.categoryController,
                  descriptionController: widget.descriptionController,
                  locationController: widget.locationController,
                  timeController: widget.timeController,
                  imageUrls: widget.imageUrls,
                  selectedDate: selectedDate,
                  selectedMonth: widget.selectedMonth,
                  isLoading: widget.isLoading,
                  setLoading: widget.setLoading,
                  resetForm: widget.resetForm,
                  ticketPriceController: widget.ticketPriceController,
                  discountController: widget.discountController,
                  discountForController: widget.discountForController,
                  busTicketPriceController: widget.busTicketPriceController,
                  busSeatsController: widget.busSeatsController,
                  busSourceController: widget.busSourceController,
                  busDestinationController: widget.busDestinationController,
                  tripExplanationController: widget.tripExplanationController,
                  contactNumberController: widget.contactNumberController,
                  contactEmailController: widget.contactEmailController,
                  isBusAvailable: isBusAvailable,
                  isTicketAvailable: isTicketAvailable,
                  isTicketLimited: isTicketLimited,
                  ticketLimit: widget.ticketLimit,
                  numberOfBuses: widget.numberOfBuses,
                  seatsPerBus: widget.seatsPerBus,
                  isSeatBookingAvailable: isSeatBookingAvailable,
                  busDepartureTimeController: widget.busDepartureTimeController,
                  busArrivalTimeController: widget.busArrivalTimeController,
                  isOnlineEvent: isOnlineEvent,
                  appTimeController: appTimeController,
                  appUrlController: appUrlController,
                  appNameController: appNameController,
                  selectedApp: selectedApp,
                );
              },
              child:
                  widget.isLoading
                      ? const CircularProgressIndicator(
                        color: WebsiteColors.primaryBlueColor,
                      )
                      : Text(
                        'Add Event',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: WebsiteColors.whiteColor,
                          fontSize: 22.sp,
                        ),
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: WebsiteColors.primaryBlueColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.sp),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 12.sp,
                  horizontal: 12.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
