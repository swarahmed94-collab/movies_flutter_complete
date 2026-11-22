import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

final class ApiFailure extends Failure {
  const ApiFailure(super.message);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

final class ConfigurationFailure extends Failure {
  const ConfigurationFailure(super.message);
}

final class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
