import 'package:isocial_messenger/models/User.dart';
import 'package:isocial_messenger/providers/BaseProviders.dart';
import 'package:isocial_messenger/providers/UserDataProvider.dart';

class UserDataRepository {
  BaseUserDataProvider userDataProvider = UserDataProvider();

  Future<User> getUser(String username) => userDataProvider.getUser(username);
  Future<String> getUidByUsername(String username) => userDataProvider
    .getUidByUsername(username);
  Future<void> cacheUserData(User user) => userDataProvider.cacheUserData(user);
  Future<void> clearUserDataCache() => userDataProvider.clearUserDataCache();
}
