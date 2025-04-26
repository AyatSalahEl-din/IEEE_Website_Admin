import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  Future<void> addFAQItem() async {
    final String question = questionController.text.trim();
    final String answer = answerController.text.trim();

    if (question.isNotEmpty && answer.isNotEmpty) {
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
      });

      questionController.clear();
      answerController.clear();
      setState(() {});
    }
  }

  Future<void> deleteFAQItem(String docId) async {
    await FirebaseFirestore.instance.collection('faq').doc(docId).delete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FAQ Admin Panel")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Add New FAQ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(
              controller: questionController,
              decoration: const InputDecoration(labelText: "Question"),
            ),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(labelText: "Answer"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: addFAQItem,
              child: const Text("Add FAQ"),
            ),
            const Divider(height: 32),
            const Text("Existing FAQs", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('faq').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Text('Error loading FAQs');
                  if (!snapshot.hasData) return const CircularProgressIndicator();

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final docId = docs[index].id;

                      return ListTile(
                        title: Text(data['question'] ?? ''),
                        subtitle: Text(data['answer'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteFAQItem(docId),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

