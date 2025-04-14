import 'package:flutter/material.dart';
import 'package:ieee_website/Projects/models/project_model.dart';
import 'package:ieee_website/Themes/website_colors.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({Key? key, required this.project, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap, // Make the entire card clickable
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child:
                  project.imageUrl != null && project.imageUrl!.isNotEmpty
                      ? Image.network(
                        '${project.imageUrl}=w400', // Append "=w400" for consistent sizing
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: WebsiteColors.primaryBlueColor,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: WebsiteColors.gradeintBlueColor,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: WebsiteColors.primaryBlueColor,
                              ),
                            ),
                          );
                        },
                      )
                      : Container(
                        color: WebsiteColors.gradeintBlueColor,
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: WebsiteColors.primaryBlueColor,
                          ),
                        ),
                      ),
            ),
            Container(
              color:
                  WebsiteColors.whiteColor, // Set the bottom section to white
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
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
}
