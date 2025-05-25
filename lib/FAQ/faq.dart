import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ieee_website/Themes/website_colors.dart';

class FAQ extends StatefulWidget {
  static const String routeName = 'faq';
  final TabController? tabController;
  const FAQ({Key? key, this.tabController}) : super(key: key);

  @override
  State<FAQ> createState() => _FAQState();
}

class _FAQState extends State<FAQ> {
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  bool isEditing = false;
  String currentDocId = '';

  @override
  void dispose() {
    questionController.dispose();
    answerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> addOrUpdateFAQItem() async {
    if (!_formKey.currentState!.validate()) return;

    final String question = questionController.text.trim();
    final String answer = answerController.text.trim();

    try {
      if (isEditing) {
        await FirebaseFirestore.instance.collection('faq').doc(currentDocId).update({
          'question': question,
          'answer': answer,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        isEditing = false;
        currentDocId = '';
      } else {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('faq')
            .orderBy('order', descending: true)
            .limit(1)
            .get();

        int nextOrder = 1;
        if (snapshot.docs.isNotEmpty) {
          final lastOrder = snapshot.docs.first['order'];
          nextOrder = lastOrder + 1;
        }

        await FirebaseFirestore.instance.collection('faq').add({
          'question': question,
          'answer': answer,
          'order': nextOrder,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      questionController.clear();
      answerController.clear();
      setState(() {});

      _showSnackBar(
        isEditing ? 'Question updated successfully' : 'Question added successfully',
        Icons.check_circle_outline,
        WebsiteColors.primaryBlueColor,
      );
    } catch (e) {
      _showSnackBar(
        'Error: ${e.toString()}',
        Icons.error_outline,
        WebsiteColors.redColor,
      );
    }
  }

  void _showSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: WebsiteColors.whiteColor, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis, // Handle text overflow
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(8),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Close',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          textColor: WebsiteColors.whiteColor,
        ),
      ),
    );
  }

  void editFAQItem(String docId, String question, String answer) {
    setState(() {
      questionController.text = question;
      answerController.text = answer;
      isEditing = true;
      currentDocId = docId;
    });

    // Scroll to form on small screens if editing
    final size = MediaQuery.of(context).size;
    if (size.width < 900) {
      // Small screen - scroll to the form area
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    }
  }

  Future<void> deleteFAQItem(String docId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: WebsiteColors.primaryYellowColor, size: 18),
            const SizedBox(width: 8),
            const Flexible(
              child: Text("Confirm Delete", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to delete this question? This action cannot be undone.",
          style: TextStyle(fontSize: 14),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: WebsiteColors.redColor,
              foregroundColor: WebsiteColors.whiteColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text("Delete", style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await FirebaseFirestore.instance.collection('faq').doc(docId).delete();
        if (currentDocId == docId) {
          questionController.clear();
          answerController.clear();
          isEditing = false;
          currentDocId = '';
        }
        setState(() {});
        _showSnackBar('Question deleted successfully', Icons.check_circle_outline, WebsiteColors.primaryBlueColor);
      } catch (e) {
        _showSnackBar('Error deleting question: ${e.toString()}', Icons.error_outline, WebsiteColors.redColor);
      }
    }
  }

  Future<void> reorderFAQ(int oldIndex, int newIndex, List<QueryDocumentSnapshot> docs) async {
    if (oldIndex == newIndex) return;

    try {
      // If moving down, we need to adjust the target index
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final batch = FirebaseFirestore.instance.batch();

      // Reorder the docs
      final movedDoc = docs[oldIndex];

      if (newIndex > oldIndex) {
        // Moving down
        for (int i = oldIndex + 1; i <= newIndex; i++) {
          batch.update(docs[i].reference, {'order': i - 1});
        }
      } else {
        // Moving up
        for (int i = newIndex; i < oldIndex; i++) {
          batch.update(docs[i].reference, {'order': i + 1});
        }
      }

      batch.update(movedDoc.reference, {'order': newIndex});
      await batch.commit();
      _showSnackBar('FAQ order updated', Icons.check_circle_outline, WebsiteColors.primaryBlueColor);
    } catch (e) {
      _showSnackBar('Error reordering questions: ${e.toString()}', Icons.error_outline, WebsiteColors.redColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FAQ Management",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        elevation: 0,
        backgroundColor: WebsiteColors.primaryBlueColor,
      ),
      body: Container(
        color: Colors.grey.shade50,
        height: size.height,
        width: size.width,
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16, vertical: 8),
        child: isSmallScreen
            ? SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              _buildAddFAQForm(),
              const SizedBox(height: 16),
              _buildFAQList(true), // Pass isSmallScreen
            ],
          ),
        )
            : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FAQ List on the left (40% width)
            Expanded(
              flex: 5,
              child: _buildFAQList(false), // Pass isSmallScreen
            ),
            const SizedBox(width: 16),
            // Form on the right (60% width)
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                child: _buildAddFAQForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddFAQForm() {
    return Card(
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form Header
              Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit_note : Icons.add_circle_outline,
                    color: WebsiteColors.primaryBlueColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      isEditing ? "Edit Question" : "Add New Question",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: WebsiteColors.primaryBlueColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Question Field
              TextFormField(
                controller: questionController,
                decoration: InputDecoration(
                  labelText: "Question",
                  hintText: "Enter the question",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  isDense: true,
                  prefixIcon: Icon(Icons.help_outline, color: WebsiteColors.primaryBlueColor, size: 18),
                ),
                style: const TextStyle(fontSize: 14),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a question';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Answer Field
              TextFormField(
                controller: answerController,
                decoration: InputDecoration(
                  labelText: "Answer",
                  hintText: "Enter the answer",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  prefixIcon: Icon(Icons.question_answer_outlined, color: WebsiteColors.primaryBlueColor, size: 18),
                  alignLabelWithHint: true,
                ),
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an answer';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Form Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isEditing)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          questionController.clear();
                          answerController.clear();
                          isEditing = false;
                          currentDocId = '';
                        });
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text("Cancel", style: TextStyle(fontSize: 13)),
                      style: TextButton.styleFrom(
                        foregroundColor: WebsiteColors.darkGreyColor,
                      ),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: addOrUpdateFAQItem,
                    icon: Icon(isEditing ? Icons.save_outlined : Icons.add_circle_outline, size: 16),
                    label: Text(
                      isEditing ? "Update" : "Add",
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WebsiteColors.primaryBlueColor,
                      foregroundColor: WebsiteColors.whiteColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildFAQList(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FAQ List Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  Icon(Icons.list_alt, color: WebsiteColors.primaryBlueColor, size: 16),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      "Frequently Asked Questions",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: WebsiteColors.darkBlueColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                "Drag to reorder",
                style: TextStyle(
                  fontSize: 11,
                  color: WebsiteColors.descGreyColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // FAQ List
        SizedBox(
          // Use constraints for height instead of fixed height to avoid overflow
          height: isSmallScreen
              ? MediaQuery.of(context).size.height * 0.6 - 80 // Reduce height by 15+ pixels
              : MediaQuery.of(context).size.height - 165, // Reduce height by 15 pixels
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('faq')
                .orderBy('order')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 36, color: WebsiteColors.redColor),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading questions',
                        style: TextStyle(color: WebsiteColors.redColor, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.question_answer,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No FAQs found",
                        style: TextStyle(
                          fontSize: 14,
                          color: WebsiteColors.greyColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Add new questions using the form",
                        style: TextStyle(
                          fontSize: 12,
                          color: WebsiteColors.descGreyColor,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.grey.shade100,
                ),
                child: ReorderableListView.builder(
                  itemCount: docs.length,
                  onReorder: (oldIndex, newIndex) =>
                      reorderFAQ(oldIndex, newIndex, docs),
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 16),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    final question = data['question'] ?? '';
                    final answer = data['answer'] ?? '';
                    final bool isCurrentEditingItem = currentDocId == docId;

                    return Card(
                      key: Key(docId),
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: isCurrentEditingItem
                            ? BorderSide(color: WebsiteColors.primaryBlueColor, width: 1)
                            : BorderSide.none,
                      ),
                      child: ExpansionTile(
                        leading: Container(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            Icons.drag_indicator,
                            color: WebsiteColors.greyColor,
                            size: 16,
                          ),
                        ),
                        title: Text(
                          question,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: isCurrentEditingItem
                                ? WebsiteColors.primaryBlueColor
                                : WebsiteColors.darkGreyColor,
                          ),
                          maxLines: 2, // Limit to two lines
                          overflow: TextOverflow.ellipsis, // Add ellipsis for text overflow
                        ),
                          trailing: Container(
                            width: 24, // Fixed width for consistent alignment
                            alignment: Alignment.center, // Center alignment
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: WebsiteColors.primaryBlueColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Answer:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: WebsiteColors.primaryBlueColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  answer,
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: WebsiteColors.darkGreyColor,
                                  ),
                                  // Allow text to wrap properly
                                  softWrap: true,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        color: WebsiteColors.primaryBlueColor,
                                        size: 18,
                                      ),
                                      tooltip: "Edit",
                                      onPressed: () => editFAQItem(docId, question, answer),
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: WebsiteColors.redColor,
                                        size: 18,
                                      ),
                                      tooltip: "Delete",
                                      onPressed: () => deleteFAQItem(docId),
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}