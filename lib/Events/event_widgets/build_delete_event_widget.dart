import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/Themes/website_colors.dart';
import 'package:intl/intl.dart';
import 'events_card.dart';

class BuildDeleteEventWidget extends StatefulWidget {
  const BuildDeleteEventWidget({super.key});

  @override
  State<BuildDeleteEventWidget> createState() => _BuildDeleteEventWidgetState();
}

class _BuildDeleteEventWidgetState extends State<BuildDeleteEventWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16.sp : 20.sp),
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
                            fontSize: isSmallScreen ? 14.sp : 16.sp,
                          ),
                          prefixIcon: Icon(Icons.search, size: isSmallScreen ? 18.sp : 20.sp),
                          fillColor: Colors.grey[100],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.sp),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 12.sp : 14.sp,
                            horizontal: 16.sp,
                          ),
                        ),
                        style: TextStyle(fontSize: isSmallScreen ? 14.sp : 16.sp),
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
                          'No events found.',
                          style: TextStyle(fontSize: 18.sp, color: WebsiteColors.greyColor),
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredEvents.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isSmallScreen ? 2 : 3,
                        crossAxisSpacing: isSmallScreen ? 20.sp : 30.sp,
                        mainAxisSpacing: isSmallScreen ? 20.sp : 30.sp,
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
                              onEnter: (_) => setLocalState(() => isHovered = !isSmallScreen),
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
                                        blurRadius: 20.sp,
                                        spreadRadius: 2.sp,
                                        offset: const Offset(0, 0),
                                      ),
                                    ]
                                        : [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        blurRadius: 4.sp,
                                        spreadRadius: 1.sp,
                                        offset: Offset(0, 2.sp),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // Image Header with Delete Icon
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10.sp),
                                            child: AspectRatio(
                                              aspectRatio: 3 / 2,
                                              child: _buildEventCardImage(data),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(isSmallScreen ? 16.sp : 20.sp),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: WebsiteColors.whiteColor,
                                                borderRadius: BorderRadius.circular(50.sp),
                                              ),
                                              child: IconButton(
                                                iconSize: isSmallScreen ? 32.sp : 40.sp,
                                                icon: Icon(
                                                  Icons.delete_rounded,
                                                  color: WebsiteColors.greyColor,
                                                  size: isSmallScreen ? 32.sp : 40.sp,
                                                ),
                                                tooltip: 'Delete Event',
                                                onPressed: () async {
                                                  final confirmed = await _showConfirmationDialog(
                                                    context,
                                                    eventName,
                                                  );
                                                  if (confirmed == true) {
                                                    await FirebaseFirestore.instance
                                                        .collection('events')
                                                        .doc(event.id)
                                                        .delete();
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Details
                                      Padding(
                                        padding: EdgeInsets.all(12.sp),
                                        child: Column(
                                          children: [
                                            Text(
                                              eventName,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: isSmallScreen ? 24.sp : 30.sp,
                                                fontWeight: FontWeight.bold,
                                                color: WebsiteColors.primaryBlueColor,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 10.sp),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.calendar_month_outlined,
                                                  size: isSmallScreen ? 14.sp : 16.sp,
                                                  color: WebsiteColors.primaryBlueColor,
                                                ),
                                                SizedBox(width: 10.sp),
                                                Text(
                                                  eventDate,
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: WebsiteColors.darkBlueColor,
                                                    fontSize: isSmallScreen ? 20.sp : 25.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
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

  /// 🔒 Confirmation Dialog Before Deletion
  Future<bool?> _showConfirmationDialog(BuildContext context, String name) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: WebsiteColors.whiteColor,
        title: Text(
          'Delete Event',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: WebsiteColors.darkBlueColor,
            fontSize: isSmallScreen ? 16.sp : 18.sp,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$name"? This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: WebsiteColors.primaryBlueColor,
            fontSize: isSmallScreen ? 14.sp : 16.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: WebsiteColors.darkGreyColor,
                fontSize: isSmallScreen ? 12.sp : 14.sp,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: WebsiteColors.darkBlueColor,
              foregroundColor: WebsiteColors.whiteColor,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12.sp : 16.sp,
                vertical: isSmallScreen ? 6.sp : 8.sp,
              ),
              textStyle: TextStyle(fontSize: isSmallScreen ? 12.sp : 14.sp),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
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
        ? firstImage.startsWith('http')
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
        : Image.asset(
      firstImage,
      width: double.infinity,
      fit: BoxFit.fill,
    )
        : Icon(Icons.broken_image, size: 50.sp, color: Colors.grey);
  }
}