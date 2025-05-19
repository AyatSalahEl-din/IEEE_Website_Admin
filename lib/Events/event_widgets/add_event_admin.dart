import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void addEvent({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required TextEditingController nameController,
  required TextEditingController categoryController,
  required TextEditingController descriptionController,
  required TextEditingController locationController,
  required TextEditingController timeController,
  required List<String> imageUrls,
  required DateTime? selectedDate,
  required String? selectedMonth,
  required bool isLoading,
  required Function(bool) setLoading,
  required Function() resetForm,
  required TextEditingController ticketPriceController,
  required TextEditingController discountController,
  required TextEditingController discountForController,
  required TextEditingController busTicketPriceController,
  required TextEditingController busSeatsController,
  required TextEditingController busSourceController,
  required TextEditingController busDestinationController,
  required TextEditingController tripExplanationController,
  required TextEditingController contactNumberController,
  required TextEditingController contactEmailController,
  required bool isBusAvailable,
  required bool isTicketAvailable,
  required bool isTicketLimited,
  required int? ticketLimit,
  required int? numberOfBuses,
  required int? seatsPerBus,
  required bool isSeatBookingAvailable,
  required TextEditingController busDepartureTimeController,
  required TextEditingController busArrivalTimeController,
  required bool isOnlineEvent,
  required TextEditingController appTimeController,
  required TextEditingController appUrlController,
  required TextEditingController appNameController,
  required String? selectedApp,
}) async {
  if (!formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all required fields.')),
    );
    return;
  }

  setLoading(true);

  try {
    final eventData = {
      'name': nameController.text.trim(),
      'category': categoryController.text.trim().toUpperCase(),
      'details': descriptionController.text.trim(),
      'location': locationController.text.trim(),
      'time': timeController.text.trim(),
      'imageUrls': imageUrls,
      'date': selectedDate != null ? Timestamp.fromDate(selectedDate) : null,
      'month': selectedMonth,
      'isOnlineEvent': isOnlineEvent,
      if (isOnlineEvent) ...{
        'appTime': appTimeController.text.trim(),
        'appUrl': appUrlController.text.trim(),
        'appName':
            selectedApp == 'Other'
                ? appNameController.text.trim()
                : selectedApp,
      },
      if (!isOnlineEvent) ...{
        'ticketPrice':
            double.tryParse(ticketPriceController.text.trim()) ?? 0.0,
        'discount':
            double.tryParse(discountController.text.trim()) ??
            0.0, // Ensure discount is in percentage
        'discountFor': discountForController.text.trim(),
        'isTicketAvailable': isTicketAvailable,
        'isTicketLimited': isTicketLimited,
        if (isTicketLimited && ticketLimit != null) 'ticketLimit': ticketLimit,
        if (isBusAvailable) ...{
          'busDetails': {
            if (numberOfBuses != null) 'numberOfBuses': numberOfBuses,
            if (seatsPerBus != null) 'seatsPerBus': seatsPerBus,
            'isSeatBookingAvailable': isSeatBookingAvailable,
            'ticketPrice':
                double.tryParse(busTicketPriceController.text.trim()) ?? 0.0,
            'seats': int.tryParse(busSeatsController.text.trim()) ?? 0,
            'source': busSourceController.text.trim(),
            'destination': busDestinationController.text.trim(),
            'tripExplanation': tripExplanationController.text.trim(),
            'departureTime': busDepartureTimeController.text.trim(),
            'arrivalTime': busArrivalTimeController.text.trim(),
          },
        },
      },
      'contact': {
        'number': contactNumberController.text.trim(),
        'email': contactEmailController.text.trim(),
      },
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('events').add(eventData);

    resetForm();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Event added successfully!')));
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error adding event: $e')));
  } finally {
    setLoading(false);
  }
}
