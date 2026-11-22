import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/cache_helper.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
enum StartupDestination { initial, onboarding, login, app }
class StartupCubit extends Cubit<StartupDestination> {
  StartupCubit(this._prefs,this._auth):super(StartupDestination.initial);
  final CacheHelper _prefs;
  final AuthRepository _auth;
  Future<void> decide() async {
    final done=await _prefs.isOnboardingCompleted();
    if(isClosed)return;
    if (!done) { emit(StartupDestination.onboarding); }
    else if (_auth.currentUser==null) { emit(StartupDestination.login); }
    else { emit(StartupDestination.app); }
  }
}
