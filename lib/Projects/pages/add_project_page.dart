import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ieee_website/Projects/models/project_model.dart';
import 'package:ieee_website/Projects/services/project_service.dart';
import 'package:ieee_website/Themes/website_colors.dart';

import '../../widgets/datepicker.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({Key? key}) : super(key: key);

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _projectService = ProjectService();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _madeByController = TextEditingController();
  final _tagsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Additional details controllers
  final Map<String, TextEditingController> _additionalDetailsControllers = {};
  final List<String> _additionalDetailKeys = [];

  final List<TextEditingController> _imageControllers =
      []; // List to handle multiple image URLs

  @override
  void initState() {
    super.initState();
    _imageControllers.add(
      TextEditingController(),
    ); // Add the first image controller by default
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose(); // Dispose the image URL controller
    _madeByController.dispose();
    _tagsController.dispose();
    for (final controller in _additionalDetailsControllers.values) {
      controller.dispose();
    }
    for (final controller in _imageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addDetailField() {
    final key = 'detail_${_additionalDetailKeys.length + 1}';
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

        // Gather image URLs
        final imageUrls =
            _imageControllers
                .map((controller) => controller.text.trim())
                .where((url) => url.isNotEmpty)
                .toList();

        // Create project
        final project = Project(
          id: '', // Firestore will generate the ID
          title:
              _nameController.text.isNotEmpty
                  ? _nameController.text
                  : 'Untitled Project',
          description:
              _descriptionController.text.isNotEmpty
                  ? _descriptionController.text
                  : 'No description provided',
          madeBy:
              _madeByController.text.trim().isNotEmpty
                  ? _madeByController.text.trim()
                  : 'Unknown',
          date: _selectedDate,
          tags:
              _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
          imageUrls: imageUrls,
          additionalDetails:
              additionalDetails.isNotEmpty ? additionalDetails : null,
        );

        if (!mounted) return;
        await _projectService.addProject(project);

        // Reset form after successful submission
        _nameController.clear();
        _descriptionController.clear();
        _imageUrlController.clear();
        _madeByController.clear();
        _tagsController.clear();
        setState(() {
          _additionalDetailKeys.clear();
          _additionalDetailsControllers.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project added successfully'),
            backgroundColor: WebsiteColors.primaryBlueColor,
          ),
        );
      } catch (e) {
        debugPrint('Error adding project: $e'); // Debug log
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void addProject({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController titleController,
    required TextEditingController categoryController,
    required TextEditingController descriptionController,
    required List<String> imageUrls,
    required DateTime? selectedDate,
    required Function(bool) setLoading,
    required Function() resetForm,
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

      final projectData = {
        'title': titleController.text.trim(),
        'category': categoryController.text.trim(),
        'description': descriptionController.text.trim(),
        'imageUrls': imageUrls,
        'date': selectedDate != null ? Timestamp.fromDate(selectedDate) : null,
      };

      await FirebaseFirestore.instance.collection('projects').add(projectData);

      resetForm();
      setLoading(false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project added successfully!')),
      );
    } catch (e) {
      setLoading(false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
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
        CustomDatePicker(
          initialDate: _selectedDate,
          onDatePicked: (newDate) {
            setState(() {
              _selectedDate = newDate!;
            });
          },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          WebsiteColors.whiteColor, // Explicitly set background color
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Project',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold, // Make title bold
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

                // Date Picker
                _buildDatePicker(),
                const SizedBox(height: 16),

                // Made By Input
                _buildMadeByInput(),
                const SizedBox(height: 16),

                // Tags Input
                _buildTagsInput(),
                const SizedBox(height: 24),

                // Additional Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Additional Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // Make title bold
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

                // Dynamic additional details fields
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
                                  color:
                                      WebsiteColors
                                          .darkBlueColor, // Change color when selected
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, // Make the text field smaller
                                horizontal: 12,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                            ), // Smaller font size
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
                                'Add Project',
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
        ],
      ),
    );
  }
}
