import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/project_model.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'projects';

  Stream<List<Project>> getProjects() {
    return _firestore
        .collection(_collectionPath)
        .orderBy('date', descending: true) // Order by 'date'
        .snapshots()
        .map((snapshot) {
          debugPrint('Fetched ${snapshot.docs.length} projects from Firebase');
          return snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  return Project.fromFirestore(data, doc.id); // Include 'id'
                } catch (e) {
                  debugPrint('Error parsing project document: ${doc.id}, $e');
                  return null; // Skip invalid documents
                }
              })
              .whereType<Project>()
              .toList();
        })
        .handleError((error) {
          debugPrint('Error fetching projects: $error');
        });
  }

  Future<Project?> getProjectById(String projectId) async {
    try {
      final doc =
          await _firestore.collection(_collectionPath).doc(projectId).get();
      if (doc.exists) {
        debugPrint('Fetched project by ID: ${doc.id}'); // Debug log
        return Project.fromFirestore(doc.data()!, doc.id);
      } else {
        debugPrint('Project not found with ID: $projectId'); // Debug log
      }
    } catch (e) {
      debugPrint('Error fetching project by ID: $e'); // Debug log
    }
    return null;
  }

  Future<void> addProject(Project project) async {
    try {
      await _firestore.collection(_collectionPath).add(project.toFirestore());
      debugPrint('Project added successfully');
    } catch (e) {
      debugPrint('Error adding project to Firestore: $e');
      rethrow;
    }
  }

  Future<void> updateProject(
    Project project,
    Map<String, dynamic>? originalAdditionalDetails,
  ) async {
    try {
      final updates = project.toFirestore();

      // Handle removal of keys from additionalDetails
      if (originalAdditionalDetails != null) {
        final removedKeys =
            originalAdditionalDetails.keys
                .where(
                  (key) =>
                      !(project.additionalDetails?.containsKey(key) ?? false),
                )
                .toList();

        for (final key in removedKeys) {
          updates['additionalDetails.$key'] = FieldValue.delete();
        }
      }

      await _firestore
          .collection(_collectionPath)
          .doc(project.id)
          .update(updates);
      debugPrint('Project updated successfully');
    } catch (e) {
      debugPrint('Error updating project: $e');
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _firestore.collection(_collectionPath).doc(projectId).delete();
      debugPrint('Project deleted successfully');
    } catch (e) {
      debugPrint('Error deleting project: $e');
      rethrow;
    }
  }
}
