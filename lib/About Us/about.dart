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

        // Initialize controllers for each field - removed video related fields
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
        'id': null, // Will be assigned by Firestore when saved
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
      // Save main data - removed video related fields
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

  String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066A0),
        title: Text(
          'About Us - Admin',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF0066A0)))
          : Container(
        color: Colors.grey[50],
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Content
              Expanded(
                child: _buildCombinedContent(),
              ),

              // Save button
              Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0066A0),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 1,
                  ),
                  child: _isSaving
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Saving Changes...",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  )
                      : Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

  Widget _buildCombinedContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          _buildSectionCard(
            'Hero Section',
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
          SizedBox(height: 32),

          // Mission Section
          _buildSectionCard(
            'Mission Section',
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
                maxLines: 5,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _controllers['missionParagraph2']!,
                label: 'Mission Paragraph 2',
                placeholder: 'We provide our members with comprehensive development...',
                maxLines: 5,
              ),
            ],
          ),
          SizedBox(height: 32),

          // Community Statement
          _buildSectionCard(
            'Community Statement',
            [
              _buildTextField(
                controller: _controllers['communityStatement']!,
                label: 'Community Statement',
                placeholder: 'IEEE PUA SB represents more than just a student organization...',
                validator: _validateRequired,
                maxLines: 5,
              ),
            ],
          ),
          SizedBox(height: 32),

          // What We Do Section
          _buildSectionCard(
              'What We Do Section',
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
                  maxLines: 5,
                ),
              ]
          ),
          SizedBox(height: 32),

          // Values Section Title
          _buildSectionCard(
            'Values Section',
            [
              _buildTextField(
                controller: _controllers['valuesTitle']!,
                label: 'Values Section Title',
                placeholder: 'Our Values',
                validator: _validateRequired,
              ),
            ],
          ),
          SizedBox(height: 32),

          // Core Values Items
          _buildCoreValuesSection(),
        ],
      ),
    );
  }

  Widget _buildCoreValuesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Core Values header card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 24),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFF0066A0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Core Values',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0066A0),
                    ),
                  ),
                ),

                // Value items
                ..._valuesData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return Container(
                    margin: EdgeInsets.only(bottom: 32),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF0066A0).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0066A0),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Core Value ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0066A0),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red[700], size: 24),
                              constraints: BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: _valuesData.length > 1
                                  ? () => _removeValueItem(index)
                                  : null,
                              tooltip: 'Remove value item',
                            ),
                          ],
                        ),
                        SizedBox(height: 24),

                        // Icon field with dropdown
                        DropdownButtonFormField<String>(
                          value: (item['iconController'] as TextEditingController).text,
                          decoration: InputDecoration(
                            labelText: 'Icon',
                            labelStyle: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF0066A0), width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(
                              _getIconData((item['iconController'] as TextEditingController).text),
                              color: Color(0xFF0066A0),
                              size: 24,
                            ),
                          ),
                          items: [
                            _buildIconDropdownItem('people', 'People'),
                            _buildIconDropdownItem('lightbulb', 'Lightbulb'),
                            _buildIconDropdownItem('trending_up', 'Trending Up'),
                            _buildIconDropdownItem('school', 'School'),
                            _buildIconDropdownItem('engineering', 'Engineering'),
                            _buildIconDropdownItem('group_work', 'Group Work'),
                            _buildIconDropdownItem('star', 'Star'),
                          ],
                          onChanged: (value) {
                            setState(() {
                              (item['iconController'] as TextEditingController).text = value ?? 'star';
                            });
                          },
                          validator: _validateRequired,
                          icon: Icon(Icons.arrow_drop_down, color: Color(0xFF0066A0)),
                          isExpanded: true,
                          dropdownColor: Colors.white,
                        ),
                        SizedBox(height: 24),

                        // Title field
                        _buildTextField(
                          controller: item['titleController'] as TextEditingController,
                          label: 'Title',
                          placeholder: 'e.g., Collaboration',
                          validator: _validateRequired,
                        ),
                        SizedBox(height: 24),

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
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: _addNewValueItem,
                      icon: Icon(Icons.add_circle_outline, size: 20),
                      label: Text("Add New Value"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0066A0),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 24),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFF0066A0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0066A0),
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildIconDropdownItem(String value, String label) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(_getIconData(value), size: 20, color: Color(0xFF0066A0)),
          SizedBox(width: 12),
          Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              )
          ),
        ],
      ),
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
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        labelStyle: TextStyle(
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF0066A0), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 16 : 12
        ),
        filled: true,
        fillColor: Colors.white,
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
        return Icons.star; // Default icon
    }
  }
}