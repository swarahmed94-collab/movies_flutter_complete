import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

/// Firestore schema and collection path are owned by the app product contract.
/// This contract intentionally does not assume movie wishlist/history fields.
abstract class UserDocumentRepository {
  Stream<Either<Failure, Map<String, dynamic>?>> watch(String uid);
  Future<Either<Failure, Map<String, dynamic>?>> read(String uid);
  Future<Either<Failure, Unit>> merge(String uid, Map<String, dynamic> fields);
  Future<Either<Failure, Unit>> delete(String uid);
}
