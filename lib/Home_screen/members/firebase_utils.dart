import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

String hashPassword(String password) {
  return sha256.convert(utf8.encode(password)).toString();
}

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

Future<void> approveNewAdmin(
  String email,
  String password,
  String name,
  String phone,
) async {
  try {
    // Save user data to `adminUsers` collection (without Firebase Auth)
    await FirebaseFirestore.instance.collection('adminUsers').doc(email).set({
      'name': name,
      'email': email,
      'phone': phone,
      'password': hashPassword(password), // Store hashed password
      'approvedAt': FieldValue.serverTimestamp(),
    });

    // Remove from `pendingAdmins` collection
    await FirebaseFirestore.instance
        .collection('pendingAdmins')
        .doc(email)
        .delete();

    print("Admin approved and added to adminUsers collection.");
  } catch (e) {
    print('Error approving admin: $e');
  }
}
