import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isocial_messenger/config/Constants.dart';
import 'package:isocial_messenger/config/Palette.dart';
import 'package:isocial_messenger/models/Message.dart';
import 'package:isocial_messenger/utils/SharedObjects.dart';
import 'package:isocial_messenger/widgets/ProgressWidget.dart';

// ignore: must_be_immutable
class ConversationFiles extends StatefulWidget {
  final String conversationId;
  int fileIndex = 0;

  ConversationFiles(this.conversationId, { this.fileIndex });

  @override
  State<StatefulWidget> createState() {
    return ConversationFilesState(this.conversationId);
  }
}

class ConversationFilesState extends State<ConversationFiles> {
  ScrollController scrollController = ScrollController();
  static List<String> files = [];
  final chatsRef = Firestore.instance.collection('chats');
  String uId = SharedObjects.prefs.getString(Constants.sessionUid);
  final String conversationId;

  ConversationFilesState(this.conversationId);

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.accentColor,
        title: Text('Uploaded Files'),
      ),
      body: Container(
        color: Colors.white,
        child: StreamBuilder(
          stream: chatsRef
            .document(uId).collection('conversations')
            .document(conversationId).collection('messages')
            .where('type', isEqualTo: 3).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: circularProgress(context));
            }
            snapshot.data.documents.forEach((doc) {
              FileMessage message = FileMessage.fromDocument(doc);
              for (int i = 0; i < message.files.length; i++) {
                if (!files.contains(message.files[i])) {
                  files.add(message.files[i]);
                }
              }
            });
            Timer(
              Duration(milliseconds: 1000),
              () => scrollController.jumpTo(widget.fileIndex ?? 0)
            );
            return ListView.separated(
              controller: scrollController,
              itemCount: files.length,
              itemBuilder: (context, index) {
                return Container(
                  color: widget.fileIndex == index
                      ? Palette.greyColor : Palette.primaryColor,
                  child: ListTile(
                    title: Text(
                      SharedObjects.extractFileName(files[index]),
                      overflow: TextOverflow.ellipsis
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.file_download),
                      onPressed: () => SharedObjects.downloadFile(files[index])
                    )
                  )
                );
              },
              separatorBuilder: (context, index) => Divider()
            );
          }
        )
      )
    );
  }
}
