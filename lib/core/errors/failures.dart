import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Fired when Dio gets a non-2xx response from the API
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Fired when SharedPreferences read/write fails
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Fired when device has no internet
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Fired on 401 responses — triggers logout flow
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
