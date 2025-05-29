import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ieee_website/Themes/website_colors.dart';
import 'package:ieee_website/FAQ/widgets/faq_form.dart';
import 'package:ieee_website/FAQ/widgets/faq_list.dart';

class FAQ extends StatefulWidget {
  static const String routeName = 'faq';
  final TabController? tabController;
  const FAQ({Key? key, this.tabController}) : super(key: key);

  @override
  State<FAQ> createState() => _FAQState();
}

class _FAQState extends State<FAQ> {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController answerController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
        await FirebaseFirestore.instance
            .collection('faq')
            .doc(currentDocId)
            .update({
              'question': question,
              'answer': answer,
              'updatedAt': FieldValue.serverTimestamp(),
            });
        isEditing = false;
        currentDocId = '';
      } else {
        QuerySnapshot snapshot =
            await FirebaseFirestore.instance
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
        isEditing
            ? 'Question updated successfully'
            : 'Question added successfully',
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
                overflow: TextOverflow.ellipsis,
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
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> deleteFAQItem(String docId) async {
    bool confirm =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: WebsiteColors.primaryYellowColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        "Confirm Delete",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                content: const Text(
                  "Are you sure you want to delete this question? This action cannot be undone.",
                  style: TextStyle(fontSize: 14),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text("Delete", style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
        ) ??
        false;

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
        _showSnackBar(
          'Question deleted successfully',
          Icons.check_circle_outline,
          WebsiteColors.primaryBlueColor,
        );
      } catch (e) {
        _showSnackBar(
          'Error deleting question: ${e.toString()}',
          Icons.error_outline,
          WebsiteColors.redColor,
        );
      }
    }
  }

  Future<void> reorderFAQ(
    int oldIndex,
    int newIndex,
    List<QueryDocumentSnapshot> docs,
  ) async {
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
      _showSnackBar(
        'FAQ order updated',
        Icons.check_circle_outline,
        WebsiteColors.primaryBlueColor,
      );
    } catch (e) {
      _showSnackBar(
        'Error reordering questions: ${e.toString()}',
        Icons.error_outline,
        WebsiteColors.redColor,
      );
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
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 16,
          vertical: 8,
        ),
        child:
            isSmallScreen
                ? SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      FAQForm(
                        formKey: _formKey,
                        questionController: questionController,
                        answerController: answerController,
                        isEditing: isEditing,
                        currentDocId: currentDocId,
                        onAddOrUpdate: addOrUpdateFAQItem,
                        onCancel: () {
                          setState(() {
                            questionController.clear();
                            answerController.clear();
                            isEditing = false;
                            currentDocId = '';
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      FAQList(
                        isSmallScreen: true,
                        currentDocId: currentDocId,
                        onEdit: editFAQItem,
                        onDelete: deleteFAQItem,
                        onReorder: reorderFAQ,
                      ),
                    ],
                  ),
                )
                : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: FAQList(
                        isSmallScreen: false,
                        currentDocId: currentDocId,
                        onEdit: editFAQItem,
                        onDelete: deleteFAQItem,
                        onReorder: reorderFAQ,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 4,
                      child: SingleChildScrollView(
                        child: FAQForm(
                          formKey: _formKey,
                          questionController: questionController,
                          answerController: answerController,
                          isEditing: isEditing,
                          currentDocId: currentDocId,
                          onAddOrUpdate: addOrUpdateFAQItem,
                          onCancel: () {
                            setState(() {
                              questionController.clear();
                              answerController.clear();
                              isEditing = false;
                              currentDocId = '';
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
