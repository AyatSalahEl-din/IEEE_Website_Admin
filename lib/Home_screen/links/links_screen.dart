import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LinksScreen extends StatefulWidget {
  @override
  _LinksScreenState createState() => _LinksScreenState();
}

class _LinksScreenState extends State<LinksScreen> {
  TextEditingController _linkController = TextEditingController();
  bool _isLoading = true;
  final String docName =
      'joinUs'; // Firestore document ID in "links" collection

  @override
  void initState() {
    super.initState();
    fetchCurrentLink();
  }

  Future<void> fetchCurrentLink() async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('links')
              .doc(docName)
              .get();

      String currentLink = doc['url'] ?? '';
      _linkController.text = currentLink;
    } catch (e) {
      print("Error fetching link: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to fetch link.")));
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> updateLink() async {
    String newLink = _linkController.text.trim();

    if (newLink.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Link cannot be empty.")));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('links').doc(docName).set({
        'url': newLink,
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Link updated successfully.")));
    } catch (e) {
      print("Error updating link: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update link.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Join Us Link")),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current Join Us Link:",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _linkController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Join Us URL",
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: updateLink,
                      child: Text("Update Link"),
                    ),
                  ],
                ),
              ),
    );
  }
}
