import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        _headerTitleController.text = data['headerTitle'] ?? 'Contact Us';
        _headerDescriptionController.text = data['headerDescription'] ?? 'Fill up the form and our Team will get back to you';
        _addressController.text = data['address'] ?? 'Pharos University in Alexandria (PUA)';

        final emails = List<String>.from(data['emails'] ?? ['pua-ieee-sb@pua.edu.eg', 'ieee.pua.sb.pr@gmail.com']);
        _emailControllers.clear();
        for (var email in emails) {
          _emailControllers.add(TextEditingController(text: email));
        }

        if (_emailControllers.isEmpty) {
          _emailControllers.add(TextEditingController(text: 'pua-ieee-sb@pua.edu.eg'));
          _emailControllers.add(TextEditingController(text: 'ieee.pua.sb.pr@gmail.com'));
        }

        final socialLinks = Map<String, dynamic>.from(data['socialLinks'] ?? {
          'facebook': 'https://www.facebook.com/share/1YKyPBgRVK/',
          'linkedin': 'https://www.linkedin.com/company/ieee-pua-student-branch/',
          'instagram': 'https://www.instagram.com/ieeepua?igsh=MWVla2RzbmJkNTZ5MQ==',
        });

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
        'lastUpdated': FieldValue.serverTimestamp(),
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF0066A0)))
          : Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0066A0), Color(0xFF004C7A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Row(
              children: [
                Icon(Icons.contacts, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'Contact Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionCard(
                      title: 'Header Information',
                      icon: Icons.dashboard_outlined,
                      children: [
                        _buildEnhancedField(
                          label: 'Page Title',
                          icon: Icons.title_outlined,
                          controller: _headerTitleController,
                          placeholder: 'Contact Us',
                        ),
                        SizedBox(height: 20),
                        _buildEnhancedField(
                          label: 'Page Description',
                          icon: Icons.description_outlined,
                          controller: _headerDescriptionController,
                          placeholder: 'Fill up the form and our Team will get back to you',
                          maxLines: 3,
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    _buildSectionCard(
                      title: 'Contact Information',
                      icon: Icons.location_on_outlined,
                      children: [
                        _buildEnhancedField(
                          label: 'Business Address',
                          icon: Icons.business_outlined,
                          controller: _addressController,
                          placeholder: 'Pharos University in Alexandria (PUA)',
                          maxLines: 2,
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    _buildSectionCard(
                      title: 'Email Addresses',
                      icon: Icons.email_outlined,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Manage contact emails',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            _buildAddButton(
                              onPressed: _addEmailField,
                              label: 'Add Email',
                              icon: Icons.add_circle_outline,
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        ..._emailControllers.asMap().entries.map((entry) {
                          int index = entry.key;
                          return _buildEmailField(index, entry.value);
                        }).toList(),
                      ],
                    ),
                    SizedBox(height: 24),
                    _buildSectionCard(
                      title: 'Social Media Links',
                      icon: Icons.share_outlined,
                      children: [
                        _buildSocialField(
                          icon: Icons.facebook_outlined,
                          label: 'Facebook Page',
                          controller: _socialLinksControllers['facebook']!,
                          placeholder: 'https://www.facebook.com/share/1YKyPBgRVK/',
                        ),
                        SizedBox(height: 16),
                        _buildSocialField(
                          icon: Icons.business_center_outlined,
                          label: 'LinkedIn Profile',
                          controller: _socialLinksControllers['linkedin']!,
                          placeholder: 'https://www.linkedin.com/company/ieee-pua-student-branch/',
                        ),
                        SizedBox(height: 16),
                        _buildSocialField(
                          icon: Icons.camera_alt_outlined,
                          label: 'Instagram Account',
                          controller: _socialLinksControllers['instagram']!,
                          placeholder: 'https://www.instagram.com/ieeepua?igsh=MWVla2RzbmJkNTZ5MQ==',
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    Center(
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(maxWidth: 200),
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveContactContent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0066A0),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: Color(0xFF0066A0).withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isSaving
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Saving Changes...",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_outlined, size: 18),
                              SizedBox(width: 8),
                              Text(
                                "Save Changes",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF0066A0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Color(0xFF0066A0),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String placeholder,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Color(0xFF0066A0), size: 16),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey[800],
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF0066A0), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(int index, TextEditingController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(0xFF0066A0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Color(0xFF0066A0),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey[800],
              ),
              decoration: InputDecoration(
                hintText: 'example@email.com',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Color(0xFF0066A0)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 18),
            constraints: BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            onPressed: () => _removeEmailField(index),
            tooltip: 'Remove email',
          ),
        ],
      ),
    );
  }

  Widget _buildSocialField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Color(0xFF0066A0), size: 16),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.grey[800],
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF0066A0), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: Color(0xFF0066A0)),
      label: Text(
        label,
        style: TextStyle(
          color: Color(0xFF0066A0),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: Color(0xFF0066A0).withOpacity(0.3)),
        ),
      ),
    );
  }
}