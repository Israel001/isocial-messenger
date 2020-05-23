import 'package:isocial_messenger/models/User.dart';
import 'package:isocial_messenger/providers/AuthenticationProvider.dart';
import 'package:isocial_messenger/providers/BaseProviders.dart';

class AuthenticationRepository {
  BaseAuthenticationProvider authenticationProvider = AuthenticationProvider();

  Future<dynamic> signInWithGoogle() => authenticationProvider.signInWithGoogle();
  Future<dynamic> signInWithPassword(email, password) => authenticationProvider
      .signInWithPassword(email, password);
  Future<void> signOutUser() => authenticationProvider.signOutUser();
  Future<User> getCurrentUser() => authenticationProvider.getCurrentUser();
  Future<bool> isLoggedIn() => authenticationProvider.isLoggedIn();
}
