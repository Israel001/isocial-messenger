import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:isocial_messenger/models/User.dart';
import 'package:isocial_messenger/repositories/AuthenticationRepository.dart';
import 'package:isocial_messenger/repositories/UserDataRepository.dart';
import './Bloc.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository authenticationRepository;
  final UserDataRepository userDataRepository;

  AuthenticationBloc(
    {
      this.authenticationRepository,
      this.userDataRepository
    }
  ) : assert (authenticationRepository != null),
      assert (userDataRepository != null);

  @override
  AuthenticationState get initialState => Uninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event
  ) async* {
    if (event is AppLaunched) {
      yield* mapAppLaunchedToState();
    } else if (event is ClickedGoogleLogin) {
      yield* mapClickedGoogleLoginToState();
    } else if (event is ClickedLoginButton) {
      yield* mapClickedLoginButtonToState(event);
    } else if (event is LoginError) {
      yield* mapLoginErrorToState(event);
    } else if (event is ClickedLogout) {
      yield* mapLoggedOutToState();
    }
  }

  Stream<AuthenticationState> mapAppLaunchedToState() async* {
    try {
      yield AuthInProgress();
      final isSignedIn = await authenticationRepository.isLoggedIn();
      if (isSignedIn) {
        final user = await authenticationRepository.getCurrentUser();
        userDataRepository.cacheUserData(user);
        yield Authenticated(user);
      } else {
        yield UnAuthenticated();
      }
    } catch(_) {
      yield UnAuthenticated();
    }
  }

  Stream<AuthenticationState> mapClickedGoogleLoginToState() async* {
    yield AuthInProgress();
    try {
      dynamic loginRes = await authenticationRepository.signInWithGoogle();
      if (loginRes == null || loginRes.runtimeType == String) {
        yield UnAuthenticated();
        dispatch(LoginError(loginRes));
      } else if (loginRes.runtimeType == User) {
        await userDataRepository.cacheUserData(loginRes);
        yield Authenticated(loginRes);
      } else {
        yield AuthInProgress();
      }
    } catch(_) {
      yield UnAuthenticated();
      dispatch(LoginError('Something went wrong'));
    }
  }

  Stream<AuthenticationState> mapClickedLoginButtonToState(data) async* {
    yield AuthInProgress();
    try {
      dynamic loginRes = await authenticationRepository.signInWithPassword(
        data.email, data.password
      );
      if (loginRes.runtimeType == String) {
        yield UnAuthenticated();
        dispatch(LoginError(loginRes));
      } else {
        userDataRepository.cacheUserData(loginRes);
        yield Authenticated(loginRes);
      }
    } catch(_) {
      yield UnAuthenticated();
      dispatch(LoginError('Something went wrong'));
    }
  }

  Stream<AuthenticationState> mapLoginErrorToState(err) async* {
    yield AuthError(err);
  }

  Stream<AuthenticationState> mapLoggedOutToState() async* {
    yield UnAuthenticated();
    await userDataRepository.clearUserDataCache();
    await authenticationRepository.signOutUser();
  }
}
