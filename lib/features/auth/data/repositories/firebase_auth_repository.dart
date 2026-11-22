import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_remote_data_source.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._remote);
  final FirebaseAuthRemoteDataSource _remote;

  AppUser _map(User user) => AppUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        providerIds: user.providerData.map((p)=>p.providerId).toList(growable:false),
      );

  @override
  AppUser? get currentUser {
    final user = _remote.instance.currentUser;
    return user == null ? null : _map(user);
  }

  @override
  Stream<AppUser?> get authStateChanges => _remote.instance
      .userChanges()
      .map((user) => user == null ? null : _map(user));

  @override
  Future<Either<Failure, AppUser>> login({
    required String email,
    required String password,
  }) async {
    try {
      return right(_map(await _remote.signIn(email, password)));
    } catch (error) {
      return left(FailureMapper.from(error));
    }
  }

  @override
  Future<Either<Failure, AppUser>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      return right(_map(await _remote.signUp(email, password, displayName)));
    } catch (error) {
      return left(FailureMapper.from(error));
    }
  }

  @override
  Future<Either<Failure, AppUser>> loginWithGoogle() async {
    try {
      return right(_map(await _remote.signInWithGoogle()));
    } catch (error) {
      return left(FailureMapper.from(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordReset(String email) async {
    try {
      await _remote.sendPasswordReset(email);
      return right(unit);
    } catch (error) {
      return left(FailureMapper.from(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _remote.signOut();
      return right(unit);
    } catch (error) {
      return left(FailureMapper.from(error));
    }
  }
  @override
  Future<Either<Failure,Unit>> updateDisplayName(String name) async {
    try { await _remote.updateDisplayName(name);return right(unit); }
    catch(e) { return left(FailureMapper.from(e)); }
  }
  @override
  Future<Either<Failure,Unit>> deleteAccount() async {
    try { await _remote.deleteAccount();return right(unit); }
    catch(e) { return left(FailureMapper.from(e)); }
  }
  @override
  Future<Either<Failure,Unit>> reauthenticate({String? password}) async {
    try {await _remote.reauthenticate(password:password);return right(unit);}
    catch(e){return left(FailureMapper.from(e));}
  }
}

