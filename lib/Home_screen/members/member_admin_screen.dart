import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ieee_website/Home_screen/members/member_form_dialog.dart';
import 'package:ieee_website/Home_screen/members/models/layout_config.dart';
import 'package:ieee_website/Home_screen/members/models/team_member.dart';
import 'package:ieee_website/Home_screen/members/widgets/admin_team_member_card.dart';
import 'package:ieee_website/Themes/website_colors.dart';

class MemberAdminScreen extends StatefulWidget {
  const MemberAdminScreen({Key? key}) : super(key: key);

  @override
  State<MemberAdminScreen> createState() => _MemberAdminScreenState();
}

class _MemberAdminScreenState extends State<MemberAdminScreen> {
  List<int> rowSizes = [];
  final _numRowsController = TextEditingController();
  final List<TextEditingController> _rowSizeControllers = [];
  bool _showRowInputs = false;

  @override
  void initState() {
    super.initState();
    _loadRowSizes();
  }

  Future<void> _loadRowSizes() async {
    rowSizes = await LayoutConfig.fetchRowSizes();
    _rowSizeControllers.clear();
    for (var size in rowSizes) {
      _rowSizeControllers.add(TextEditingController(text: size.toString()));
    }
    setState(() {});
  }

  void _updateRowCount() {
    int count = int.tryParse(_numRowsController.text) ?? 0;
    if (count <= 0) return;

    _rowSizeControllers.clear();
    for (int i = 0; i < count; i++) {
      _rowSizeControllers.add(TextEditingController(text: '1'));
    }

    setState(() {
      _showRowInputs = true;
    });
  }

  Future<void> _saveLayoutToFirestore() async {
    List<int> sizes =
        _rowSizeControllers
            .map((controller) => int.tryParse(controller.text) ?? 1)
            .toList();

    await LayoutConfig.saveRowSizes(sizes);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Row layout saved successfully!")));

    _loadRowSizes(); // Refresh
  }

  Future<void> _deleteMember(String? memberId) async {
    if (memberId == null || memberId.isEmpty) {
      print("Error: Member ID is null or empty");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('Members')
          .doc(memberId)
          .delete();

      print("Member deleted: $memberId");

      // Ensure UI updates correctly
      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      print("Error deleting member: $e");
      print(stackTrace); // Logs detailed error info without freezing
    }
  }

  void _confirmDelete(TeamMember member) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Confirm Delete"),
            content: Text('Are you sure you want to delete "${member.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("No"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog first
                  await Future.delayed(
                    Duration(milliseconds: 100),
                  ); // Let UI settle
                  await _deleteMember(member.id); // Delete member

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${member.name} deleted successfully'),
                      ),
                    );
                  }
                },
                child: Text("Yes"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Manage Team Members",
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: WebsiteColors.primaryBlueColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _numRowsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Number of Rows"),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _updateRowCount,
                    child: Text(
                      "Set Rows",
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: WebsiteColors.primaryBlueColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_showRowInputs) // ONLY SHOW AFTER BUTTON PRESS
              ..._rowSizeControllers
                  .asMap()
                  .entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      child: TextField(
                        controller: entry.value,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              "Members in Row ${entry.key + 1} (at most 4 members)",
                        ),
                      ),
                    ),
                  )
                  .toList(),
            if (_showRowInputs)
              ElevatedButton(
                onPressed: _saveLayoutToFirestore,
                child: Text("Save Layout"),
              ),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('Members')
                      .orderBy('number')
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                List<TeamMember> members =
                    snapshot.data!.docs.map((doc) {
                      return TeamMember.fromFirestore(
                        doc.id,
                        doc.data() as Map<String, dynamic>,
                      );
                    }).toList();

                List<List<TeamMember>> rows = [];
                int startIndex = 0;
                for (int size in rowSizes) {
                  if (startIndex >= members.length) break;
                  int endIndex = (startIndex + size).clamp(0, members.length);
                  rows.add(members.sublist(startIndex, endIndex));
                  startIndex = endIndex;
                }

                return SingleChildScrollView(
                  child: Column(
                    children:
                        rows.map((row) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                row.map((member) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Flexible(
                                      flex:
                                          1, // Adjust this flex value if needed
                                      child: AdminTeamMemberCard(
                                        member: member,
                                        onEdit: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => MemberEditScreen(
                                                    member: member,
                                                  ),
                                            ),
                                          );
                                        },
                                        onDelete: () => _confirmDelete(member),
                                      ),
                                    ),
                                  );
                                }).toList(),
                          );
                        }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MemberEditScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
