import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../movies/domain/entities/movie.dart';
import '../../domain/repositories/library_repository.dart';

class LibraryState extends Equatable {
  const LibraryState({this.uid,this.watchlist=const [],this.history=const [],
    this.isLoading=true,this.failure});
  final String? uid;
  final List<Movie> watchlist,history;
  final bool isLoading;
  final Failure? failure;
  bool includes(int id) => watchlist.any((m)=>m.id==id);
  @override
  List<Object?> get props=>[uid,watchlist,history,isLoading,failure];
}

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit(this._repo):super(const LibraryState());
  final LibraryRepository _repo;
  StreamSubscription? _watchlistSubscription;
  StreamSubscription? _historySubscription;
  Future<void> bindUser(String? uid,{bool force=false}) async {
    if (state.uid==uid && !state.isLoading && !force) return;
    await _watchlistSubscription?.cancel();
    await _historySubscription?.cancel();
    if (isClosed) return;
    if (uid==null) { emit(const LibraryState(isLoading:false));return; }
    emit(LibraryState(uid:uid));
    _watchlistSubscription=_repo.watchWatchlist(uid).listen((result){
      if (isClosed || state.uid!=uid) return;
      result.fold((f)=>emit(LibraryState(uid:uid,watchlist:state.watchlist,
        history:state.history,isLoading:false,failure:f)),
        (movies)=>emit(LibraryState(uid:uid,watchlist:movies,
          history:state.history,isLoading:false)));
    });
    _historySubscription=_repo.watchHistory(uid).listen((result){
      if (isClosed || state.uid!=uid) return;
      result.fold((f)=>emit(LibraryState(uid:uid,watchlist:state.watchlist,
        history:state.history,isLoading:false,failure:f)),
        (movies)=>emit(LibraryState(uid:uid,watchlist:state.watchlist,
          history:movies,isLoading:false)));
    });
  }
  Future<Failure?> toggleWatchlist(Movie movie) async {
    final uid=state.uid;
    if (uid==null) return const AuthFailure('Please sign in to save movies.');
    final result=await _repo.setWatchlisted(uid,movie,!state.includes(movie.id));
    return result.fold((f)=>f,(_)=>null);
  }
  Future<Failure?> recordHistory(Movie movie) async {
    final uid=state.uid;
    if (uid==null) return const AuthFailure('Please sign in to record history.');
    final result=await _repo.addHistory(uid,movie);
    return result.fold((f)=>f,(_)=>null);
  }
  @override
  Future<void> close() async {
    await _watchlistSubscription?.cancel();await _historySubscription?.cancel();
    await super.close();
  }
}
