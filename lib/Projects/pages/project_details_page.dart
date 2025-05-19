import 'package:flutter/material.dart';
import 'package:ieee_website/Projects/models/project_model.dart';
import 'package:ieee_website/Projects/services/project_service.dart';
import 'package:ieee_website/Themes/website_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../pages/update_project_page.dart';

class ProjectDetailsPage extends StatefulWidget {
  final String projectId;

  const ProjectDetailsPage({Key? key, required this.projectId})
    : super(key: key);

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  final ProjectService _projectService = ProjectService();
  bool _isLoading = true;
  Project? _project;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProjectDetails();
  }

  Future<void> _loadProjectDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final project = await _projectService.getProjectById(
        widget.projectId,
      ); // Fetch by ID
      setState(() {
        _project = project;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load project details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProject() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                WebsiteColors.whiteColor, // Set dialog background to white
            title: const Text(
              'Confirm Delete',
              style: TextStyle(
                color: WebsiteColors.primaryBlueColor,
              ), // Primary blue text
            ),
            content: Text(
              'Are you sure you want to delete "${_project?.title}"? This action cannot be undone.',
              style: const TextStyle(
                color: WebsiteColors.primaryBlueColor,
              ), // Primary blue text
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: WebsiteColors.primaryBlueColor,
                  ), // Primary blue text
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: WebsiteColors.primaryBlueColor,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (shouldDelete == true && _project != null) {
      try {
        await _projectService.deleteProject(widget.projectId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project deleted successfully'),
              backgroundColor: WebsiteColors.primaryBlueColor,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting project: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildProjectImage() {
    final List<String>? firebaseImages = _project?.imageUrls;
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
          height: 300,
          fit: BoxFit.fill,
          errorBuilder:
              (context, error, stackTrace) => const Icon(
                Icons.broken_image,
                size: 50,
                color: WebsiteColors.primaryBlueColor,
              ),
        )
        : Container(
          width: double.infinity,
          height: 300,
          color: WebsiteColors.gradeintBlueColor,
          child: const Icon(
            Icons.broken_image,
            size: 50,
            color: WebsiteColors.primaryBlueColor,
          ),
        );
  }

  Widget _buildImageUrlsSection() {
    if (_project?.imageUrls == null || _project!.imageUrls!.isEmpty) {
      return const SizedBox.shrink(); // Return an empty widget if no URLs exist
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Image URLs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: WebsiteColors.darkBlueColor,
          ),
        ),
        const SizedBox(height: 12),
        ..._project!.imageUrls!.map((url) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: WebsiteColors.whiteColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    url,
                    style: const TextStyle(color: WebsiteColors.darkGreyColor),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.open_in_browser,
                    color: WebsiteColors.primaryBlueColor,
                  ),
                  onPressed: () async {
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not launch URL'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Project Details'),
          backgroundColor: WebsiteColors.primaryBlueColor,
          foregroundColor: WebsiteColors.whiteColor,
        ),
        backgroundColor:
            WebsiteColors.whiteColor, // Set background color to white
        body: const Center(
          child: CircularProgressIndicator(
            color: WebsiteColors.primaryBlueColor,
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Project Details'),
          backgroundColor: WebsiteColors.primaryBlueColor,
          foregroundColor: WebsiteColors.whiteColor,
        ),
        backgroundColor:
            WebsiteColors.whiteColor, // Set background color to white
        body: Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (_project == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Project Details'),
          backgroundColor: WebsiteColors.primaryBlueColor,
          foregroundColor: WebsiteColors.whiteColor,
        ),
        backgroundColor:
            WebsiteColors.whiteColor, // Set background color to white
        body: const Center(child: Text('Project not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _project!.title,
          style: const TextStyle(color: WebsiteColors.whiteColor),
        ),
        backgroundColor: WebsiteColors.primaryBlueColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: WebsiteColors.whiteColor),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateProjectPage(project: _project!),
                ),
              );
              if (result == true) {
                _loadProjectDetails();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: WebsiteColors.whiteColor),
            onPressed: _deleteProject,
          ),
        ],
      ),
      backgroundColor:
          WebsiteColors.whiteColor, // Explicitly set background color
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project image
            _buildProjectImage(),

            // Project details
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project name
                  Text(
                    _project!.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: WebsiteColors.darkBlueColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Made by
                  Text(
                    _project!.madeBy ?? 'Made by: N/A',
                    style: const TextStyle(
                      fontSize: 16,
                      color: WebsiteColors.greyColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Creation date
                  Text(
                    'Date: ${_project!.date.day}/${_project!.date.month}/${_project!.date.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: WebsiteColors.greyColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  Wrap(
                    spacing: 4,
                    children:
                        _project!.tags.map((tag) {
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
                  const SizedBox(height: 24),

                  // Description section
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: WebsiteColors.darkBlueColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: WebsiteColors.gradeintBlueColor.withOpacity(0.3),
                      color: WebsiteColors.gradeintBlueColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: WebsiteColors.primaryBlueColor.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      _project!.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: WebsiteColors.darkGreyColor,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Additional details section
                  if (_project!.additionalDetails != null &&
                      _project!.additionalDetails!.isNotEmpty) ...[
                    const Text(
                      'Additional Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: WebsiteColors.darkBlueColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._project!.additionalDetails!.entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: WebsiteColors.whiteColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade100,
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${entry.key}:',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: WebsiteColors.darkBlueColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${entry.value}',
                                style: const TextStyle(
                                  color: WebsiteColors.darkGreyColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],

                  // Image URLs Section
                  _buildImageUrlsSection(), // Add the image URLs section
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Container>? buildAdditionalDetails() {
    return _project!.additionalDetails?.entries.map((entry) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: WebsiteColors.whiteColor, // Set card background to white
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              '${entry.key}:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: WebsiteColors.darkBlueColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${entry.value}',
                style: const TextStyle(color: WebsiteColors.darkGreyColor),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
