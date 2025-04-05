import 'package:flutter/material.dart';
import 'package:ieee_website/Projects/components/project_card.dart';
import 'package:ieee_website/Projects/models/project_model.dart';
import 'package:ieee_website/Projects/pages/add_project_page.dart';
import 'package:ieee_website/Projects/pages/project_details_page.dart';
import 'package:ieee_website/Projects/pages/update_project_page.dart';
import 'package:ieee_website/Projects/services/project_service.dart';
import 'package:ieee_website/Themes/website_colors.dart';

class Projects extends StatefulWidget {
  static const String routeName = 'projects';
  final TabController?
  tabController; // This is the parent controller from Base widget (length 6)

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
                AddProjectPage(), // Add Project tab
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
          borderRadius: BorderRadius.circular(25.0),
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
          debugPrint('Error in StreamBuilder: ${snapshot.error}'); // Debug log
          return Center(
            child: Text(
              'Error loading projects: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final projects = snapshot.data ?? [];
        if (projects.isEmpty) {
          debugPrint('No projects found'); // Debug log
          return const Center(
            child: Text(
              'No projects yet. Add your first project!',
              style: TextStyle(fontSize: 18, color: WebsiteColors.greyColor),
            ),
          );
        }

        // Responsive grid layout to prevent overflow
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _calculateCrossAxisCount(context),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9, // Adjusted for smaller card proportions
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
  }

  // Helper method to make grid responsive
  int _calculateCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return 3;
    } else if (width > 800) {
      return 2;
    } else {
      return 1;
    }
  }

  Widget _buildManageProjectsTab() {
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
              style: TextStyle(fontSize: 18, color: WebsiteColors.greyColor),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return Card(
              color: WebsiteColors.whiteColor, // Set card background to white
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 3,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                leading:
                    project.imageUrl!.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            project.imageUrl ?? '',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color:
                                    WebsiteColors
                                        .whiteColor, // Set container background to white
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        )
                        : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color:
                                WebsiteColors
                                    .whiteColor, // Set container background to white
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Icon(
                            Icons.image,
                            color: WebsiteColors.primaryBlueColor,
                          ),
                        ),
                title: Text(
                  project.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: WebsiteColors.darkBlueColor,
                  ),
                ),
                subtitle: Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: WebsiteColors.descGreyColor),
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
                            () => _showDeleteConfirmation(context, project),
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
            'Are you sure you want to delete "${project.name}"?',
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
