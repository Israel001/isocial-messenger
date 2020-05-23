import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:isocial_messenger/blocs/chat/Bloc.dart';
import 'package:isocial_messenger/models/Chat.dart';
import 'package:isocial_messenger/repositories/ChatRepository.dart';
import 'package:isocial_messenger/repositories/StorageRepository.dart';
import 'package:isocial_messenger/repositories/UserDataRepository.dart';
import 'package:isocial_messenger/utils/Exceptions.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  final StorageRepository storageRepository;
  final UserDataRepository userDataRepository;

  ChatBloc(
    {
      this.chatRepository,
      this.storageRepository,
      this.userDataRepository
    }
  ) : assert(chatRepository != null),
      assert(storageRepository != null),
      assert(userDataRepository != null);

  @override
  ChatState get initialState => InitialChatState();

  @override
  Stream<ChatState> mapEventToState(ChatEvent event) async* {
    if (event is FetchChatListEvent) {
      yield* mapFetchChatListEventToState(event);
    }
    if (event is PageChangedEvent) {
      yield PageChangedState(event.chatId);
    }
    if (event is SendTextMessageEvent) {
      yield* mapSendTextMessageEventToState(event);
    }
    if (event is SendAttachmentEvent) {
      yield* mapSendAttachmentEventToState(event);
    }
    if (event is DeleteMessageEvent) {
      yield* mapDeleteMessageEventToState(event);
    }
  }

  Stream<ChatState> mapFetchChatListEventToState(FetchChatListEvent event) async* {
    yield ChatInProgress();
    try {
      List<Chat> chats = await chatRepository.getChats();
      if (chats == null || chats.isEmpty) {
        yield NoChats();
      } else {
        yield FetchedChatListState(chats);
      }
    } on iSocialMessengerException catch (exception) {
      yield ErrorState(exception);
    }
  }

  Stream<ChatState> mapSendTextMessageEventToState(SendTextMessageEvent event) async* {
    try {
      await chatRepository.sendMessage(event.otherUserId, event.message);
    } on iSocialMessengerException catch (exception) {
      yield ErrorState(exception);
    }
  }

  Stream<ChatState> mapSendAttachmentEventToState(SendAttachmentEvent event) async* {
    try {
      await chatRepository.sendAttachments(event.otherUserId, event.files);
    } on iSocialMessengerException catch (exception) {
      yield ErrorState(exception);
    }
  }

  Stream<ChatState> mapDeleteMessageEventToState(DeleteMessageEvent event) async* {
    try {
      await chatRepository.deleteMessage(event.conversationId, event.messageId);
    } on iSocialMessengerException catch (exception) {
      yield ErrorState(exception);
    }
  }
}
