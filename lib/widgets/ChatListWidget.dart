import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isocial_messenger/config/Constants.dart';
import 'package:isocial_messenger/models/Message.dart';
import 'package:isocial_messenger/utils/SharedObjects.dart';
import 'package:isocial_messenger/widgets/ChatItemWidget.dart';
import 'package:isocial_messenger/widgets/ProgressWidget.dart';

class ChatListWidget extends StatefulWidget {
  final String conversationId;

  ChatListWidget(this.conversationId);

  @override
  _ChatListWidgetState createState() => _ChatListWidgetState(this.conversationId);
}

class _ChatListWidgetState extends State<ChatListWidget> {
  final ScrollController listScrollController = new ScrollController();
  final chatsRef = Firestore.instance.collection('chats');
  List<dynamic> messages = List();
  String uId = SharedObjects.prefs.getString(Constants.sessionUid);
  final String conversationId;
  Timer timer;

  _ChatListWidgetState(this.conversationId);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: chatsRef
        .document(uId).collection('conversations')
        .document(conversationId).collection('messages')
        .where('isDeleted', isEqualTo: false).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return circularProgress(context);
        List<dynamic> messages = [];
        snapshot.data.documents.forEach((doc) {
          int type = doc['type'];
          switch (type) {
            case 0:
              TextMessage message = TextMessage.fromDocument(doc);
              messages.add(message);
            break;
            case 1:
              ImageMessage message = ImageMessage.fromDocument(doc);
              messages.add(message);
            break;
            case 2:
              VideoMessage message = VideoMessage.fromDocument(doc);
              messages.add(message);
            break;
            case 3:
              FileMessage message = FileMessage.fromDocument(doc);
              messages.add(message);
            break;
          }
        });
        Timer(
          Duration(seconds: 1),
          () {
            listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 100),
              curve: Curves.easeOut
            );
          }
        );
        return ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemBuilder: (context, index) => ChatItemWidget(
            messages[index], conversationId
          ),
          itemCount: messages.length,
          controller: listScrollController,
        );
      }
    );
  }
}
