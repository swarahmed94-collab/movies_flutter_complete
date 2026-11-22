import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';

enum AuthStatus {
  checking,
  signedOut,
  signedIn,
  working,
  passwordResetSent,
  failed,
}

class AuthState extends Equatable {
  const AuthState({
    required this.status,
    this.user,
    this.failure,
  });

  final AuthStatus status;
  final AppUser? user;
  final Failure? failure;

  @override
  List<Object?> get props => [status, user, failure];
}
