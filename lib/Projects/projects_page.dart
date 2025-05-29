import 'package:flutter/material.dart';
import 'package:ieee_website/Projects/components/project_card.dart';
import 'package:ieee_website/Projects/models/project_model.dart';
import 'package:ieee_website/Projects/pages/add_project_page.dart'
    as add_project;
import 'package:ieee_website/Projects/pages/project_details_page.dart';
import 'package:ieee_website/Projects/pages/update_project_page.dart';
import 'package:ieee_website/Projects/services/project_service.dart';
import 'package:ieee_website/Themes/website_colors.dart';

class Projects extends StatefulWidget {
  static const String routeName = 'projects';
  final TabController? tabController;

  const Projects({super.key, this.tabController});

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects>
    with SingleTickerProviderStateMixin {
  // This controller is for the internal tabs in Projects screen
  late TabController _projectTabController;
  final ProjectService _projectService = ProjectService();

  @override
  void initState() {
    super.initState();
    // Create a separate TabController for the Projects page tabs (length 3)
    _projectTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // Always dispose our internal controller
    _projectTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Column(
        children: [
          SizedBox(
            height: kToolbarHeight + 32, // Increased spacing to make tabs lower
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBubble('All Projects', 0),
                _buildBubble('Add Project', 1),
                _buildBubble('Manage Projects', 2),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _projectTabController,
              children: [
                _buildProjectsGrid(), // All Projects tab
                add_project.AddProjectPage(), // Add Project tab
                _buildManageProjectsTab(), // Manage Projects tab
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(String text, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _projectTabController.index = index; // Ensure tab navigation works
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color:
              _projectTabController.index == index
                  ? WebsiteColors.primaryBlueColor
                  : Colors.grey[300],
          borderRadius: BorderRadius.circular(
            25.0,
          ), // Use Flutter's BorderRadius
        ),
        child: Text(
          text,
          style: TextStyle(
            color:
                _projectTabController.index == index
                    ? Colors.white
                    : WebsiteColors.darkBlueColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            constraints.maxWidth < 600
                ? 2 // Small screens
                : constraints.maxWidth < 900
                ? 3 // Medium screens
                : 4; // Large screens

        return StreamBuilder<List<Project>>(
          stream: _projectService.getProjects(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: WebsiteColors.primaryBlueColor,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final projects = snapshot.data ?? [];
            if (projects.isEmpty) {
              return const Center(
                child: Text(
                  'No projects yet. Add your first project!',
                  style: TextStyle(
                    fontSize: 18,
                    color: WebsiteColors.greyColor,
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9, // Adjusted for better layout
                ),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return ProjectCard(
                    project: project,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ProjectDetailsPage(projectId: project.id),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildManageProjectsTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            constraints.maxWidth < 600
                ? 1 // Small screens
                : constraints.maxWidth < 900
                ? 2 // Medium screens
                : 3; // Large screens

        return StreamBuilder<List<Project>>(
          stream: _projectService.getProjects(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: WebsiteColors.primaryBlueColor,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final projects = snapshot.data ?? [];
            if (projects.isEmpty) {
              return const Center(
                child: Text(
                  'No projects to manage',
                  style: TextStyle(
                    fontSize: 18,
                    color: WebsiteColors.greyColor,
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.5, // Adjusted for better layout
                ),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return Card(
                    color: WebsiteColors.whiteColor,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading:
                          project.imageUrls != null &&
                                  project.imageUrls!.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  project.imageUrls!.first,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: WebsiteColors.whiteColor,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                      ),
                                    );
                                  },
                                ),
                              )
                              : Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: WebsiteColors.whiteColor,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Icon(
                                  Icons.image,
                                  color: WebsiteColors.primaryBlueColor,
                                ),
                              ),
                      title: Text(
                        project.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: WebsiteColors.darkBlueColor,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.madeBy != null
                                ? 'Made by: ${project.madeBy}'
                                : 'Made by: N/A',
                            style: const TextStyle(
                              color: WebsiteColors.descGreyColor,
                            ),
                          ),
                          Text(
                            project.date != null
                                ? 'Date: ${project.date.day}/${project.date.month}/${project.date.year}'
                                : 'Date: N/A',
                            style: const TextStyle(
                              color: WebsiteColors.descGreyColor,
                            ),
                          ),
                        ],
                      ),
                      trailing: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 100),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: WebsiteColors.primaryBlueColor,
                              ),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            UpdateProjectPage(project: project),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed:
                                  () =>
                                      _showDeleteConfirmation(context, project),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ProjectDetailsPage(projectId: project.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    Project project,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              WebsiteColors.whiteColor, // Set dialog background to white
          title: const Text(
            'Confirm Delete',
            style: TextStyle(
              color: WebsiteColors.primaryBlueColor,
            ), // Primary blue text
          ),
          content: Text(
            'Are you sure you want to delete "${project.title}"?',
            style: const TextStyle(
              color: WebsiteColors.primaryBlueColor,
            ), // Primary blue text
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: WebsiteColors.primaryBlueColor,
                ), // Primary blue text
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              style: TextButton.styleFrom(
                foregroundColor:
                    WebsiteColors.primaryBlueColor, // Primary blue text
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _projectService.deleteProject(project.id);
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Project successfully deleted'),
                      backgroundColor: WebsiteColors.primaryBlueColor,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
