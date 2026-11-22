import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_app/core/error/failures.dart';
import 'package:movies_app/features/movies/domain/entities/movie.dart';
import 'package:movies_app/features/movies/domain/repositories/movies_repository.dart';
import 'package:movies_app/features/movies/presentation/cubit/movie_list_cubit.dart';

class _FakeRepository implements MoviesRepository {
  @override
  Future<Either<Failure, MoviesPage>> list(MovieQuery query) async {
    return right(MoviesPage(
      movies: [
        Movie(
          id: query.page,
          title: 'Test movie ${query.page}',
          year: 2024,
          rating: 7,
          runtime: 90,
          genres: const ['Action'],
          smallCover: '',
          mediumCover: '',
          largeCover: '',
          backgroundImage: '',
        ),
      ],
      totalCount: 2,
      page: query.page,
      limit: 1,
    ));
  }

  @override
  Future<Either<Failure, Movie>> details(int movieId) async =>
      left(const ApiFailure('Not needed for list test'));

  @override
  Future<Either<Failure, List<Movie>>> suggestions(int movieId) async =>
      right(const []);
}

void main() {
  test('MovieListCubit loads and appends without duplicate data', () async {
    final cubit = MovieListCubit(_FakeRepository());
    await cubit.load(const MovieQuery(limit: 1));
    expect(cubit.state.items.map((e) => e.id), [1]);
    expect(cubit.state.hasMore, isTrue);
    await cubit.nextPage();
    expect(cubit.state.items.map((e) => e.id), [1, 2]);
    expect(cubit.state.hasMore, isFalse);
    await cubit.close();
  });
}
