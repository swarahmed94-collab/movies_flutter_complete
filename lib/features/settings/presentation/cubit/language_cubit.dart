import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/cache_helper.dart';
class LanguageCubit extends Cubit<String> {
  LanguageCubit(this._cache):super('en') { load(); }
  final CacheHelper _cache;
  Future<void> load() async {
    final value=await _cache.getLanguage();
    if(!isClosed)emit(value=='ar'?'ar':'en');
  }
  Future<void> select(String code) async {
    if(code!='ar' && code!='en')return;
    await _cache.setLanguage(code);
    if(!isClosed) emit(code);
  }
}
