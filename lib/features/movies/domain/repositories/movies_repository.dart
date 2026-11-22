import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/movie.dart';

abstract class MoviesRepository {
  Future<Either<Failure,MoviesPage>> list(MovieQuery query);
  Future<Either<Failure,Movie>> details(int movieId);
  Future<Either<Failure,List<Movie>>> suggestions(int movieId);
}
