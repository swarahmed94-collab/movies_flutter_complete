import 'package:cloud_firestore/cloud_firestore.dart';

/// Generic Firestore user document operations. No invented document schema.
class FirestoreUserDocumentDataSource {
  FirestoreUserDocumentDataSource(this._firestore, this.collectionName) {
    if (collectionName.trim().isEmpty || collectionName.contains('/')) {
      throw ArgumentError.value(
        collectionName,
        'collectionName',
        'Supply a single Firestore collection ID.',
      );
    }
  }

  final FirebaseFirestore _firestore;
  final String collectionName;
  DocumentReference<Map<String, dynamic>> _doc(String uid) {
    if (uid.isEmpty || uid.contains('/')) {
      throw ArgumentError.value(uid, 'uid', 'Invalid document ID.');
    }
    return _firestore.collection(collectionName).doc(uid);
  }

  Stream<Map<String, dynamic>?> watch(String uid) =>
      _doc(uid).snapshots().map((snapshot) => snapshot.data());

  Future<Map<String, dynamic>?> read(String uid) async =>
      (await _doc(uid).get()).data();

  Future<void> merge(String uid, Map<String, dynamic> fields) =>
      _doc(uid).set(fields, SetOptions(merge: true));

  Future<void> delete(String uid) => _doc(uid).delete();
}
