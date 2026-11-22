import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../domain/entities/app_user.dart';
import '../../../user_data/domain/repositories/user_document_repository.dart';
import '../../../library/domain/repositories/library_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository,this._documents,this._library)
      : super(const AuthState(status: AuthStatus.checking)) {
    _subscription = _repository.authStateChanges.listen(
      (user) {
        if (isClosed || state.status == AuthStatus.working) return;
        emit(AuthState(
          status: user == null ? AuthStatus.signedOut : AuthStatus.signedIn,
          user: user,
        ));
      },
      onError: (Object error) {
        if (isClosed) return;
        emit(AuthState(
          status: AuthStatus.failed,
          user: state.user,
          failure: FailureMapper.from(error),
        ));
      },
    );
  }

  final AuthRepository _repository;
  final UserDocumentRepository _documents;
  final LibraryRepository _library;
  late final StreamSubscription<AppUser?> _subscription;

  Future<void> login(String email, String password) async {
    emit(AuthState(status: AuthStatus.working, user: state.user));
    final result = await _repository.login(email: email, password: password);
    if (isClosed) return;
    result.fold(
      (failure) => emit(AuthState(
        status: AuthStatus.failed,
        failure: failure,
        user: state.user,
      )),
      (user) => emit(AuthState(status: AuthStatus.signedIn, user: user)),
    );
  }

  Future<void> register(String name, String email, String password,
      {String phoneNumber='',int avatarIndex=7}) async {
    emit(AuthState(status:AuthStatus.working,user:state.user));
    final result=await _repository.register(displayName:name,email:email,password:password);
    if (isClosed) return;
    await result.fold((failure) async {
      emit(AuthState(status:AuthStatus.failed,user:state.user,failure:failure));
    },(user) async {
      final save=await _documents.merge(user.uid,{
        'displayName':name.trim(),'email':email.trim(),
        'phoneNumber':phoneNumber.trim(),'avatarIndex':avatarIndex,
      });
      if (isClosed) return;
      save.fold((f)=>emit(AuthState(status:AuthStatus.failed,user:user,failure:f)),
        (_)=>emit(AuthState(status:AuthStatus.signedIn,user:user)));
    });
  }

  Future<void> loginWithGoogle() async {
    emit(AuthState(status: AuthStatus.working, user: state.user));
    final result = await _repository.loginWithGoogle();
    if (isClosed) return;
    result.fold(
      (failure) => emit(AuthState(
        status: AuthStatus.failed,
        failure: failure,
        user: state.user,
      )),
      (user) => emit(AuthState(status: AuthStatus.signedIn, user: user)),
    );
  }

  Future<void> resetPassword(String email) async {
    emit(AuthState(status: AuthStatus.working, user: state.user));
    final result = await _repository.sendPasswordReset(email);
    if (isClosed) return;
    result.fold(
      (failure) => emit(AuthState(
        status: AuthStatus.failed,
        failure: failure,
        user: state.user,
      )),
      (_) => emit(AuthState(
        status: AuthStatus.passwordResetSent,
        user: state.user,
      )),
    );
  }

  Future<void> logout() async {
    emit(AuthState(status: AuthStatus.working, user: state.user));
    final result = await _repository.logout();
    if (isClosed) return;
    result.fold(
      (failure) => emit(AuthState(
        status: AuthStatus.failed,
        failure: failure,
        user: state.user,
      )),
      (_) => emit(const AuthState(status: AuthStatus.signedOut)),
    );
  }

  Future<void> deleteAccount({String? currentPassword}) async {
    final user=_repository.currentUser;
    if (user==null) return;
    emit(AuthState(status:AuthStatus.working,user:user));
    // Force a recent sign-in before deleting any app-owned Firestore data.
    final reauth=await _repository.reauthenticate(password:currentPassword);
    if(isClosed)return;
    final authFailure=reauth.fold((f)=>f,(_)=>null);
    if(authFailure!=null){
      emit(AuthState(status:AuthStatus.failed,user:user,failure:authFailure));return;
    }
    // Delete subcollections while the user's Firebase credentials still work.
    final cleared=await _library.clearUserData(user.uid);
    if(isClosed)return;
    final clearFailure=cleared.fold((f)=>f,(_)=>null);
    if(clearFailure!=null){
      emit(AuthState(status:AuthStatus.failed,user:user,failure:clearFailure));return;
    }
    final remove=await _repository.deleteAccount();
    if(isClosed)return;
    final deleteFailure=remove.fold((f)=>f,(_)=>null);
    if(deleteFailure!=null){
      emit(AuthState(status:AuthStatus.failed,user:user,failure:deleteFailure));return;
    }
    emit(const AuthState(status:AuthStatus.signedOut));
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
