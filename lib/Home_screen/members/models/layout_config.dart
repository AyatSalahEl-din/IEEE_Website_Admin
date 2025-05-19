import 'package:cloud_firestore/cloud_firestore.dart';

class LayoutConfig {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final _docRef = _firestore
      .collection('teamLayoutConfig')
      .doc('rowSizes');

  /// Fetch row sizes from Firestore (fallback to default if not found)
  static Future<List<int>> fetchRowSizes() async {
    try {
      DocumentSnapshot doc = await _docRef.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        List<dynamic> sizes = data['sizes'] ?? [];
        return sizes.map((e) => (e as num).toInt()).toList();
      }
    } catch (e) {
      print('Error fetching rowSizes: $e');
    }

    return [2, 2, 3, 4, 4, 4, 4]; // default fallback
  }

  /// Save row sizes list to Firestore
  static Future<void> saveRowSizes(List<int> sizes) async {
    try {
      await _docRef.set({'sizes': sizes});
    } catch (e) {
      print('Error saving rowSizes: $e');
      rethrow;
    }
  }
}
