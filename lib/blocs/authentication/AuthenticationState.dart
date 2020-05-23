import 'package:equatable/equatable.dart';
import 'package:isocial_messenger/models/User.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AuthenticationState extends Equatable {
  AuthenticationState([List props = const <dynamic>[]]) : super(props);
}

class Uninitialized extends AuthenticationState {
  @override
  String toString() => 'Uninitialized';
}

class AuthInProgress extends AuthenticationState {
  @override
  String toString() => 'AuthInProgress';
}

class Authenticated extends AuthenticationState {
  final User user;
  Authenticated(this.user);

  @override
  String toString() => 'Authenticated';
}

class UnAuthenticated extends AuthenticationState {
  @override
  String toString() => 'UnAuthenticated';
}

class AuthError extends AuthenticationState {
  final String err;

  AuthError(this.err);

  @override
  String toString() => 'AuthError';
}
