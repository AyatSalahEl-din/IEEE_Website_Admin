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

  @override
  void initState() {
    super.initState();
    _loadContactContent();
  }

  Future<void> _loadContactContent() async {
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

      final socialLinks = Map<String, dynamic>.from(data['socialLinks'] ?? {});
      socialLinks.forEach((key, value) {
        if (_socialLinksControllers.containsKey(key)) {
          _socialLinksControllers[key]!.text = value ?? '';
        }
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveContactContent() async {
    final updatedData = {
      'headerTitle': _headerTitleController.text.trim(),
      'headerDescription': _headerDescriptionController.text.trim(),
      'address': _addressController.text.trim(),
      'emails': _emailControllers.map((controller) => controller.text.trim()).toList(),
      'socialLinks': {
        for (var entry in _socialLinksControllers.entries)
          entry.key: entry.value.text.trim(),
      }
    };

    await FirebaseFirestore.instance.collection('contact_page').doc('content').set(updatedData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Changes saved successfully")),
    );
  }

  void _addEmailField() {
    setState(() {
      _emailControllers.add(TextEditingController());
    });
  }

  void _removeEmailField(int index) {
    setState(() {
      _emailControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Contact Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveContactContent,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("Header Title", _headerTitleController),
            SizedBox(height: 15),
            _buildTextField("Header Description", _headerDescriptionController),
            SizedBox(height: 15),
            _buildTextField("Address", _addressController),
            SizedBox(height: 25),
            Text("Emails:", style: TextStyle(fontWeight: FontWeight.bold)),
            ..._emailControllers.asMap().entries.map((entry) {
              int index = entry.key;
              return Row(
                children: [
                  Expanded(child: _buildTextField("Email ${index + 1}", entry.value)),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeEmailField(index),
                  ),
                ],
              );
            }),
            ElevatedButton(
              onPressed: _addEmailField,
              child: Text("Add Email"),
            ),
            SizedBox(height: 25),
            Text("Social Links:", style: TextStyle(fontWeight: FontWeight.bold)),
            _buildTextField("Facebook", _socialLinksControllers['facebook']!),
            _buildTextField("LinkedIn", _socialLinksControllers['linkedin']!),
            _buildTextField("Instagram", _socialLinksControllers['instagram']!),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
