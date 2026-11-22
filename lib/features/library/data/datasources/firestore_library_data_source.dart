import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../movies/data/models/movie_model.dart';
import '../../../movies/domain/entities/movie.dart';

class FirestoreLibraryDataSource {
  const FirestoreLibraryDataSource(this._firestore);
  final FirebaseFirestore _firestore;
  CollectionReference<Map<String,dynamic>> _collection(String uid,String name) {
    if (uid.isEmpty || uid.contains('/')) throw ArgumentError('Invalid user identifier');
    return _firestore.collection('users').doc(uid).collection(name);
  }
  Stream<List<Movie>> watchList(String uid,String name) =>
    _collection(uid,name).orderBy('savedAt',descending:true).snapshots().map(
      (snap)=>snap.docs.map((doc)=>MovieModel.fromJson(doc.data()).entity)
          .where((movie)=>movie.id>0).toList(growable:false));

  Future<void> save(String uid,String name,Movie movie) async {
    if (movie.id <= 0) throw ArgumentError('Invalid movie id');
    await _collection(uid,name).doc('${movie.id}').set({
      ...MovieModel(movie).toSnapshot(),
      'savedAt': FieldValue.serverTimestamp(),
    });
  }
  Future<void> remove(String uid,String name,int id) =>
      _collection(uid,name).doc('$id').delete();

  Future<void> deleteAll(String uid) async {
    for (final collection in ['watchlist','history']) {
      while (true) {
        final batchDocs=await _collection(uid,collection).limit(300).get();
        if (batchDocs.docs.isEmpty) break;
        final batch=_firestore.batch();
        for (final doc in batchDocs.docs) { batch.delete(doc.reference); }
        await batch.commit();
      }
    }
    await _firestore.collection('users').doc(uid).delete();
  }
}
