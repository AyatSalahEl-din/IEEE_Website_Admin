import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Event {
  final String id;
  final String name;
  final String location;
  final String time;
  final List<String> imageUrls;
  final String month;
  final DateTime date;
  final String category;
  final String details;

  // Optional fields from the first model
  //final String? description;
  //final String? coverImageUrl;
  //final String? additionalDetails;
  final double? baseTicketPrice;
  final bool? discountOption;
  final double? discountAmount;
  final DateTime? discountValidUntil;
  final bool? hasBusService;
  final BusDetails? busDetails;
  final List<String>? galleryImages;
  final bool? isPastEvent;
  final bool? isTicketAvailable;
  final bool? isTicketLimited;
  final int? ticketLimit;
  final int? numberOfBuses;
  final int? seatsPerBus;
  final bool? isSeatBookingAvailable;

  Event({
    required this.name,
    required this.location,
    required this.time,
    required this.imageUrls,
    required this.month,
    required this.date,
    required this.category,
    required this.details,
    this.id = '',
    //this.description,
    //this.coverImageUrl,
    //this.additionalDetails,
    this.baseTicketPrice,
    this.discountOption,
    this.discountAmount,
    this.discountValidUntil,
    this.hasBusService,
    this.busDetails,
    this.galleryImages,
    this.isPastEvent,
    this.isTicketAvailable,
    this.isTicketLimited,
    this.ticketLimit,
    this.numberOfBuses,
    this.seatsPerBus,
    this.isSeatBookingAvailable,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Event(
      id: doc.id,
      name: data['name'] ?? 'No name',
      location: data['location'] ?? 'No location',
      time: data['time'] ?? 'No time',
      imageUrls:
          (data['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      month: data['month'] ?? 'No month',
      date: (data['date'] as Timestamp).toDate(),
      category: data['category'] ?? 'No category',
      details: data['details'] ?? 'No details',
      //description: data['description'],
      //coverImageUrl: data['coverImageUrl'],
      //additionalDetails: data['additionalDetails'],
      baseTicketPrice: data['baseTicketPrice']?.toDouble(),
      discountOption: data['discountOption'],
      discountAmount: data['discountAmount']?.toDouble(),
      discountValidUntil: data['discountValidUntil']?.toDate(),
      hasBusService: data['hasBusService'],
      busDetails:
          data['busDetails'] != null
              ? BusDetails.fromMap(data['busDetails'])
              : null,
      galleryImages:
          data['galleryImages'] != null
              ? List<String>.from(data['galleryImages'])
              : null,
      isPastEvent: data['isPastEvent'],
      isTicketAvailable: data['isTicketAvailable'],
      isTicketLimited: data['isTicketLimited'],
      ticketLimit: data['ticketLimit'],
      numberOfBuses: data['busDetails']?['numberOfBuses'],
      seatsPerBus: data['busDetails']?['seatsPerBus'],
      isSeatBookingAvailable: data['busDetails']?['isSeatBookingAvailable'],
    );
  }

  String formatDate() {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
}

class BusDetails {
  final String departureLocation;
  final String arrivalLocation;
  final String tripProgram;
  final double busTicketPrice;
  final int totalSeats;
  final bool enableSeatSelection;
  final String? departureTime;
  final String? arrivalTime;

  BusDetails({
    required this.departureLocation,
    required this.arrivalLocation,
    required this.tripProgram,
    required this.busTicketPrice,
    required this.totalSeats,
    required this.enableSeatSelection,
    this.departureTime,
    this.arrivalTime,
  });

  factory BusDetails.fromMap(Map data) {
    return BusDetails(
      departureLocation: data['departureLocation'] ?? '',
      arrivalLocation: data['arrivalLocation'] ?? '',
      tripProgram: data['tripProgram'] ?? '',
      busTicketPrice: (data['busTicketPrice'] ?? 0).toDouble(),
      totalSeats: (data['totalSeats'] ?? 0).toInt(),
      enableSeatSelection: data['enableSeatSelection'] ?? false,
      departureTime: data['departureTime'],
      arrivalTime: data['arrivalTime'],
    );
  }
}

class TicketRequest {
  final String id;
  final String userName;
  final String userPhone;
  final String? userEmail;
  final String eventName;
  final Timestamp requestDate;
  final String status;
  final String? additionalUserInfo;
  final String? ticketType;
  final int? ticketQuantity;
  final bool? busService;
  final Map<String, dynamic>? busDetails;
  final String? rejectReason;
  final String? notes;
  final Timestamp? eventDate;

  TicketRequest({
    required this.id,
    required this.userName,
    required this.userPhone,
    this.userEmail,
    required this.eventName,
    required this.requestDate,
    required this.status,
    this.additionalUserInfo,
    this.ticketType,
    this.ticketQuantity,
    this.busService,
    this.busDetails,
    this.rejectReason,
    this.notes,
    this.eventDate,
  });

  factory TicketRequest.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return TicketRequest(
      id: doc.id,
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      userEmail: data['userEmail'],
      eventName: data['eventName'] ?? '',
      requestDate: data['requestDate'] ?? Timestamp.now(),
      status: data['status'] ?? 'pending',
      additionalUserInfo: data['additionalUserInfo'],
      ticketType: data['ticketType'],
      ticketQuantity: data['ticketQuantity'],
      busService: data['busService'],
      busDetails:
          data['busDetails'] != null
              ? Map<String, dynamic>.from(data['busDetails'])
              : null,
      rejectReason: data['rejectReason'],
      notes: data['notes'],
      eventDate: data['eventDate'],
    );
  }
}

class Proposal {
  final String id;
  final String name;
  final String requester;
  final String contact;
  final String description;
  final String location;
  final String category;
  final Timestamp proposedDate;
  final String coverImageUrl;
  final String additionalDetails;
  final double baseTicketPrice;
  final Timestamp submittedAt;

  Proposal({
    required this.id,
    required this.name,
    required this.requester,
    required this.contact,
    required this.description,
    required this.location,
    required this.category,
    required this.proposedDate,
    required this.coverImageUrl,
    required this.additionalDetails,
    required this.baseTicketPrice,
    required this.submittedAt,
  });

  factory Proposal.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Proposal(
      id: doc.id,
      name: data['name'] ?? '',
      requester: data['requester'] ?? '',
      contact: data['contact'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      category: data['category'] ?? 'Workshop',
      proposedDate: data['proposedDate'] ?? Timestamp.now(),
      coverImageUrl: data['coverImageUrl'] ?? '',
      additionalDetails: data['additionalDetails'] ?? '',
      baseTicketPrice: (data['baseTicketPrice'] ?? 0).toDouble(),
      submittedAt: data['submittedAt'] ?? Timestamp.now(),
    );
  }
}

Future<List<Event>> fetchEventsFromFirestore() async {
  try {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('events').get();

    if (snapshot.docs.isEmpty) {
      print("No events found in Firestore.");
    }

    List<Event> events =
        snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          print("Fetched Event: $data"); // Debugging
          return Event.fromFirestore(doc);
        }).toList();

    print("Total Events: ${events.length}");
    return events;
  } catch (e) {
    print("Error fetching events: $e");
    return [];
  }
}
