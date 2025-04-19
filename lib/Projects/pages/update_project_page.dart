import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ieee_website/Projects/models/project_model.dart';
import 'package:ieee_website/Projects/services/project_service.dart';
import 'package:ieee_website/Themes/website_colors.dart';

class UpdateProjectPage extends StatefulWidget {
  final Project project;
  final List<String>? imageUrls;
  const UpdateProjectPage({Key? key, required this.project, this.imageUrls})
    : super(key: key);

  @override
  State<UpdateProjectPage> createState() => _UpdateProjectPageState();
}

class _UpdateProjectPageState extends State<UpdateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _projectService = ProjectService();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final _tagsController = TextEditingController();
  final _madeByController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;

  // Additional details controllers
  final Map<String, TextEditingController> _additionalDetailsControllers = {};
  final List<String> _additionalDetailKeys = [];
  List<String>? imageUrls;
  final List<TextEditingController> _imageControllers =
      []; // List to handle multiple image URLs

  @override
  void initState() {
    super.initState();
    imageUrls =
        widget.project.imageUrls?.where((url) => url.isNotEmpty).toList() ??
        []; // Filter out empty URLs
    for (final url in imageUrls!) {
      _imageControllers.add(
        TextEditingController(text: url),
      ); // Initialize controllers with existing URLs
    }
    if (_imageControllers.isEmpty) {
      _imageControllers.add(
        TextEditingController(),
      ); // Add at least one controller
    }
    _nameController = TextEditingController(
      
    );
    _descriptionController = TextEditingController(
      
    );
    _tagsController.text =
        widget.project.tags.isNotEmpty ? widget.project.tags.join(', ') : '';
    _madeByController.text = widget.project.madeBy ?? '';
   // _selectedDate = widget.project.date ?? DateTime.now();

    // Initialize additional details
    int index = 0;
    widget.project.additionalDetails?.forEach((key, value) {
      final fieldKey = 'detail_$index';
      _additionalDetailKeys.add(fieldKey);
      _additionalDetailsControllers[fieldKey] = TextEditingController(
        text: '$key: $value',
      );
      index++;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _madeByController.dispose();
    for (final controller in _imageControllers) {
      controller.dispose();
    }
    for (final controller in _additionalDetailsControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addDetailField() {
    final key = 'detail_${_additionalDetailKeys.length}';
    setState(() {
      _additionalDetailKeys.add(key);
      _additionalDetailsControllers[key] = TextEditingController();
    });
  }

  void _removeDetailField(String key) {
    setState(() {
      _additionalDetailKeys.remove(key);
      _additionalDetailsControllers[key]?.dispose();
      _additionalDetailsControllers.remove(key);
    });
  }

  void _addImageField() {
    setState(() {
      _imageControllers.add(TextEditingController());
    });
  }

  void _removeImageField(int index) {
    setState(() {
      _imageControllers[index].dispose();
      _imageControllers.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Gather image URLs
        final updatedImageUrls =
            _imageControllers
                .map((controller) => controller.text.trim())
                .where((url) => url.isNotEmpty)
                .toList();

        // Gather additional details
        final additionalDetails = <String, dynamic>{};
        for (final key in _additionalDetailKeys) {
          final controller = _additionalDetailsControllers[key];
          if (controller != null && controller.text.trim().isNotEmpty) {
            final parts = controller.text.split(':');
            if (parts.length > 1) {
              additionalDetails[parts[0].trim()] = parts[1].trim();
            } else {
              additionalDetails[controller.text.trim()] = '';
            }
          }
        }

        // Create updated project
        final updatedProject = Project(
          id: widget.project.id,
          title: _nameController.text,
          description: _descriptionController.text,
          madeBy:
              _madeByController.text.trim().isNotEmpty
                  ? _madeByController.text.trim()
                  : 'Unknown',
          date: _selectedDate,
          tags:
              _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
          imageUrls: updatedImageUrls,
          additionalDetails:
              additionalDetails.isNotEmpty ? additionalDetails : null,
        );

        // Update in Firebase
        await _projectService.updateProject(
          updatedProject,
          widget.project.additionalDetails,
        );

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project updated successfully'),
              backgroundColor: WebsiteColors.primaryBlueColor,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        debugPrint('Error updating project: $e'); // Debug log
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildTagsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: WebsiteColors.darkGreyColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _tagsController,
          decoration: InputDecoration(
            hintText: 'Enter tags separated by commas',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: WebsiteColors.primaryBlueColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildMadeByInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Made By (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: WebsiteColors.darkGreyColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _madeByController,
          decoration: InputDecoration(
            hintText: 'Enter creator name (Optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: WebsiteColors.primaryBlueColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Date (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: WebsiteColors.darkGreyColor,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              setState(() {
                _selectedDate = pickedDate;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalDetailsFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Additional Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: WebsiteColors.darkGreyColor,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addDetailField,
              icon: const Icon(Icons.add),
              label: const Text('Add Field'),
              style: ElevatedButton.styleFrom(
                backgroundColor: WebsiteColors.primaryBlueColor,
                foregroundColor: WebsiteColors.whiteColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._additionalDetailKeys.map((key) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _additionalDetailsControllers[key],
                    decoration: InputDecoration(
                      hintText: 'Key: Value (e.g., Team Size: 5)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: WebsiteColors.darkBlueColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeDetailField(key),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildImageInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Image URLs',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: WebsiteColors.darkGreyColor,
          ),
        ),
        const SizedBox(height: 8),
        ..._imageControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Enter image URL',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: WebsiteColors.primaryBlueColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                if (_imageControllers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeImageField(index),
                  ),
              ],
            ),
          );
        }).toList(),
        ElevatedButton.icon(
          onPressed: _addImageField,
          icon: const Icon(Icons.add),
          label: const Text('Add Image'),
          style: ElevatedButton.styleFrom(
            backgroundColor: WebsiteColors.primaryBlueColor,
            foregroundColor: WebsiteColors.whiteColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Update Project',
          style: TextStyle(color: WebsiteColors.whiteColor),
        ),
        backgroundColor: WebsiteColors.primaryBlueColor,
        iconTheme: const IconThemeData(color: WebsiteColors.whiteColor),
      ),
      backgroundColor:
          WebsiteColors.whiteColor, // Explicitly set background color
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Project Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: WebsiteColors.darkBlueColor,
                ),
              ),
              const SizedBox(height: 24),

              // Project Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Project Name', // Use hint text instead of label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: WebsiteColors.primaryBlueColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8, // Smaller padding
                    horizontal: 12,
                  ),
                ),
                style: const TextStyle(fontSize: 14), // Smaller font size
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Project name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Project Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText:
                      'Project Description', // Use hint text instead of label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: WebsiteColors.primaryBlueColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8, // Smaller padding
                    horizontal: 12,
                  ),
                ),
                style: const TextStyle(fontSize: 14), // Smaller font size
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Project description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Image Inputs
              _buildImageInputs(),
              const SizedBox(height: 16),

              // Made By Input
              _buildMadeByInput(),
              const SizedBox(height: 16),

              // Tags Input
              _buildTagsInput(),
              const SizedBox(height: 16),

              // Project Date
              _buildDatePicker(),
              const SizedBox(height: 24),

              // Additional Details
              _buildAdditionalDetailsFields(),
              const SizedBox(height: 32),

              // Submit button
              Center(
                child: SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WebsiteColors.primaryBlueColor,
                      foregroundColor: WebsiteColors.whiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: WebsiteColors.whiteColor,
                            )
                            : const Text(
                              'Update Project',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void updateProject({
  required BuildContext context,
  required String projectId,
  required GlobalKey<FormState> formKey,
  required TextEditingController titleController,
  required TextEditingController categoryController,
  required TextEditingController descriptionController,
  required List<String> imageUrls,
  required DateTime? selectedDate,
  required Function(bool) setLoading,
}) async {
  if (!formKey.currentState!.validate()) {
    return;
  }
  setLoading(true);

  try {
    // Convert category to uppercase
    final category = categoryController.text.trim().toUpperCase();

    // Check if the category already exists in Firestore
    final existingCategories =
        await FirebaseFirestore.instance
            .collection('projects')
            .where('category', isEqualTo: category)
            .get();

    if (existingCategories.docs.isNotEmpty) {
      // If the category exists, use the existing category name
      categoryController.text = existingCategories.docs.first['category'];
    } else {
      // Otherwise, save the category in uppercase
      categoryController.text = category;
    }

    final updatedData = {
      'title': titleController.text.trim(),
      'category': categoryController.text.trim(),
      'description': descriptionController.text.trim(),
      'imageUrls': imageUrls,
      'date': selectedDate != null ? Timestamp.fromDate(selectedDate) : null,
    };

    await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .update(updatedData);

    setLoading(false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project updated successfully!')),
    );
  } catch (e) {
    setLoading(false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}
