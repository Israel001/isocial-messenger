import 'dart:io';
import 'package:isocial_messenger/models/Chat.dart';
import 'package:isocial_messenger/models/User.dart';

abstract class BaseAuthenticationProvider {
  Future<dynamic> signInWithGoogle();
  Future<dynamic> signInWithPassword(email, password);
  Future<void> signOutUser();
  Future<User> getCurrentUser();
  Future<bool> isLoggedIn();
}

abstract class BaseUserDataProvider {
  Future<User> getUser(String username);
  Future<String> getUidByUsername(String username);
  Future<void> cacheUserData(User user);
  Future<void> clearUserDataCache();
}

abstract class BaseStorageProvider {
  Future<String> uploadFile(File file, String path);
}

abstract class BaseChatProvider {
  Future<List<Chat>> getChats();
  Future<void> sendMessage(String otherUserId, String message);
  Future<void> sendAttachments(String otherUserId, List<File> files);
  Future<void> deleteMessage(String conversationId, String messageId);
}
