import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movies_repository.dart';

enum DetailsStatus { loading, ready, failed }
class MovieDetailsState extends Equatable {
  const MovieDetailsState({this.status=DetailsStatus.loading,this.movie,
    this.suggestions=const [],this.failure});
  final DetailsStatus status;
  final Movie? movie;
  final List<Movie> suggestions;
  final Failure? failure;
  @override
  List<Object?> get props => [status,movie,suggestions,failure];
}
class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  MovieDetailsCubit(this._repo):super(const MovieDetailsState());
  final MoviesRepository _repo;
  Future<void> load(int id) async {
    emit(const MovieDetailsState());
    final detail=await _repo.details(id);
    if (isClosed) return;
    await detail.fold((failure) async => emit(MovieDetailsState(status:DetailsStatus.failed,failure:failure)),
      (movie) async {
        emit(MovieDetailsState(status:DetailsStatus.ready,movie:movie));
        final suggestions=await _repo.suggestions(id);
        if (isClosed) return;
        suggestions.fold((_) {},(items)=>emit(MovieDetailsState(
          status:DetailsStatus.ready,movie:movie,suggestions:items)));
      });
  }
}
