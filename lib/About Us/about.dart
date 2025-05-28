import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AboutUs extends StatefulWidget {
  static const String routeName = 'aboutus';
  final TabController? tabController;

  const AboutUs({Key? key, this.tabController}) : super(key: key);

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  bool _isLoading = true;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();

  // Main data fields
  final Map<String, TextEditingController> _controllers = {};

  // Values section
  List<Map<String, dynamic>> _valuesData = [];

  // Color scheme
  static const Color primaryColor = Color(0xFF2563eb);
  static const Color primaryLight = Color(0xFFdbeafe);
  static const Color surfaceColor = Color(0xFFfafafa);
  static const Color cardColor = Colors.white;
  static const Color borderColor = Color(0xFFe5e7eb);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6b7280);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load main about data
      final aboutSnapshot = await FirebaseFirestore.instance
          .collection('about')
          .doc('main')
          .get();

      if (aboutSnapshot.exists) {
        final mainData = aboutSnapshot.data() ?? {};

        // Initialize controllers for each field
        [
          'heroTitle', 'heroSubtitle', 'heroHighlight',
          'missionTitle', 'missionParagraph1', 'missionParagraph2',
          'communityStatement',
          'whatWeDoTitle', 'empowermentTitle', 'empowermentText',
          'valuesTitle'
        ].forEach((field) {
          _controllers[field] = TextEditingController(text: mainData[field] ?? '');
        });
      }

      // Load values data
      final valuesSnapshot = await FirebaseFirestore.instance
          .collection('about')
          .doc('values')
          .collection('items')
          .get();

      _valuesData = valuesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'icon': data['icon'] ?? 'star',
          'title': data['title'] ?? '',
          'description': data['description'] ?? '',
          'iconController': TextEditingController(text: data['icon'] ?? 'star'),
          'titleController': TextEditingController(text: data['title'] ?? ''),
          'descriptionController': TextEditingController(text: data['description'] ?? ''),
        };
      }).toList();

      // Add at least 3 value items if none exist
      if (_valuesData.isEmpty) {
        for (int i = 0; i < 3; i++) {
          _addNewValueItem();
        }
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addNewValueItem() {
    setState(() {
      _valuesData.add({
        'id': null,
        'icon': 'star',
        'title': '',
        'description': '',
        'iconController': TextEditingController(text: 'star'),
        'titleController': TextEditingController(text: ''),
        'descriptionController': TextEditingController(text: ''),
      });
    });
  }

  void _removeValueItem(int index) {
    final item = _valuesData[index];

    // Dispose controllers
    (item['iconController'] as TextEditingController).dispose();
    (item['titleController'] as TextEditingController).dispose();
    (item['descriptionController'] as TextEditingController).dispose();

    setState(() {
      _valuesData.removeAt(index);
    });
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Save main data
      final mainData = {
        'heroTitle': _controllers['heroTitle']!.text,
        'heroSubtitle': _controllers['heroSubtitle']!.text,
        'heroHighlight': _controllers['heroHighlight']!.text,
        'missionTitle': _controllers['missionTitle']!.text,
        'missionParagraph1': _controllers['missionParagraph1']!.text,
        'missionParagraph2': _controllers['missionParagraph2']!.text,
        'communityStatement': _controllers['communityStatement']!.text,
        'whatWeDoTitle': _controllers['whatWeDoTitle']!.text,
        'empowermentTitle': _controllers['empowermentTitle']!.text,
        'empowermentText': _controllers['empowermentText']!.text,
        'valuesTitle': _controllers['valuesTitle']!.text,
      };

      await FirebaseFirestore.instance
          .collection('about')
          .doc('main')
          .set(mainData);

      // Save values data
      final valuesRef = FirebaseFirestore.instance
          .collection('about')
          .doc('values')
          .collection('items');

      // First delete all existing values
      final existingValues = await valuesRef.get();
      final batch = FirebaseFirestore.instance.batch();

      for (var doc in existingValues.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Then add all current values
      for (var item in _valuesData) {
        await valuesRef.add({
          'icon': (item['iconController'] as TextEditingController).text,
          'title': (item['titleController'] as TextEditingController).text,
          'description': (item['descriptionController'] as TextEditingController).text,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text("Changes saved successfully", style: TextStyle(fontSize: 15)),
            ],
          ),
          backgroundColor: Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(16),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text("Error saving data: $e", style: TextStyle(fontSize: 15)),
            ],
          ),
          backgroundColor: Color(0xFFdc2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'About Us Management',
          style: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        shadowColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            height: 1,
            color: borderColor,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Loading content...',
              style: TextStyle(
                color: textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : Form(
        key: _formKey,
        child: Column(
          children: [
            // Content
            Expanded(
              child: _buildCombinedContent(),
            ),

            // Save button
            Container(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border(
                  top: BorderSide(color: borderColor, width: 1),
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: borderColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
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
                            strokeWidth: 2.5,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Saving Changes...",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    )
                        : Text(
                      "Save Changes",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCombinedContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          _buildSectionCard(
            'Hero Section',
            Icons.rocket_launch_outlined,
            [
              _buildTextField(
                controller: _controllers['heroTitle']!,
                label: 'Hero Title',
                placeholder: 'About IEEE PUA',
                validator: _validateRequired,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _controllers['heroSubtitle']!,
                label: 'Hero Subtitle',
                placeholder: 'ADDRESSING GLOBAL CHALLENGES',
                validator: _validateRequired,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _controllers['heroHighlight']!,
                label: 'Hero Highlight',
                placeholder: 'Advancing Technology for the Benefit of Humanity',
                validator: _validateRequired,
              ),
            ],
          ),
          SizedBox(height: 24),

          // Mission Section
          _buildSectionCard(
            'Mission Section',
            Icons.flag_outlined,
            [
              _buildTextField(
                controller: _controllers['missionTitle']!,
                label: 'Mission Title',
                placeholder: 'Our Mission',
                validator: _validateRequired,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _controllers['missionParagraph1']!,
                label: 'Mission Paragraph 1',
                placeholder: 'IEEE PUA Student Branch (SB) at Pharos University in Alexandria was established in 2014...',
                validator: _validateRequired,
                maxLines: 4,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _controllers['missionParagraph2']!,
                label: 'Mission Paragraph 2',
                placeholder: 'We provide our members with comprehensive development...',
                maxLines: 4,
              ),
            ],
          ),
          SizedBox(height: 24),

          // Community Statement
          _buildSectionCard(
            'Community Statement',
            Icons.groups_outlined,
            [
              _buildTextField(
                controller: _controllers['communityStatement']!,
                label: 'Community Statement',
                placeholder: 'IEEE PUA SB represents more than just a student organization...',
                validator: _validateRequired,
                maxLines: 4,
              ),
            ],
          ),
          SizedBox(height: 24),

          // What We Do Section
          _buildSectionCard(
            'What We Do Section',
            Icons.work_outline,
            [
              _buildTextField(
                controller: _controllers['whatWeDoTitle']!,
                label: 'Section Title',
                placeholder: 'What We Do',
                validator: _validateRequired,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _controllers['empowermentTitle']!,
                label: 'Empowerment Title',
                placeholder: 'We empower engineering students',
                validator: _validateRequired,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _controllers['empowermentText']!,
                label: 'Empowerment Text',
                placeholder: 'Through IEEE-led workshops, hands-on projects...',
                validator: _validateRequired,
                maxLines: 4,
              ),
            ],
          ),
          SizedBox(height: 24),

          // Values Section Title
          _buildSectionCard(
            'Values Section',
            Icons.auto_awesome_outlined,
            [
              _buildTextField(
                controller: _controllers['valuesTitle']!,
                label: 'Values Section Title',
                placeholder: 'Our Values',
                validator: _validateRequired,
              ),
            ],
          ),
          SizedBox(height: 24),

          // Core Values Items
          _buildCoreValuesSection(),
        ],
      ),
    );
  }

  Widget _buildCoreValuesSection() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: borderColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.psychology_outlined,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Core Values',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Define your organization\'s core principles',
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Value items
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                ..._valuesData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return Container(
                    margin: EdgeInsets.only(bottom: index == _valuesData.length - 1 ? 0 : 20),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row
                        Row(
                          children: [
                            // Cleaner number badge
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Value ${index + 1}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                            // Delete button
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Color(0xFFef4444),
                                size: 20,
                              ),
                              onPressed: _valuesData.length > 1
                                  ? () => _removeValueItem(index)
                                  : null,
                              constraints: BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              padding: EdgeInsets.all(8),
                              tooltip: 'Remove value',
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                hoverColor: Color(0xFFfef2f2),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Icon dropdown
                        DropdownButtonFormField<String>(
                          value: (item['iconController'] as TextEditingController).text,
                          decoration: _buildInputDecoration(
                            label: 'Icon',
                            prefixIcon: Icon(
                              _getIconData((item['iconController'] as TextEditingController).text),
                              color: primaryColor,
                              size: 20,
                            ),
                          ),
                          items: [
                            _buildIconDropdownItem('people', 'People'),
                            _buildIconDropdownItem('lightbulb', 'Lightbulb'),
                            _buildIconDropdownItem('trending_up', 'Growth'),
                            _buildIconDropdownItem('school', 'Education'),
                            _buildIconDropdownItem('engineering', 'Engineering'),
                            _buildIconDropdownItem('group_work', 'Teamwork'),
                            _buildIconDropdownItem('star', 'Excellence'),
                          ],
                          onChanged: (value) {
                            setState(() {
                              (item['iconController'] as TextEditingController).text = value ?? 'star';
                            });
                          },
                          validator: _validateRequired,
                          icon: Icon(Icons.keyboard_arrow_down, color: textSecondary, size: 20),
                          isExpanded: true,
                          dropdownColor: cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        SizedBox(height: 16),

                        // Title field
                        _buildTextField(
                          controller: item['titleController'] as TextEditingController,
                          label: 'Title',
                          placeholder: 'e.g., Collaboration',
                          validator: _validateRequired,
                        ),
                        SizedBox(height: 16),

                        // Description field
                        _buildTextField(
                          controller: item['descriptionController'] as TextEditingController,
                          label: 'Description',
                          placeholder: 'e.g., Working together across IEEE disciplines...',
                          validator: _validateRequired,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  );
                }).toList(),

                // Add new value button
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _addNewValueItem,
                    icon: Icon(Icons.add, size: 18),
                    label: Text("Add New Value"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: borderColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<String> _buildIconDropdownItem(String value, String label) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(_getIconData(value), size: 18, color: primaryColor),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: Color(0xFF9ca3af),
        fontSize: 15,
      ),
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFFef4444), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFFef4444), width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      filled: true,
      fillColor: cardColor,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 15,
        color: textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: _buildInputDecoration(
        label: label,
        hint: placeholder,
      ),
      validator: validator,
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'people':
        return Icons.people;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'trending_up':
        return Icons.trending_up;
      case 'school':
        return Icons.school;
      case 'engineering':
        return Icons.engineering;
      case 'group_work':
        return Icons.group_work;
      default:
        return Icons.star;
    }
  }
}