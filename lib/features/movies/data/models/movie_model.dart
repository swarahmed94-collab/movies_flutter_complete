import '../../domain/entities/movie.dart';

abstract final class JsonValue {
  static String string(Object? value) => value is String ? value : '';
  static int integer(Object? value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  static double number(Object? value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
  static Map<String,dynamic> object(Object? value) => value is Map ? Map<String,dynamic>.from(value) : <String,dynamic>{};
  static List<dynamic> list(Object? value) => value is List ? value : <dynamic>[];
}

class MovieModel {
  const MovieModel(this.entity);
  final Movie entity;

  factory MovieModel.fromJson(Map<String,dynamic> json) {
    final cast = JsonValue.list(json['cast']).map((e) {
      final value=JsonValue.object(e);
      return MovieActor(
        name: JsonValue.string(value['name']),
        characterName: JsonValue.string(value['character_name']),
        imageUrl: JsonValue.string(value['url_small_image']),
      );
    }).where((actor) => actor.name.isNotEmpty).toList(growable:false);
    final screenshots = <String>[
      for (final key in <String>['medium_screenshot_image1','medium_screenshot_image2','medium_screenshot_image3'])
        if (JsonValue.string(json[key]).isNotEmpty) JsonValue.string(json[key]),
    ];
    return MovieModel(Movie(
      id: JsonValue.integer(json['id']),
      title: JsonValue.string(json['title_english']).isNotEmpty
          ? JsonValue.string(json['title_english']) : JsonValue.string(json['title']),
      year: JsonValue.integer(json['year']),
      rating: JsonValue.number(json['rating']),
      runtime: JsonValue.integer(json['runtime']),
      genres: JsonValue.list(json['genres']).whereType<String>().toList(growable:false),
      smallCover: JsonValue.string(json['small_cover_image']),
      mediumCover: JsonValue.string(json['medium_cover_image']),
      largeCover: JsonValue.string(json['large_cover_image']),
      backgroundImage: JsonValue.string(json['background_image_original']).isNotEmpty
          ? JsonValue.string(json['background_image_original'])
          : JsonValue.string(json['background_image']),
      summary: JsonValue.string(json['summary']),
      description: JsonValue.string(json['description_full']).isNotEmpty
          ? JsonValue.string(json['description_full']) : JsonValue.string(json['summary']),
      trailerCode: JsonValue.string(json['yt_trailer_code']),
      likeCount: JsonValue.integer(json['like_count']),
      screenshots: screenshots,
      cast: cast,
    ));
  }

  Map<String,dynamic> toSnapshot() => {
    'id': entity.id,
    'title': entity.title,
    'year': entity.year,
    'rating': entity.rating,
    'runtime': entity.runtime,
    'genres': entity.genres,
    'small_cover_image': entity.smallCover,
    'medium_cover_image': entity.mediumCover,
    'large_cover_image': entity.largeCover,
    'background_image': entity.backgroundImage,
    'summary': entity.summary,
    'description_full': entity.description,
    'yt_trailer_code': entity.trailerCode,
    'like_count': entity.likeCount,
    'cast': [for (final actor in entity.cast) {'name':actor.name,
      'character_name':actor.characterName,'url_small_image':actor.imageUrl}],
  };
}
