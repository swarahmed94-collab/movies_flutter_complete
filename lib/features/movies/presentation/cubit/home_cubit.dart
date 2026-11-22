import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movies_repository.dart';

enum HomeStatus { initial, loading, ready, failed }
class HomeState extends Equatable {
  const HomeState({this.status=HomeStatus.initial,this.featured=const [],
    this.action=const [],this.adventure=const [],this.animation=const [],this.failure});
  final HomeStatus status;
  final List<Movie> featured,action,adventure,animation;
  final Failure? failure;
  @override
  List<Object?> get props=>[status,featured,action,adventure,animation,failure];
}
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repo):super(const HomeState());
  final MoviesRepository _repo;
  Future<void> load() async {
    emit(const HomeState(status:HomeStatus.loading));
    final results=await Future.wait([
      _repo.list(const MovieQuery(limit:8,sortBy:'date_added')),
      _repo.list(const MovieQuery(limit:12,genre:'Action',sortBy:'rating')),
      _repo.list(const MovieQuery(limit:12,genre:'Adventure',sortBy:'rating')),
      _repo.list(const MovieQuery(limit:12,genre:'Animation',sortBy:'rating')),
    ]);
    if (isClosed) return;
    final pages=<List<Movie>>[];
    Failure? failure;
    for (final result in results) {
      result.fold((f){failure??=f;pages.add([]);},(p)=>pages.add(p.movies));
    }
    if (pages.every((p)=>p.isEmpty)) {
      emit(HomeState(status:HomeStatus.failed,failure:failure));
      return;
    }
    emit(HomeState(status:HomeStatus.ready,featured:pages[0],action:pages[1],
      adventure:pages[2],animation:pages[3],failure:failure));
  }
}
