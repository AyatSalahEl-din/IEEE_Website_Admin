import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Themes/website_colors.dart';
import 'Date_picker_tile.dart';
import 'custom_text_form_field.dart';

// ignore: must_be_immutable
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
  int? ticketLimit;
  int? numberOfBuses;
  int? seatsPerBus;
  final bool isSeatBookingAvailable;
  final TextEditingController busDepartureTimeController;
  final TextEditingController busArrivalTimeController;
  final TextEditingController appNameController;
  final TextEditingController appTimeController;
  final TextEditingController appUrlController;
  final bool isOnlineEvent;
  final String? selectedApp;

  AddEventForm({
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
    required this.appNameController,
    required this.appTimeController,
    required this.appUrlController,
    required this.isOnlineEvent,
    required this.selectedApp,
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
    selectedDate = widget.selectedDate;
    isTicketAvailable = widget.isTicketAvailable;
    isTicketLimited = widget.isTicketLimited;
    isSeatBookingAvailable = widget.isSeatBookingAvailable;
    isOnlineEvent = widget.isOnlineEvent;
    selectedApp = widget.selectedApp;
    appNameController.text = widget.appNameController.text;
    appUrlController.text = widget.appUrlController.text;
    appTimeController.text = widget.appTimeController.text;
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
            keyboardType: TextInputType.text,
            onChanged: (value) {},
            validator: (value) =>
            value == null || value.isEmpty ? 'Enter event name' : null,
          ),
          SizedBox(height: 30.sp),
          CustomTextFormField(
            controller: widget.categoryController,
            labelText: 'Category',
            icon: Icons.category_outlined,
            keyboardType: TextInputType.text,
            onChanged: (value) {},
            validator: (value) =>
            value == null || value.isEmpty ? 'Enter category' : null,
          ),
          SizedBox(height: 30.sp),
          CustomTextFormField(
            controller: widget.descriptionController,
            labelText: 'Description',
            icon: Icons.description,
            isMultiline: true,
            keyboardType: TextInputType.multiline,
            onChanged: (value) {},
            validator: (value) =>
            value == null || value.isEmpty ? 'Enter description' : null,
          ),
          SizedBox(height: 30.sp),
          CustomTextFormField(
            controller: widget.imageUrlController,
            labelText: 'Image URL',
            icon: Icons.image,
            keyboardType: TextInputType.url,
            onChanged: (value) {},
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
            icon: const Icon(Icons.add, color: WebsiteColors.whiteColor, size: 28),
            label: Text(
              'Add Image URL',
              style: TextStyle(
                color: WebsiteColors.whiteColor,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: WebsiteColors.primaryBlueColor,
              foregroundColor: WebsiteColors.whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.sp),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.sp, horizontal: 20.sp),
              elevation: 6,
              shadowColor: WebsiteColors.primaryBlueColor.withOpacity(0.4),
            ),
          ),
          SizedBox(height: 30.sp),
          if (widget.imageUrls.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Added Images:',
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
                        errorBuilder: (context, error, stackTrace) =>
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
            keyboardType: TextInputType.text,
            onChanged: (value) {},
          ),
          SizedBox(height: 30.sp),
          CustomTextFormField(
            controller: widget.timeController,
            labelText: 'Time (e.g. 3:00 PM)',
            icon: Icons.access_time,
            keyboardType: TextInputType.datetime,
            onChanged: (value) {},
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
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10.sp),
              border: Border.all(
                color: isOnlineEvent
                    ? WebsiteColors.darkBlueColor
                    : Colors.grey[400]!,
                width: 1,
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 12.sp),
            child: SwitchListTile(
              title: Text(
                'Is Online Event?',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w500,
                  color: WebsiteColors.primaryBlueColor,
                ),
              ),
              value: isOnlineEvent,
              activeTrackColor: WebsiteColors.darkBlueColor,
              activeColor: WebsiteColors.whiteColor,
              inactiveTrackColor: Colors.grey[400],
              inactiveThumbColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  isOnlineEvent = value;
                  if (isOnlineEvent) {
                    isTicketAvailable = false;
                    isBusAvailable = false;
                  }
                });
              },
              contentPadding: EdgeInsets.zero,
              dense: true,
              visualDensity: VisualDensity.compact,
              controlAffinity: ListTileControlAffinity.trailing,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          if (isOnlineEvent) ...[
            SizedBox(height: 30.sp),
            CustomTextFormField(
              controller: appTimeController,
              labelText: 'Exact Time (e.g., 3:00 PM)',
              icon: Icons.access_time,
              keyboardType: TextInputType.datetime,
              onChanged: (value) {},
              validator: (value) =>
              value == null || value.isEmpty ? 'Enter the exact time' : null,
            ),
            SizedBox(height: 30.sp),
            CustomTextFormField(
              controller: appUrlController,
              labelText: 'Pre-URL (Optional)',
              icon: Icons.link,
              keyboardType: TextInputType.url,
              onChanged: (value) {},
            ),
            SizedBox(height: 30.sp),
            DropdownButtonFormField<String>(
              value: selectedApp,
              items: ['Zoom', 'Microsoft Teams', 'Google Meet', 'Other']
                  .map((app) {
                return DropdownMenuItem(value: app, child: Text(app));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedApp = value;
                  if (value != 'Other') {
                    appNameController.clear();
                  }
                });
              },
              decoration: InputDecoration(
                labelText: 'Select App Hosting',
                labelStyle: TextStyle(fontSize: 25.sp,color: WebsiteColors.darkBlueColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) =>
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
                keyboardType: TextInputType.text,
                onChanged: (value) {},
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter app name' : null,
              ),
            ],
          ],
          if (!isOnlineEvent) ...[
            if (selectedDate != null && selectedDate!.isAfter(DateTime.now())) ...[
              SwitchListTile(
                title: const Text('Are Tickets Available?'),
                value: isTicketAvailable,
                onChanged: (value) {
                  setState(() {
                    isTicketAvailable = value;
                    if (!isTicketAvailable) {
                      isBusAvailable = false;
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
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      widget.ticketLimit = int.tryParse(value) ?? 0;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter ticket limit';
                      }
                      return null;
                    },
                  ),
                SizedBox(height: 30.sp),
                CustomTextFormField(
                  controller: widget.ticketPriceController,
                  labelText: 'Ticket Price',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {},
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter ticket price' : null,
                ),
                SizedBox(height: 30.sp),
                CustomTextFormField(
                  controller: widget.discountController,
                  labelText: 'Discount (%)',
                  icon: Icons.discount,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {},
                  validator: (value) =>
                  value == null || value.isEmpty
                      ? 'Enter discount percentage'
                      : null,
                ),
                SizedBox(height: 30.sp),
                CustomTextFormField(
                  controller: widget.discountForController,
                  labelText: 'Discount For (e.g., Students)',
                  icon: Icons.group,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {},
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
                    controller: TextEditingController(
                      text: widget.numberOfBuses?.toString() ?? '',
                    ),
                    labelText: 'Number of Buses',
                    icon: Icons.directions_bus,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      widget.numberOfBuses = int.tryParse(value) ?? 0;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter number of buses';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30.sp),
                  CustomTextFormField(
                    controller: TextEditingController(
                      text: widget.seatsPerBus?.toString() ?? '',
                    ),
                    labelText: 'Seats Per Bus',
                    icon: Icons.event_seat,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      widget.seatsPerBus = int.tryParse(value) ?? 0;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter seats per bus';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30.sp),
                  CustomTextFormField(
                    controller: widget.busTicketPriceController,
                    labelText: 'Bus Ticket Price Per Seat',
                    icon: Icons.directions_bus,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {},
                    validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Enter bus ticket price'
                        : null,
                  ),
                  SizedBox(height: 30.sp),
                  CustomTextFormField(
                    controller: widget.busSourceController,
                    labelText: 'Bus Departure Location',
                    icon: Icons.location_on,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {},
                    validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Enter departure location'
                        : null,
                  ),
                  SizedBox(height: 30.sp),
                  CustomTextFormField(
                    controller: widget.busDestinationController,
                    labelText: 'Bus Destination',
                    icon: Icons.location_on,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {},
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Enter destination' : null,
                  ),
                  SizedBox(height: 30.sp),
                  CustomTextFormField(
                    controller: widget.busDepartureTimeController,
                    labelText: 'Bus Departure Time',
                    icon: Icons.access_time,
                    keyboardType: TextInputType.datetime,
                    onChanged: (value) {},
                    validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Enter departure time'
                        : null,
                  ),
                  SizedBox(height: 30.sp),
                  CustomTextFormField(
                    controller: widget.busArrivalTimeController,
                    labelText: 'Bus Arrival Time',
                    icon: Icons.access_time,
                    keyboardType: TextInputType.datetime,
                    onChanged: (value) {},
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Enter arrival time' : null,
                  ),
                  SizedBox(height: 30.sp),
                  CustomTextFormField(
                    controller: widget.tripExplanationController,
                    labelText: 'Program Details',
                    icon: Icons.info,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {},
                    validator: (value) =>
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
            keyboardType: TextInputType.phone,
            onChanged: (value) {},
            validator: (value) =>
            value == null || value.isEmpty ? 'Enter contact number' : null,
          ),
          SizedBox(height: 30.sp),
          CustomTextFormField(
            controller: widget.contactEmailController,
            labelText: 'Contact Email',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {},
            validator: (value) =>
            value == null || value.isEmpty ? 'Enter contact email' : null,
          ),
          SizedBox(height: 40.sp),
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: 220.sp),
            child: ElevatedButton(
              onPressed: () async {
                if (!widget.formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please fill all required fields.',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                      backgroundColor: Colors.redAccent,
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
              child: widget.isLoading
                  ? const CircularProgressIndicator(
                color: WebsiteColors.whiteColor,
              )
                  : Text(
                'Add Event',
                style: TextStyle(
                  color: WebsiteColors.whiteColor,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: WebsiteColors.primaryBlueColor,
                foregroundColor: WebsiteColors.whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.sp),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 16.sp,
                  horizontal: 24.sp,
                ),
                elevation: 6,
                shadowColor: WebsiteColors.primaryBlueColor.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}