import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference membersCollection = FirebaseFirestore.instance
      .collection('Members');

  // Add a new member
  Future<void> addMember(
    String name,
    String position,
    String number,
    String pic,
  ) {
    return membersCollection.add({
      'name': name,
      'position': position,
      'number': number,
      'pic': pic,
    });
  }

  // Edit existing member
  Future<void> updateMember(
    String memberId,
    String name,
    String position,
    String number,
    String pic,
  ) {
    return membersCollection.doc(memberId).update({
      'name': name,
      'position': position,
      'number': number,
      'pic': pic,
    });
  }

  // Delete a member
  Future<void> deleteMember(String memberId) {
    return membersCollection.doc(memberId).delete();
  }
}
