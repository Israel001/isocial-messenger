import 'package:equatable/equatable.dart';
import 'package:isocial_messenger/models/Chat.dart';
import 'package:isocial_messenger/models/User.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ChatState extends Equatable {
  ChatState([ List props = const<dynamic>[] ]) : super(props);
}

class InitialChatState extends ChatState {}

class FetchedChatListState extends ChatState {
  final List<Chat> chatList;

  FetchedChatListState(this.chatList);

  @override
  String toString() => 'FetchedChatListState';
}

class FetchedMessagesState extends ChatState {
  final List<dynamic> messages;

  FetchedMessagesState(this.messages);

  @override
  String toString() => 'FetchedMessagesState';
}

class ErrorState extends ChatState {
  final Exception exception;

  ErrorState(this.exception) : super([exception]);

  @override
  String toString () => 'ErrorState';
}

class FetchedContactDetailsState extends ChatState {
  final User user;

  FetchedContactDetailsState(this.user) : super([user]);

  @override
  String toString () => 'FetchedContactDetailsState';
}

class PageChangedState extends ChatState {
  final String chatId;

  PageChangedState(this.chatId);

  @override
  String toString() => 'PageChangedState';
}

class ChatInProgress extends ChatState {
  @override
  String toString() => 'ChatInProgress';
}

class NoChats extends ChatState {
  @override
  String toString() => 'NoChats';
}
