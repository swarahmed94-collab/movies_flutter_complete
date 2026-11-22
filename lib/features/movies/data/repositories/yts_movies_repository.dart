import 'package:dartz/dartz.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movies_repository.dart';
import '../datasources/yts_movies_remote_data_source.dart';

class YtsMoviesRepository implements MoviesRepository {
  const YtsMoviesRepository(this._source);
  final YtsMoviesRemoteDataSource _source;
  @override
  Future<Either<Failure,MoviesPage>> list(MovieQuery q) async {
    try { return right(await _source.list(q)); }
    catch (e) { return left(FailureMapper.from(e)); }
  }
  @override
  Future<Either<Failure,Movie>> details(int id) async {
    try { return right(await _source.details(id)); }
    catch (e) { return left(FailureMapper.from(e)); }
  }
  @override
  Future<Either<Failure,List<Movie>>> suggestions(int id) async {
    try { return right(await _source.suggestions(id)); }
    catch (e) { return left(FailureMapper.from(e)); }
  }
}
