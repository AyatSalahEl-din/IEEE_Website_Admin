import 'dart:io' show File;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:path/path.dart' as path;

import '../models/project_model.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collectionPath = 'projects';

  ProjectService() {
    // Set custom retry time for Firebase Storage
    _storage.setMaxUploadRetryTime(const Duration(minutes: 10));
  }

  Stream<List<Project>> getProjects() {
    return _firestore
        .collection(_collectionPath)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          debugPrint('Fetched ${snapshot.docs.length} projects'); // Debug log
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Project.fromFirestore(data, doc.id);
          }).toList();
        })
        .handleError((error) {
          debugPrint('Error fetching projects: $error'); // Debug log
        });
  }

  Future<Project?> getProjectById(String projectId) async {
    try {
      final doc =
          await _firestore.collection(_collectionPath).doc(projectId).get();
      if (doc.exists) {
        debugPrint('Fetched project: ${doc.id}'); // Debug log
        return Project.fromFirestore(doc.data()!, doc.id);
      } else {
        debugPrint('Project not found: $projectId'); // Debug log
      }
    } catch (e) {
      debugPrint('Error fetching project by ID: $e'); // Debug log
    }
    return null;
  }

  Future<void> addProject(
    Project project,
    Uint8List? imageBytes,
    String imageName,
  ) async {
    String imageUrl = '';
    if (imageBytes != null) {
      try {
        // Check file size (Firebase Storage has a 5MB limit for free tier)
        if (imageBytes.length > 5 * 1024 * 1024) {
          throw Exception('File size exceeds the 5MB limit.');
        }

        // Sanitize the filename to remove special characters
        final sanitizedImageName = imageName.replaceAll(
          RegExp(r'[^\w\-.]'),
          '_',
        );
        final storageRef = _storage.ref().child('projects/$sanitizedImageName');
        debugPrint('Starting image upload: $sanitizedImageName'); // Debug log

        // Start the upload task
        final uploadTask = storageRef.putData(imageBytes);

        // Monitor the upload progress
        uploadTask.snapshotEvents.listen((event) {
          final progress = (event.bytesTransferred / event.totalBytes) * 100;
          debugPrint('Upload progress: ${progress.toStringAsFixed(2)}%');
        });

        // Await the upload task completion
        final snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
        debugPrint('Image uploaded successfully: $imageUrl'); // Debug log
      } catch (e) {
        debugPrint('Error uploading image: $e'); // Debug log
        rethrow;
      }
    }
    try {
      // Ensure Firestore collection reference is correct
      final collectionRef = _firestore.collection(_collectionPath);
      await collectionRef.add({...project.toFirestore(), 'imageUrl': imageUrl});
      debugPrint('Project added with image URL: $imageUrl'); // Debug log
    } catch (e) {
      debugPrint('Error adding project to Firestore: $e'); // Debug log
      rethrow;
    }
  }

  Future<void> updateProject(
    Project project,
    Uint8List? imageFile,
    String? imageName,
  ) async {
    String? imageUrl = project.imageUrl;
    if (imageFile != null && imageName != null) {
      imageUrl = await _uploadImage(imageFile, imageName);
    }
    try {
      await _firestore.collection(_collectionPath).doc(project.id).update({
        ...project.toFirestore(),
        'imageUrl': imageUrl,
      });
    } catch (e) {
      debugPrint('Error updating project: $e'); // Debug log
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    final project = await getProjectById(projectId);
    if (project != null && project.imageUrl!.isNotEmpty) {
      try {
        if (project.imageUrl != null) {
          await _storage.refFromURL(project.imageUrl!).delete();
        }
      } catch (e) {
        debugPrint('Error deleting image: $e'); // Debug log
      }
    }
    try {
      await _firestore.collection(_collectionPath).doc(projectId).delete();
    } catch (e) {
      debugPrint('Error deleting project: $e'); // Debug log
      rethrow;
    }
  }

  Future<String> _uploadImage(Uint8List imageFile, String imageName) async {
    try {
      final storageRef = _storage.ref().child('project_images/$imageName');
      final uploadTask = storageRef.putData(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e'); // Debug log
      rethrow;
    }
  }

  Future<String?> uploadProjectImage({
    required Uint8List imageBytes,
    required String imageName,
  }) async {
    try {
      // Sanitize the filename to remove special characters
      final sanitizedImageName =
          imageName
              .replaceAll(
                RegExp(r'[^\w\-.]'),
                '_',
              ) // Replace special characters
              .replaceAll(RegExp(r'_+'), '_') // Remove consecutive underscores
              .trim(); // Trim leading/trailing underscores

      debugPrint('Sanitized image name: $sanitizedImageName'); // Debug log

      final storageRef = _storage.ref().child(
        'project_images/$sanitizedImageName',
      );

      // Compress image if not on web
      Uint8List? compressedBytes = imageBytes;
      if (!kIsWeb) {
        compressedBytes = await _compressImage(imageBytes);
      }

      // Start the upload task
      final uploadTask = storageRef.putData(compressedBytes!);

      // Monitor the upload progress
      uploadTask.snapshotEvents.listen((event) {
        final progress = (event.bytesTransferred / event.totalBytes) * 100;
        debugPrint('Upload progress: ${progress.toStringAsFixed(2)}%');
        if (event.state == TaskState.running) {
          debugPrint('Upload is running...');
        } else if (event.state == TaskState.success) {
          debugPrint('Upload completed successfully.');
        } else if (event.state == TaskState.error) {
          debugPrint('Upload encountered an error.');
        }
      });

      // Await the upload task completion
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Image uploaded successfully: $downloadUrl'); // Debug log
      return downloadUrl;
    } catch (e) {
      debugPrint('Upload error: $e'); // Debug log
      return null;
    }
  }

  Future<Uint8List?> _compressImage(Uint8List imageBytes) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: 70, // Adjust quality as needed
        minWidth: 1024,
        minHeight: 1024,
      );
      return Uint8List.fromList(result);
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  Future<String?> uploadLargeFile(File file) async {
    if (await file.length() > 5 * 1024 * 1024) {
      return await _uploadInChunks(file);
    }
    return await uploadProjectImage(
      imageBytes: await file.readAsBytes(),
      imageName: path.basename(file.path),
    );
  }

  Future<String?> _uploadInChunks(File file) async {
    final storageRef = _storage.ref().child(
      'project_images/large_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final uploadTask = storageRef.putFile(
      file,
      SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'chunked': 'true'},
      ),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<String?> uploadWithRetry({
    required Uint8List imageBytes,
    required String imageName,
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        return await uploadProjectImage(
          imageBytes: imageBytes,
          imageName: imageName,
        );
      } catch (e) {
        attempt++;
        if (attempt == maxRetries) rethrow;
        debugPrint('Retrying upload... Attempt $attempt'); // Debug log
        await Future.delayed(
          Duration(seconds: 2 * attempt),
        ); // Exponential backoff
      }
    }
    return null;
  }

  Future<String?> uploadImageWithRetry({
    required Uint8List imageBytes,
    required String imageName,
    int maxRetries = 3,
    int timeoutSeconds = 60,
  }) async {
    int attempt = 0;
    late UploadTask uploadTask;

    // Compress image before upload
    final compressedBytes = await _compressImage(imageBytes);

    while (attempt < maxRetries) {
      try {
        final sanitizedImageName = imageName.replaceAll(
          RegExp(r'[^\w\-.]'),
          '_',
        );
        final storageRef = _storage.ref().child(
          'project_images/$sanitizedImageName',
        );

        uploadTask = storageRef.putData(
          compressedBytes!,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        // Monitor upload progress
        uploadTask.snapshotEvents.listen((event) {
          final progress = (event.bytesTransferred / event.totalBytes) * 100;
          debugPrint('Upload progress: ${progress.toStringAsFixed(2)}%');
        });

        // Complete upload with timeout
        final snapshot = await uploadTask.timeout(
          Duration(seconds: timeoutSeconds),
          onTimeout: () {
            uploadTask.cancel();
            throw Exception('Upload timed out after $timeoutSeconds seconds');
          },
        );

        return await snapshot.ref.getDownloadURL();
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          debugPrint('Upload failed after $maxRetries attempts: $e');
          rethrow;
        }
        debugPrint('Retrying upload (attempt $attempt)...');
        await Future.delayed(
          Duration(seconds: attempt * 2),
        ); // Exponential backoff
      }
    }
    return null;
  }

  Future<bool> hasGoodConnection() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return false;

    try {
      final stopwatch = Stopwatch()..start();
      await _storage.ref('test').getMetadata();
      return stopwatch.elapsedMilliseconds < 3000; // 3-second threshold
    } catch (_) {
      return false;
    }
  }
}
