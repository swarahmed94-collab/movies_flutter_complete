import 'package:flutter_test/flutter_test.dart';
import 'package:movies_app/features/movies/data/models/movie_model.dart';

void main() {
  test('Parses documented YTS movie fields and optional cast/screen shots', () {
    final movie = MovieModel.fromJson({
      'id': 123,
      'title_english': 'A Film',
      'title': 'Original Title',
      'year': 2024,
      'rating': 7.6,
      'runtime': 90,
      'genres': ['Action', 'Sci-Fi'],
      'small_cover_image': 'https://example.com/small.jpg',
      'medium_cover_image': 'https://example.com/medium.jpg',
      'large_cover_image': 'https://example.com/large.jpg',
      'background_image_original': 'https://example.com/back.jpg',
      'description_full': 'Story summary',
      'yt_trailer_code': 'abcd123',
      'like_count': 15,
      'medium_screenshot_image1': 'https://example.com/screen1.jpg',
      'cast': [
        {
          'name': 'Performer',
          'character_name': 'Hero',
          'url_small_image': 'https://example.com/actor.jpg',
        },
      ],
    }).entity;
    expect(movie.id, 123);
    expect(movie.title, 'A Film');
    expect(movie.genres, ['Action', 'Sci-Fi']);
    expect(movie.screenshots, ['https://example.com/screen1.jpg']);
    expect(movie.cast.single.characterName, 'Hero');
    expect(MovieModel(movie).toSnapshot()['id'], 123);
  });

  test('Handles missing optional fields without inventing movie data', () {
    final movie = MovieModel.fromJson({'id': 3, 'title': 'Minimal'}).entity;
    expect(movie.title, 'Minimal');
    expect(movie.screenshots, isEmpty);
    expect(movie.cast, isEmpty);
    expect(movie.rating, 0);
  });
}
