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
    return Padding(
      padding:  EdgeInsets.all(8.sp),
      child: SingleChildScrollView( // Wrap the entire column inside SingleChildScrollView
        child: Column(
          children: [
            // Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: WebsiteColors.greyColor),
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.grey[100],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
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
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - 250,
              ),
              child: StreamBuilder<QuerySnapshot>(

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
                    return const Center(child: Text("No events found."));
                  }

                  return GridView.builder(

                    shrinkWrap: true,  // Prevent overflow by shrinking the GridView
                  //  physics: NeverScrollableScrollPhysics(),  // Prevent overflow by letting GridView size based on content
                    itemCount: filteredEvents.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 30.sp,
                      mainAxisSpacing: 30.sp,
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

                      return Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        child: Column(
                          children: [
                            // Image Header
                            Stack(
                              children:[ ClipRRect(
                                borderRadius: BorderRadius.circular(10.sp),
                                child: AspectRatio(
                                  aspectRatio: 3 / 2,
                                  child: _buildEventCardImage(data),
                                ),
                              ),
                                Padding(
                                  padding: EdgeInsets.all( 20.sp),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: WebsiteColors.whiteColor, // Set the background color to grey
                                      borderRadius: BorderRadius.circular(50.sp), // Optional: rounded corners for the container
                                    ),
                                    child: IconButton(

                                      iconSize: 40.sp,
                                      icon: Icon(
                                        Icons.delete_rounded,
                                        color: WebsiteColors.greyColor, // Set the icon color to white
                                        size: 40.sp,
                                      ),
                                      tooltip: "Delete Event",
                                      onPressed: () async {
                                        final confirmed = await _showConfirmationDialog(
                                          context,
                                          eventName,
                                        );
                                        if (confirmed == true) {
                                          await FirebaseFirestore.instance.collection('events').doc(event.id).delete();
                                        }
                                      },
                                    ),
                                  ),
                                )
                              ]
                            ),

                            // Details
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Text(
                                    eventName,
                                    style: TextStyle(
                                        fontSize: 30.sp,
                                        fontWeight: FontWeight.bold,
                                        color: WebsiteColors.primaryBlueColor),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 10.sp),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.calendar_month_outlined,
                                          size: 16, color: WebsiteColors.primaryBlueColor),
                                      SizedBox(width: 10.sp),
                                      Text(
                                        eventDate,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: WebsiteColors.darkBlueColor,
                                            fontSize: 25.sp
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),



                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔒 Confirmation Dialog Before Deletion
  Future<bool?> _showConfirmationDialog(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: WebsiteColors.whiteColor,
        title: Text(
          'Delete Event',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: WebsiteColors.darkBlueColor,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$name"? This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: WebsiteColors.primaryBlueColor,
            fontSize: 30.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: WebsiteColors.darkGreyColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: WebsiteColors.darkBlueColor,
              foregroundColor: Colors.white,
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
    final List<String> firebaseImages =
    imgListDynamic != null ? List<String>.from(imgListDynamic) : [];

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
                ? loadingProgress.cumulativeBytesLoaded /
                (loadingProgress.expectedTotalBytes ?? 1)
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
      fit: BoxFit.cover,
    )
        : Icon(Icons.broken_image, size: 50.sp, color: Colors.grey);


  }
}
