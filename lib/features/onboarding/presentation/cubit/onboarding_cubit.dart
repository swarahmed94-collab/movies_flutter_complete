import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/cache_helper.dart';
class OnboardingCubit extends Cubit<int> {
  OnboardingCubit(this._prefs):super(0);
  final CacheHelper _prefs;
  void next(){if(state<5)emit(state+1);}
  void back(){if(state>0)emit(state-1);}
  Future<void> finish()=>_prefs.setOnboardingCompleted(true);
}
