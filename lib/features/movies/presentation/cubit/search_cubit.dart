import 'dart:async';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movies_repository.dart';
import 'movie_list_cubit.dart';

class SearchCubit extends MovieListCubit {
  SearchCubit(MoviesRepository repo):super(repo);
  Timer? _debounce;
  String _current='';
  void changed(String text){
    _current=text.trim();
    _debounce?.cancel();
    if(_current.isEmpty) {reset();return;}
    _debounce=Timer(const Duration(milliseconds:450),(){
      load(MovieQuery(query:_current,limit:20));
    });
  }
  @override
  Future<void> close() async { _debounce?.cancel();await super.close(); }
}
