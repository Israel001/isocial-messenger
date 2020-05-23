abstract class iSocialMessengerException implements Exception {
  String errorMessage();
}

class UserNotFoundException extends iSocialMessengerException {
  @override
  String errorMessage() => 'No user found for provided uid/username';
}

class UsernameMappingUndefinedException extends iSocialMessengerException {
  @override
  String errorMessage() => 'User not found';
}
