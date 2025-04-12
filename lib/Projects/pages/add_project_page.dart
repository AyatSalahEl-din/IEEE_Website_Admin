import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ieee_website/Projects/models/project_model.dart';
import 'package:ieee_website/Projects/services/project_service.dart';
import 'package:ieee_website/Themes/website_colors.dart';

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

  Uint8List? _selectedImage;
  String _imageName = '';
  bool _isLoading = false;

  // Additional details controllers
  final Map<String, TextEditingController> _additionalDetailsControllers = {};
  final List<String> _additionalDetailKeys = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (final controller in _additionalDetailsControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedImage = result.files.first.bytes;
        _imageName = result.files.first.name;
      });
      debugPrint('Image selected: $_imageName'); // Debug log
    } else {
      debugPrint('No image selected'); // Debug log
    }
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

        // Sanitize the image name
        String? imageUrl;
        if (_selectedImage != null) {
          final sanitizedImageName =
              _imageName
                  .replaceAll(
                    RegExp(r'[^\w\-.]'),
                    '_',
                  ) // Replace special characters
                  .replaceAll(
                    RegExp(r'_+'),
                    '_',
                  ) // Remove consecutive underscores
                  .trim(); // Trim leading/trailing underscores

          debugPrint('Sanitized image name: $sanitizedImageName'); // Debug log

          // Upload image with retry logic
          imageUrl = await _projectService.uploadImageWithRetry(
            imageBytes: _selectedImage!,
            imageName: sanitizedImageName,
          );

          if (imageUrl == null) {
            throw Exception('Failed to upload image.');
          }
        }

        // Create project
        final project = Project(
          id: '', // Firestore will generate the ID
          name: _nameController.text,
          description: _descriptionController.text,
          additionalDetails: additionalDetails,
          imageUrl: imageUrl, // Nullable imageUrl
        );

        if (!mounted) return;
        await _projectService.addProject(project, null, '');

        // Reset form after successful submission
        _nameController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedImage = null;
          _imageName = '';
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

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Image',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: WebsiteColors.darkGreyColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 250, // Increased height
          width: 300, // Reduced width
          decoration: BoxDecoration(
            color: WebsiteColors.gradeintBlueColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child:
              _selectedImage != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(_selectedImage!, fit: BoxFit.cover),
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_upload,
                        size: 48,
                        color: WebsiteColors.primaryBlueColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _imageName.isEmpty
                            ? 'No image selected'
                            : 'Selected: $_imageName',
                        style: const TextStyle(color: WebsiteColors.greyColor),
                      ),
                    ],
                  ),
        ),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Select Image'),
            style: ElevatedButton.styleFrom(
              backgroundColor: WebsiteColors.primaryBlueColor,
              foregroundColor: WebsiteColors.whiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
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
                const SizedBox(height: 24),

                // Image Upload Section
                _buildImageUploadSection(),
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
