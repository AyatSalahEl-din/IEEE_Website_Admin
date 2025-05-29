import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/faq_model.dart';

class FAQRepository {
  final CollectionReference _faqCollection =
  FirebaseFirestore.instance.collection('faq');

  Stream<List<FAQModel>> getFAQList() {
    return _faqCollection
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FAQModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList());
  }

  Future<void> addFAQ(FAQModel faq) async {
    await _faqCollection.add(faq.toMap());
  }

  Future<void> updateFAQ(FAQModel faq) async {
    await _faqCollection.doc(faq.id).update(faq.toMap());
  }

  Future<void> deleteFAQ(String id) async {
    await _faqCollection.doc(id).delete();
  }

  Future<void> reorderFAQ(List<FAQModel> faqs) async {
    final batch = FirebaseFirestore.instance.batch();

    for (final faq in faqs) {
      batch.update(_faqCollection.doc(faq.id), {
        'order': faq.order,
      });
    }

    await batch.commit();
  }
}