import 'package:dartz/dartz.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../movies/domain/entities/movie.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/firestore_library_data_source.dart';

class FirestoreLibraryRepository implements LibraryRepository {
  const FirestoreLibraryRepository(this._source);
  final FirestoreLibraryDataSource _source;
  Stream<Either<Failure,List<Movie>>> _watch(String uid,String coll) async* {
    try {
      await for (final items in _source.watchList(uid,coll)) { yield right(items); }
    } catch (e) { yield left(FailureMapper.from(e)); }
  }
  @override
  Stream<Either<Failure,List<Movie>>> watchWatchlist(String uid) => _watch(uid,'watchlist');
  @override
  Stream<Either<Failure,List<Movie>>> watchHistory(String uid) => _watch(uid,'history');
  @override
  Future<Either<Failure,Unit>> setWatchlisted(String uid,Movie movie,bool saved) async {
    try {
      if (saved) { await _source.save(uid,'watchlist',movie); }
      else { await _source.remove(uid,'watchlist',movie.id); }
      return right(unit);
    } catch (e) { return left(FailureMapper.from(e)); }
  }
  @override
  Future<Either<Failure,Unit>> addHistory(String uid,Movie movie) async {
    try { await _source.save(uid,'history',movie);return right(unit); }
    catch (e) { return left(FailureMapper.from(e)); }
  }
  @override
  Future<Either<Failure,Unit>> clearUserData(String uid) async {
    try { await _source.deleteAll(uid);return right(unit); }
    catch (e) { return left(FailureMapper.from(e)); }
  }
}
