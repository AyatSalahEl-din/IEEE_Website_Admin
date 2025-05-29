import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/Themes/website_colors.dart';
import 'package:intl/intl.dart';
import 'edit_event_admin.dart';
import 'events_card.dart';

class EditEventWidget extends StatefulWidget {
  const EditEventWidget({super.key});

  @override
  State<EditEventWidget> createState() => _EditEventWidgetState();
}

class _EditEventWidgetState extends State<EditEventWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(

        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.sp), // Use .sp for responsiveness
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search events...',
                          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: WebsiteColors.greyColor,
                            fontSize: 16.sp,
                          ),
                          prefixIcon: Icon(Icons.search, size: 20.sp),
                          fillColor: Colors.grey[100],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.sp),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(fontSize: 16.sp),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.sp),

                // StreamBuilder Grid
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('events').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final filteredEvents = snapshot.data!.docs.where((event) {
                      final data = event.data() as Map<String, dynamic>;
                      final name = (data['name'] ?? '').toString().toLowerCase();
                      final dateRaw = data['date'];
                      String formattedDate = '';

                      if (dateRaw is Timestamp) {
                        formattedDate = DateFormat.yMMMd().format(dateRaw.toDate()).toLowerCase();
                      } else if (dateRaw is DateTime) {
                        formattedDate = DateFormat.yMMMd().format(dateRaw).toLowerCase();
                      }

                      return name.contains(_searchQuery) || formattedDate.contains(_searchQuery);
                    }).toList();

                    if (filteredEvents.isEmpty) {
                      return Center(
                        child: Text(
                          "No events found.",
                          style: TextStyle(fontSize: 18.sp, color: WebsiteColors.greyColor),
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true, // Allow GridView to take only needed space
                      physics: const NeverScrollableScrollPhysics(), // Disable GridView scrolling
                      itemCount: filteredEvents.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16.sp,
                        mainAxisSpacing: 16.sp,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (context, index) {
                        final event = filteredEvents[index];
                        final data = event.data() as Map<String, dynamic>;

                        final eventName = data['name'] ?? 'No Name';
                        final eventDate = () {
                          final date = data['date'];
                          if (date is Timestamp) {
                            return DateFormat.yMMMd().format(date.toDate());
                          } else if (date is DateTime) {
                            return DateFormat.yMMMd().format(date);
                          }
                          return 'No Date';
                        }();

                        bool isHovered = false;

                        return StatefulBuilder(
                          builder: (context, setLocalState) {
                            return MouseRegion(
                              onEnter: (_) => setLocalState(() => isHovered = true),
                              onExit: (_) => setLocalState(() => isHovered = false),
                              child: Transform.scale(
                                scale: isHovered ? 1.03 : 1.0,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.sp),
                                    boxShadow: isHovered
                                        ? [
                                      BoxShadow(
                                        color: WebsiteColors.primaryBlueColor.withOpacity(0.6),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 0),
                                      ),
                                    ]
                                        : [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // Image Header
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10.sp),
                                        child: AspectRatio(
                                          aspectRatio: 3 / 2,
                                          child: _buildEventCardImage(data),
                                        ),
                                      ),

                                      // Details
                                      Padding(
                                        padding: EdgeInsets.all(12.sp),
                                        child: Column(
                                          children: [
                                            Text(
                                              eventName,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 30.sp,
                                                fontWeight: FontWeight.bold,
                                                color: WebsiteColors.primaryBlueColor,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 20.sp),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.calendar_month_outlined,
                                                  size: 16.sp,
                                                  color: WebsiteColors.primaryBlueColor,
                                                ),
                                                SizedBox(width: 10.sp),
                                                Text(
                                                  eventDate,
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: WebsiteColors.darkBlueColor,
                                                    fontSize: 25.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      const Spacer(),

                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20.sp,
                                          vertical: 20.sp,
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => EditEventPage(
                                                  eventId: event.id,
                                                  eventData: data,
                                                ),
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            size: 25.sp,
                                            color: WebsiteColors.whiteColor,
                                          ),
                                          label: Text(
                                            "Edit",
                                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                              color: WebsiteColors.whiteColor,
                                              fontSize: 25.sp,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 50.sp,
                                              vertical: 30.sp,
                                            ),
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12.sp),
                                            ),
                                            minimumSize: Size.fromHeight(36.sp),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCardImage(Map<String, dynamic> data) {
    final List<dynamic>? imgListDynamic = data['imageUrls'];
    final List<String> firebaseImages = imgListDynamic != null ? List<String>.from(imgListDynamic) : [];

    final List<String>? localImages = EventsCard.eventImageMap[data['name']];
    String? firstImage;

    if (firebaseImages.isNotEmpty) {
      firstImage = firebaseImages.first;
    } else if (localImages != null && localImages.isNotEmpty) {
      firstImage = localImages.first;
    }

    return firstImage != null
        ? firstImage.startsWith("http")
        ? Image.network(
      firstImage,
      width: double.infinity,
      fit: BoxFit.fill,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.broken_image,
        size: 50.sp,
        color: Colors.grey,
      ),
    )
        : Image.asset(firstImage, width: double.infinity, fit: BoxFit.cover)
        : Icon(Icons.broken_image, size: 50.sp, color: Colors.grey);
  }
}