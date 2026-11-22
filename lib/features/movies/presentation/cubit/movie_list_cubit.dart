import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movies_repository.dart';

enum MovieListStatus { initial, loading, ready, loadingMore, failure }

class MovieListState extends Equatable {
  const MovieListState({this.status=MovieListStatus.initial,this.items=const [],
    this.hasMore=true,this.failure,this.query=const MovieQuery()});
  final MovieListStatus status;
  final List<Movie> items;
  final bool hasMore;
  final Failure? failure;
  final MovieQuery query;
  @override
  List<Object?> get props => [status,items,hasMore,failure,query];
}

class MovieListCubit extends Cubit<MovieListState> {
  MovieListCubit(this._repo):super(const MovieListState());
  final MoviesRepository _repo;
  int _requestId=0;
  Future<void> load(MovieQuery query) async {
    final request=++_requestId;
    emit(MovieListState(status:MovieListStatus.loading,query:query));
    final result=await _repo.list(query);
    if (isClosed || request!=_requestId) return;
    result.fold((f)=>emit(MovieListState(status:MovieListStatus.failure,query:query,failure:f)),
      (page)=>emit(MovieListState(status:MovieListStatus.ready,query:query,
        items:page.movies,hasMore:page.hasMore)));
  }
  void reset(){_requestId++;emit(const MovieListState());}
  Future<void> nextPage() async {
    if (state.status!=MovieListStatus.ready || !state.hasMore) return;
    final previous=state;
    final request=++_requestId;
    emit(MovieListState(status:MovieListStatus.loadingMore,query:previous.query,
      items:previous.items,hasMore:previous.hasMore));
    final nextQuery=previous.query.copyWith(page:previous.query.page+1);
    final result=await _repo.list(nextQuery);
    if (isClosed || request!=_requestId) return;
    result.fold((f)=>emit(MovieListState(status:MovieListStatus.ready,
      items:previous.items,query:previous.query,hasMore:previous.hasMore,failure:f)),
      (page){
        final existing={for (final m in previous.items) m.id};
        final appended=[...previous.items,...page.movies.where((e)=>existing.add(e.id))];
        emit(MovieListState(status:MovieListStatus.ready,items:appended,
          query:nextQuery,hasMore:page.hasMore));
      });
  }
}
