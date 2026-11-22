import 'package:dartz/dartz.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/user_document_repository.dart';
import '../datasources/firestore_user_document_data_source.dart';

class FirestoreUserDocumentRepository implements UserDocumentRepository {
  FirestoreUserDocumentRepository(this._source);
  final FirestoreUserDocumentDataSource _source;

  @override
  Stream<Either<Failure, Map<String, dynamic>?>> watch(String uid) async* {
    try {
      await for (final data in _source.watch(uid)) {
        yield right(data);
      }
    } catch (error) {
      yield left(FailureMapper.from(error));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> read(String uid) async {
    try {
      return right(await _source.read(uid));
    } catch (error) {
      return left(FailureMapper.from(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> merge(
    String uid,
    Map<String, dynamic> fields,
  ) async {
    try {
      await _source.merge(uid, fields);
      return right(unit);
    } catch (error) {
      return left(FailureMapper.from(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String uid) async {
    try {
      await _source.delete(uid);
      return right(unit);
    } catch (error) {
      return left(FailureMapper.from(error));
    }
  }
}
