import '../../../../core/error/failures.dart';
import '../../../../core/network/cached_json_request.dart';
import '../../domain/entities/movie.dart';
import '../models/movie_model.dart';

/// Public YTS v2 GET contract: list_movies, movie_details, movie_suggestions.
/// No other routes, POSTs or streaming sources are assumed.
class YtsMoviesRemoteDataSource {
  const YtsMoviesRemoteDataSource(this._requests);
  final CachedJsonRequest _requests;

  Map<String,dynamic> _unwrap(Map<String,dynamic> json) {
    if (json['status'] != 'ok') {
      throw ApiFailure(JsonValue.string(json['status_message']).isNotEmpty
          ? JsonValue.string(json['status_message']) : 'Movie service failed.');
    }
    final data=json['data'];
    if (data is! Map) throw const ApiFailure('The API returned an invalid data field.');
    return Map<String,dynamic>.from(data);
  }

  Future<MoviesPage> list(MovieQuery query) async {
    final params = <String,dynamic>{
      'limit':query.limit.clamp(1,50), 'page':query.page,
      'sort_by':query.sortBy,'order_by':query.orderBy,
      if (query.genre != null && query.genre!.isNotEmpty) 'genre':query.genre,
      if (query.query != null && query.query!.isNotEmpty) 'query_term':query.query,
      if (query.minimumRating != null) 'minimum_rating':query.minimumRating!.clamp(0,9),
      if (query.quality != null) 'quality':query.quality,
    };
    final key='yts:v2:list:${Uri(queryParameters:params.map((k,v)=>MapEntry(k,'$v'))).query}';
    final result=await _requests.get(path:'list_movies.json',cacheKey:key,
        queryParameters:params,maxAge:const Duration(minutes:30));
    return result.fold((error)=>throw error,(json){
      final data=_unwrap(json);
      final movies=JsonValue.list(data['movies']).map((e)=>MovieModel.fromJson(
        JsonValue.object(e)).entity).where((e)=>e.id>0).toList(growable:false);
      return MoviesPage(movies:movies,totalCount:JsonValue.integer(data['movie_count']),
          page:JsonValue.integer(data['page_number'])==0?query.page:JsonValue.integer(data['page_number']),
          limit:JsonValue.integer(data['limit'])==0?query.limit:JsonValue.integer(data['limit']));
    });
  }

  Future<Movie> details(int id) async {
    final result=await _requests.get(path:'movie_details.json',cacheKey:'yts:v2:details:$id',
        queryParameters:{'movie_id':id,'with_images':true,'with_cast':true},
        maxAge:const Duration(hours:12));
    return result.fold((error)=>throw error,(json){
      final data=_unwrap(json);
      final movie=MovieModel.fromJson(JsonValue.object(data['movie'])).entity;
      if (movie.id==0) throw const ApiFailure('Movie details are missing.');
      return movie;
    });
  }

  Future<List<Movie>> suggestions(int id) async {
    final result=await _requests.get(path:'movie_suggestions.json',
        cacheKey:'yts:v2:suggestions:$id',queryParameters:{'movie_id':id},
        maxAge:const Duration(hours:12));
    return result.fold((error)=>throw error,(json){
      final data=_unwrap(json);
      return JsonValue.list(data['movies']).map((e)=>MovieModel.fromJson(
          JsonValue.object(e)).entity).where((e)=>e.id>0).toList(growable:false);
    });
  }
}
