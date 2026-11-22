import 'package:equatable/equatable.dart';

class MovieActor extends Equatable {
  const MovieActor({required this.name, this.characterName = '', this.imageUrl = ''});
  final String name;
  final String characterName;
  final String imageUrl;
  @override
  List<Object?> get props => [name, characterName, imageUrl];
}

class Movie extends Equatable {
  const Movie({
    required this.id, required this.title, required this.year,
    required this.rating, required this.runtime, required this.genres,
    required this.smallCover, required this.mediumCover,
    required this.largeCover, required this.backgroundImage,
    this.summary = '', this.description = '', this.trailerCode = '',
    this.likeCount = 0, this.screenshots = const [], this.cast = const [],
  });
  final int id;
  final String title;
  final int year;
  final double rating;
  final int runtime;
  final List<String> genres;
  final String smallCover;
  final String mediumCover;
  final String largeCover;
  final String backgroundImage;
  final String summary;
  final String description;
  final String trailerCode;
  final int likeCount;
  final List<String> screenshots;
  final List<MovieActor> cast;
  @override
  List<Object?> get props => [id,title,year,rating,runtime,genres,smallCover,
    mediumCover,largeCover,backgroundImage,summary,description,trailerCode,
    likeCount,screenshots,cast];
}

class MoviesPage extends Equatable {
  const MoviesPage({required this.movies,required this.totalCount,required this.page,required this.limit});
  final List<Movie> movies;
  final int totalCount;
  final int page;
  final int limit;
  bool get hasMore => page * limit < totalCount && movies.isNotEmpty;
  @override
  List<Object?> get props => [movies,totalCount,page,limit];
}

class MovieQuery extends Equatable {
  const MovieQuery({this.page=1,this.limit=20,this.genre,this.query,this.minimumRating,
    this.sortBy='date_added',this.orderBy='desc',this.quality});
  final int page;
  final int limit;
  final String? genre;
  final String? query;
  final int? minimumRating;
  final String sortBy;
  final String orderBy;
  final String? quality;
  MovieQuery copyWith({int? page,int? limit,String? genre,String? query,
      int? minimumRating,String? sortBy,String? orderBy,String? quality}) =>
    MovieQuery(page:page??this.page,limit:limit??this.limit,
      genre:genre??this.genre,query:query??this.query,
      minimumRating:minimumRating??this.minimumRating,
      sortBy:sortBy??this.sortBy,orderBy:orderBy??this.orderBy,
      quality:quality??this.quality);
  @override
  List<Object?> get props => [page,limit,genre,query,minimumRating,sortBy,orderBy,quality];
}
