import 'package:flutter_test/flutter_test.dart';
import 'package:movies_app/features/movies/domain/entities/movie.dart';

void main() {
  test('Movie entity preserves YTS trailer code', () {
    const movie = Movie(
      id: 25,
      title: 'Sample Movie',
      year: 2024,
      rating: 7.0,
      runtime: 120,
      genres: ['Drama'],
      smallCover: '',
      mediumCover: '',
      largeCover: '',
      backgroundImage: '',
      trailerCode: 'dQw4w9WgXcQ',
    );

    expect(movie.title, 'Sample Movie');
    expect(movie.trailerCode, 'dQw4w9WgXcQ');
  });
}
