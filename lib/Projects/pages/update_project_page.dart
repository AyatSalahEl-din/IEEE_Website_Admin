import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ieee_website/Projects/models/project_model.dart';
import 'package:ieee_website/Projects/services/project_service.dart';
import 'package:ieee_website/Themes/website_colors.dart';

class UpdateProjectPage extends StatefulWidget {
  final Project project;

  const UpdateProjectPage({Key? key, required this.project}) : super(key: key);

  @override
  State<UpdateProjectPage> createState() => _UpdateProjectPageState();
}

class _UpdateProjectPageState extends State<UpdateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _projectService = ProjectService();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  Uint8List? _selectedImage;
  String _imageName = '';
  bool _isLoading = false;
  bool _imageChanged = false;

  // Additional details controllers
  final Map<String, TextEditingController> _additionalDetailsControllers = {};
  final List<String> _additionalDetailKeys = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _descriptionController = TextEditingController(
      text: widget.project.description,
    );

    // Initialize additional details
    int index = 0;
    widget.project.additionalDetails.forEach((key, value) {
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
        _imageChanged = true;
      });
    }
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

        // Handle image upload if changed
        String? imageUrl = widget.project.imageUrl;
        if (_imageChanged && _selectedImage != null) {
          final sanitizedImageName = _imageName.replaceAll(
            RegExp(r'[^\w\-.]'),
            '_',
          );
          imageUrl = await _projectService.uploadProjectImage(
            imageBytes: _selectedImage!,
            imageName: sanitizedImageName,
          );

          if (imageUrl == null) {
            throw Exception('Failed to upload image.');
          }
        }

        // Create updated project
        final updatedProject = Project(
          id: widget.project.id, // Use the existing project ID
          name: _nameController.text,
          description: _descriptionController.text,
          imageUrl: imageUrl, // Nullable imageUrl
          createdAt: widget.project.createdAt,
          additionalDetails: additionalDetails,
        );

        // Update in Firebase
        await _projectService.updateProject(updatedProject, null, null);

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
            color: WebsiteColors.gradientBlueColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child:
              _selectedImage != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(_selectedImage!, fit: BoxFit.cover),
                  )
                  : widget.project.imageUrl!.isNotEmpty
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      '${widget.project.imageUrl}=w400', // Append "=w400"
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: WebsiteColors.primaryBlueColor,
                          ),
                        );
                      },
                    ),
                  )
                  : const Center(
                    child: Icon(
                      Icons.image,
                      size: 48,
                      color: WebsiteColors.primaryBlueColor,
                    ),
                  ),
        ),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Change Image'),
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
              const SizedBox(height: 24),

              // Image Upload
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
                          ),
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
