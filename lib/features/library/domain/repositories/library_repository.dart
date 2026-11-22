import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../movies/domain/entities/movie.dart';
abstract class LibraryRepository {
  Stream<Either<Failure,List<Movie>>> watchWatchlist(String uid);
  Stream<Either<Failure,List<Movie>>> watchHistory(String uid);
  Future<Either<Failure,Unit>> setWatchlisted(String uid, Movie movie, bool isSaved);
  Future<Either<Failure,Unit>> addHistory(String uid, Movie movie);
  Future<Either<Failure,Unit>> clearUserData(String uid);
}
