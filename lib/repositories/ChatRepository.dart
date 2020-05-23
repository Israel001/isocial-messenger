import 'dart:io';

import 'package:isocial_messenger/models/Chat.dart';
import 'package:isocial_messenger/providers/BaseProviders.dart';
import 'package:isocial_messenger/providers/ChatProvider.dart';

class ChatRepository {
  BaseChatProvider chatProvider = ChatProvider();
  Future<List<Chat>> getChats() => chatProvider.getChats();
  Future<void> sendMessage(String otherUserId, String message) => chatProvider
    .sendMessage(otherUserId, message);
  Future<void> sendAttachments(
    String otherUserId, List<File> files
  ) => chatProvider.sendAttachments(otherUserId, files);
  Future<void> deleteMessage(String conversationId, String messageId) =>
    chatProvider.deleteMessage(conversationId, messageId);
}
