import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;

  Future<Either<Failure, AppUser>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Either<Failure, AppUser>> loginWithGoogle();
  Future<Either<Failure, Unit>> sendPasswordReset(String email);
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, Unit>> updateDisplayName(String name);
  Future<Either<Failure, Unit>> deleteAccount();
  Future<Either<Failure, Unit>> reauthenticate({String? password});
}
