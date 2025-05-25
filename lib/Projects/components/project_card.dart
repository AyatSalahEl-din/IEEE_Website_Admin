import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ieee_website/Projects/models/project_model.dart';
import 'package:ieee_website/Themes/website_colors.dart';

class ProjectCard extends StatelessWidget {
  static const Map<String, List<String>> projectImageMap = {
    // Add predefined local images for projects here if needed
    // "Project Name": ["assets/images/project1.jpg", "assets/images/project2.jpg"],
  };

  final Project project;
  final VoidCallback onTap;

  const ProjectCard({Key? key, required this.project, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, // White background for the card
      elevation: 2,
      margin: EdgeInsets.all(4.sp),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.sp)),
      child: Padding(
        padding: EdgeInsets.all(10.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildProjectCardImage()),
            Container(
              color:
                  WebsiteColors.whiteColor, // Set the bottom section to white
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: WebsiteColors.darkBlueColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: WebsiteColors.descGreyColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.madeBy ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 12,
                      color: WebsiteColors.greyColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${project.date.day}/${project.date.month}/${project.date.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: WebsiteColors.greyColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (project.tags.isNotEmpty) // Show only if tags are provided
                    Wrap(
                      spacing: 4,
                      children:
                          project.tags.map((tag) {
                            return Chip(
                              label: Text(tag),
                              backgroundColor: WebsiteColors.gradeintBlueColor,
                              labelStyle: const TextStyle(
                                color: WebsiteColors.primaryBlueColor,
                                fontSize: 12,
                              ),
                            );
                          }).toList(),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WebsiteColors.primaryBlueColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          color: WebsiteColors.whiteColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCardImage() {
    final List<String>? firebaseImages = project.imageUrls;
    String? firstImage;

    if (firebaseImages != null && firebaseImages.isNotEmpty) {
      firstImage = firebaseImages.firstWhere(
        (url) => url.isNotEmpty && url.startsWith('http'),
        orElse:
            () => '', // Fallback to an empty string if no valid URL is found
      );
    }

    return firstImage != null && firstImage.isNotEmpty
        ? Image.network(
          firstImage,
          width: double.infinity,
          height:40
          , // Fixed height for consistent card layout
          fit: BoxFit.cover, // Ensure the image covers the available space
          errorBuilder:
              (context, error, stackTrace) => const Icon(
                Icons.broken_image,
                size: 50,
                color: WebsiteColors.primaryBlueColor,
              ),
        )
        : Container(
          width: double.infinity,
          height: 40, // Fixed height for consistent card layout
          color: WebsiteColors.gradeintBlueColor,
          child: const Icon(
            Icons.broken_image,
            size: 50,
            color: WebsiteColors.primaryBlueColor,
          ),
        );
  }
}
