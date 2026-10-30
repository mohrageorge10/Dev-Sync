import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ================= Firebase Instance =================

  FirebaseFirestore get instance => _firestore;

  // ================= References =================

  CollectionReference<Map<String, dynamic>> collectionReference(
    String collectionPath,
  ) {
    return _firestore.collection(collectionPath);
  }

  DocumentReference<Map<String, dynamic>> documentReference({
    required String collectionPath,
    required String docId,
  }) {
    return _firestore
        .collection(collectionPath)
        .doc(docId);
  }

  // ================= Create Document =================

  Future<void> setDocument({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    await documentReference(
      collectionPath: collectionPath,
      docId: docId,
    ).set(
      data,
      SetOptions(merge: merge),
    );
  }

  Future<String> addDocument({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    final DocumentReference<Map<String, dynamic>> reference =
        await _firestore
            .collection(collectionPath)
            .add(data);

    return reference.id;
  }

  // ================= Read Document =================

  Future<Map<String, dynamic>?> getDocument({
    required String collectionPath,
    required String docId,
  }) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await documentReference(
      collectionPath: collectionPath,
      docId: docId,
    ).get();

    final Map<String, dynamic>? data = snapshot.data();

    if (!snapshot.exists || data == null) return null;

    return {
      ...data,
      'id': snapshot.id,
    };
  }

  // ================= Update Document =================

  Future<void> updateDocument({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await documentReference(
      collectionPath: collectionPath,
      docId: docId,
    ).update(data);
  }

  // ================= Delete Document =================

  Future<void> deleteDocument({
    required String collectionPath,
    required String docId,
  }) async {
    await documentReference(
      collectionPath: collectionPath,
      docId: docId,
    ).delete();
  }

  // ================= Read Collection =================

  Future<List<Map<String, dynamic>>> getCollection({
    required String collectionPath,
    Query<Map<String, dynamic>> Function(
      Query<Map<String, dynamic>> query,
    )? queryBuilder,
  }) async {
    Query<Map<String, dynamic>> query =
        _firestore.collection(collectionPath);

    if (queryBuilder != null) {
      query = queryBuilder(query);
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await query.get();

    return snapshot.docs.map((doc) {
      return {
        ...doc.data(),
        'id': doc.id,
      };
    }).toList();
  }

  // ================= Document Stream =================

  Stream<Map<String, dynamic>?> documentStream({
    required String collectionPath,
    required String docId,
  }) {
    return documentReference(
      collectionPath: collectionPath,
      docId: docId,
    ).snapshots().map((snapshot) {
      final Map<String, dynamic>? data = snapshot.data();

      if (!snapshot.exists || data == null) return null;

      return {
        ...data,
        'id': snapshot.id,
      };
    });
  }

  // ================= Collection Stream =================

  Stream<List<Map<String, dynamic>>> collectionStream({
    required String collectionPath,
    Query<Map<String, dynamic>> Function(
      Query<Map<String, dynamic>> query,
    )? queryBuilder,
  }) {
    Query<Map<String, dynamic>> query =
        _firestore.collection(collectionPath);

    if (queryBuilder != null) {
      query = queryBuilder(query);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          ...doc.data(),
          'id': doc.id,
        };
      }).toList();
    });
  }

  // ================= Batch Operations =================

  Future<void> runBatch(
    void Function(WriteBatch batch) operations,
  ) async {
    final WriteBatch batch = _firestore.batch();

    operations(batch);

    await batch.commit();
  }

  // ================= Transaction Operations =================

  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) action, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) {
    return _firestore.runTransaction<T>(
      action,
      timeout: timeout,
      maxAttempts: maxAttempts,
    );
  }

  // ================= Field Operations =================

  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  FieldValue increment(num value) => FieldValue.increment(value);

  FieldValue arrayUnion(List<dynamic> elements) =>
      FieldValue.arrayUnion(elements);

  FieldValue arrayRemove(List<dynamic> elements) =>
      FieldValue.arrayRemove(elements);

  FieldValue get deleteField => FieldValue.delete();
}