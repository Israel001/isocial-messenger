import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AuthenticationEvent extends Equatable {
  AuthenticationEvent([List props = const <dynamic>[]]) : super(props);
}

class AppLaunched extends AuthenticationEvent {
  @override
  String toString() => 'AppLaunched';
}

class ClickedGoogleLogin extends AuthenticationEvent {
  @override
  String toString() => 'ClickedGoogleLogin';
}

class ClickedLoginButton extends AuthenticationEvent {
  final String email;
  final String password;

  ClickedLoginButton(this.email, this.password);

  @override
  String toString() => 'ClickedLoginButton';
}

class LoginError extends AuthenticationEvent {
  final String err;
  LoginError(this.err);

  @override
  String toString() => 'LoginError';
}

class ClickedLogout extends AuthenticationEvent {
  @override
  String toString() => 'ClickedLogout';
}
