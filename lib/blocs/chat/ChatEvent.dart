import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:isocial_messenger/models/Chat.dart';
import 'package:meta/meta.dart';


@immutable
abstract class ChatEvent extends Equatable {
  ChatEvent([ List props = const <dynamic>[] ]) : super(props);
}

class FetchChatListEvent extends ChatEvent {
  @override
  String toString() => 'FetchChatListEvent';
}

class ReceivedChatsEvent extends ChatEvent {
  final List<Chat> chatList;

  ReceivedChatsEvent(this.chatList);

  @override
  String toString() => 'ReceivedChatsEvent';
}

class FetchMessagesEvent extends ChatEvent {
  final String conversationId;

  FetchMessagesEvent(this.conversationId);

  @override
  String toString() => 'FetchMessagesEvent';
}

class SendTextMessageEvent extends ChatEvent {
  final String otherUserId;
  final String message;

  SendTextMessageEvent(this.otherUserId, this.message);

  @override
  String toString() => 'SendTextMessageEvent';
}

class SendAttachmentEvent extends ChatEvent {
  final String otherUserId;
  final List<File> files;

  SendAttachmentEvent(this.otherUserId, this.files);

  @override
  String toString() => 'PickedAttachmentEvent';
}

class PageChangedEvent extends ChatEvent {
  final String chatId;

  PageChangedEvent(this.chatId);

  @override
  String toString() => 'PageChangedEvent';
}

class DeleteMessageEvent extends ChatEvent {
  final String messageId;
  final String conversationId;

  DeleteMessageEvent(this.messageId, this.conversationId);

  @override
  String toString() => 'DeleteMessageEvent';
}
