import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devsync/core/services/firebase/firebase_constants.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // 1. Create or update a document
  Future<void> setDocument({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection(collectionPath)
        .doc(docId)
        .set(data, SetOptions(merge: true));
  }

  // 2. Get a document
  Future<Map<String, dynamic>?> getDocument({
    required String collectionPath,
    required String docId,
  }) async {
    final snapshot = await _firestore
        .collection(collectionPath)
        .doc(docId)
        .get();

    return snapshot.data();
  }

  // 3. Update an existing document
  Future<void> updateDocument({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection(collectionPath)
        .doc(docId)
        .update(data);
  }

  // 4. Create or replace a project
  Future<void> addProject({
    required String projectId,
    required Map<String, dynamic> projectData,
  }) async {
    await _firestore
        .collection(FirebaseConstants.projectsCollection)
        .doc(projectId)
        .set(projectData);
  }

  // 5. Get all projects
  Future<List<Map<String, dynamic>>> getProjects() async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.projectsCollection)
        .get();

    return snapshot.docs.map((doc) {
      return {
        ...doc.data(),
        'id': doc.id,
      };
    }).toList();
  }
}