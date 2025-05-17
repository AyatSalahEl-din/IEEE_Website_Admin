import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Contact extends StatefulWidget {
  static const String routeName = 'contact';
  final TabController? tabController;
  const Contact({Key? key, this.tabController}) : super(key: key);

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  final TextEditingController _headerTitleController = TextEditingController();
  final TextEditingController _headerDescriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final List<TextEditingController> _emailControllers = [];
  final Map<String, TextEditingController> _socialLinksControllers = {
    'facebook': TextEditingController(),
    'linkedin': TextEditingController(),
    'instagram': TextEditingController(),
  };

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadContactContent();
  }

  Future<void> _loadContactContent() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('contact_page').doc('content').get();
      final data = doc.data();

      if (data != null) {
        _headerTitleController.text = data['headerTitle'] ?? '';
        _headerDescriptionController.text = data['headerDescription'] ?? '';
        _addressController.text = data['address'] ?? '';

        final emails = List<String>.from(data['emails'] ?? []);
        _emailControllers.clear();
        for (var email in emails) {
          _emailControllers.add(TextEditingController(text: email));
        }

        // Add at least one email field if none exist
        if (_emailControllers.isEmpty) {
          _emailControllers.add(TextEditingController());
        }

        final socialLinks = Map<String, dynamic>.from(data['socialLinks'] ?? {});
        socialLinks.forEach((key, value) {
          if (_socialLinksControllers.containsKey(key)) {
            _socialLinksControllers[key]!.text = value ?? '';
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading data: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveContactContent() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final updatedData = {
        'headerTitle': _headerTitleController.text.trim(),
        'headerDescription': _headerDescriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'emails': _emailControllers.map((controller) => controller.text.trim()).toList(),
        'socialLinks': {
          for (var entry in _socialLinksControllers.entries)
            entry.key: entry.value.text.trim(),
        },
      };

      await FirebaseFirestore.instance.collection('contact_page').doc('content').set(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Changes saved successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _addEmailField() {
    setState(() {
      _emailControllers.add(TextEditingController());
    });
  }

  void _removeEmailField(int index) {
    if (_emailControllers.length > 1) {
      setState(() {
        _emailControllers.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must have at least one email address")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        color: Colors.white,
        child: Column(
          children: [
            // Top navigation bar
            Container(
              color: const Color(0xFF0066A0),
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Contact Us - Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Content area
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Information
                      Text(
                        'Header Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Header Title
                      _buildLabeledField(
                        label: 'Header Title',
                        icon: Icons.title,
                        child: _buildTextField(
                          controller: _headerTitleController,
                          placeholder: 'Contact Us',
                        ),
                      ),
                      SizedBox(height: 12),

                      // Header Description
                      _buildLabeledField(
                        label: 'Header Description',
                        icon: Icons.description,
                        child: _buildTextField(
                          controller: _headerDescriptionController,
                          placeholder: 'Fill up the form and our Team will get back to you',
                          maxLines: 2,
                        ),
                      ),
                      SizedBox(height: 24),

                      // Contact Details
                      Text(
                        'Contact Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Address
                      _buildLabeledField(
                        label: 'Address',
                        icon: Icons.location_on,
                        child: _buildTextField(
                          controller: _addressController,
                          placeholder: 'Pharos University in Alexandria (PUA)',
                        ),
                      ),
                      SizedBox(height: 16),

                      // Email Addresses
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.email, color: Color(0xFF0066A0), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Email Addresses',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: _addEmailField,
                            icon: Icon(Icons.add, size: 16),
                            label: Text("Add Email"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0066A0),
                              foregroundColor: Colors.white,
                              minimumSize: Size(30, 32),
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              textStyle: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),

                      // Email fields
                      ..._emailControllers.asMap().entries.map((entry) {
                        int index = entry.key;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Email ${index + 1}',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: _buildTextField(
                                  controller: entry.value,
                                  placeholder: 'example@email.com',
                                ),
                              ),
                              SizedBox(width: 4),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                constraints: BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () => _removeEmailField(index),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 24),

                      // Social Media Links
                      Text(
                        'Social Media Links',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Facebook
                      _buildSocialMediaField(
                        icon: Icons.facebook,
                        label: 'Facebook',
                        controller: _socialLinksControllers['facebook']!,
                      ),
                      SizedBox(height: 12),

                      // LinkedIn
                      _buildSocialMediaField(
                        icon: Icons.link,
                        label: 'LinkedIn',
                        controller: _socialLinksControllers['linkedin']!,
                      ),
                      SizedBox(height: 12),

                      // Instagram
                      _buildSocialMediaField(
                        icon: Icons.camera_alt,
                        label: 'Instagram',
                        controller: _socialLinksControllers['instagram']!,
                      ),
                      SizedBox(height: 24),

                      // Save button
                      Center(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveContactContent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0066A0),
                            foregroundColor: Colors.white,
                            minimumSize: Size(120, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: _isSaving
                              ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text("Saving...")
                            ],
                          )
                              : Text("Save Changes"),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          child: Icon(icon, color: Color(0xFF0066A0), size: 20),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              child,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: maxLines > 1 ? 12 : 8),
        isDense: true,
      ),
    );
  }

  Widget _buildSocialMediaField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Icon(icon, color: Color(0xFF0066A0), size: 20),
        ),
        SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}