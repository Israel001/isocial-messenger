import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:isocial_messenger/config/Constants.dart';
import 'package:isocial_messenger/models/Chat.dart';
import 'package:isocial_messenger/models/Message.dart';
import 'package:isocial_messenger/models/User.dart';
import 'package:isocial_messenger/utils/SharedObjects.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import 'BaseProviders.dart';

class ChatProvider extends BaseChatProvider {
  final chatsRef = Firestore.instance.collection('chats');
  final usersRef = Firestore.instance.collection('users');
  final StorageReference storageRef = FirebaseStorage.instance.ref();
  List<String> filesUploaded = [];

  @override
  Future<List<Chat>> getChats() async {
    String uId = SharedObjects.prefs.getString(Constants.sessionUid);
    QuerySnapshot snapshot = await chatsRef
      .document(uId).collection('conversations').getDocuments();
    List<Chat> chatList = [];
    if (snapshot.documents.length > 0) {
      for (int i = 0; i < snapshot.documents.length; i++) {
        DocumentSnapshot userDoc = await usersRef
          .document(snapshot.documents[i].documentID.split(uId)[1]).get();
        User user = User.fromDocument(userDoc);
        QuerySnapshot lastMesSnapshot = await chatsRef
          .document(uId).collection('conversations')
          .document(snapshot.documents[i].documentID)
          .collection('messages').where('isDeleted', isEqualTo: false)
          .orderBy('timeStamp', descending: true)
          .limit(1).getDocuments();
        DocumentSnapshot doc = lastMesSnapshot.documents[0];
        int type = doc['type'];
        switch (type) {
          case 0:
            TextMessage message = TextMessage.fromDocument(doc);
            Chat chat = new Chat(
              snapshot.documents[i].documentID,
              user, textMessage: message
            );
            chatList.add(chat);
          break;
          case 1:
            ImageMessage message = ImageMessage.fromDocument(doc);
            Chat chat = new Chat(
              snapshot.documents[i].documentID,
              user, imageMessage: message
            );
            chatList.add(chat);
          break;
          case 2:
            VideoMessage message = VideoMessage.fromDocument(doc);
            Chat chat = new Chat(
              snapshot.documents[i].documentID,
              user, videoMessage: message
            );
            chatList.add(chat);
          break;
          case 3:
            FileMessage message = FileMessage.fromDocument(doc);
            Chat chat = new Chat(
              snapshot.documents[i].documentID,
              user, fileMessage: message
            );
            chatList.add(chat);
          break;
        }
      }
    }
    return chatList;
  }

  @override
  Future<void> sendMessage(String otherUserId, String message) async {
    DocumentReference conversation;
    DocumentReference conversationId;
    String uId = SharedObjects.prefs.getString(Constants.sessionUid);
    String messageId = await calcMessageId(uId, uId+otherUserId);
    conversation = chatsRef.document(uId);
    conversation.setData({'dummy': 'dummy'});
    conversationId = conversation.collection('conversations')
      .document(uId+otherUserId);
    conversationId.setData({'dummy': 'dummy'});
    conversationId.collection('messages')
      .document(messageId).setData({
        'id': messageId,
        'from': uId,
        'text': message.trim(),
        'timeStamp': DateTime.now(),
        'to': otherUserId,
        'type': 0,
        'isDeleted': false
      });
    conversation = chatsRef.document(otherUserId);
    conversation.setData({'dummy': 'dummy'});
    conversationId = conversation.collection('conversations')
      .document(otherUserId+uId);
    conversationId.setData({'dummy': 'dummy'});
    conversationId.collection('messages')
      .document(messageId).setData({
        'id': messageId,
        'from': uId,
        'text': message.trim(),
        'timeStamp': DateTime.now(),
        'to': otherUserId,
        'type': 0,
        'isDeleted': false
      });
  }

  @override
  Future<void> sendAttachments(String otherUserId, List<File> files) async {
    DocumentReference conversation;
    DocumentReference conversationId;
    String uId = SharedObjects.prefs.getString(Constants.sessionUid);
    List<String> images = [];
    List<String> videos = [];
    List<String> otherFiles = [];
    await Future.wait(files.map((file) async {
      StorageUploadTask uploadTask;
      String baseName = basename(file.path);
      String fileName = 'chat_'+baseName.split('.')[0]+Uuid().v4()+'.'+baseName.split('.')[1];
      uploadTask = storageRef.child(fileName).putFile(file);
      if (uploadTask != null) {
        StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
        String downloadUrl = await storageSnap.ref.getDownloadURL();
        filesUploaded.add(downloadUrl);
      }
    }));
    for (int i = 0; i < filesUploaded.length; i++) {
      if (filesUploaded[i].contains('jpg') || filesUploaded[i].contains('jpeg')
          || filesUploaded[i].contains('png') || filesUploaded[i].contains('gif')) {
        images.add(filesUploaded[i]);
      } else if (filesUploaded[i].contains('mp4')) {
        videos.add(filesUploaded[i]);
      } else { otherFiles.add(filesUploaded[i]); }
    }
    if (images.isNotEmpty) {
      String messageId = await calcMessageId(uId, uId+otherUserId);
      conversation = chatsRef.document(uId);
      conversation.setData({'dummy': 'dummy'});
      conversationId = conversation.collection('conversations')
        .document(uId+otherUserId);
      conversationId.setData({'dummy': 'dummy'});
      conversationId.collection('messages').document(messageId)
        .setData({'id': messageId, 'from': uId, 'images': images,
          'timeStamp': DateTime.now(), 'to': otherUserId, 'type': 1,
          'isDeleted': false
        });
      conversation = chatsRef.document(otherUserId);
      conversation.setData({'dummy': 'dummy'});
      conversationId = conversation.collection('conversations')
        .document(otherUserId+uId);
      conversationId.setData({'dummy': 'dummy'});
      conversationId.collection('messages').document(messageId)
        .setData({'id': messageId, 'from': uId, 'images': images,
          'timeStamp': DateTime.now(), 'to': otherUserId, 'type': 1,
          'isDeleted': false
        });
    }
    if (videos.isNotEmpty) {
      String messageId = await calcMessageId(uId, uId+otherUserId);
      conversation = chatsRef.document(uId);
      conversation.setData({'dummy': 'dummy'});
      conversationId = conversation.collection('conversations')
        .document(uId+otherUserId);
      conversationId.setData({'dummy': 'dummy'});
      conversationId.collection('messages').document(messageId)
        .setData({'id': messageId, 'from': uId, 'videos': videos,
          'timeStamp': DateTime.now(), 'to': otherUserId, 'type': 2,
          'isDeleted': false
        });
      conversation = chatsRef.document(otherUserId);
      conversation.setData({'dummy': 'dummy'});
      conversationId = conversation.collection('conversations')
        .document(otherUserId+uId);
      conversationId.setData({'dummy': 'dummy'});
      conversationId.collection('messages').document(messageId)
        .setData({'id': messageId, 'from': uId, 'videos': videos,
          'timeStamp': DateTime.now(), 'to': otherUserId, 'type': 2,
          'isDeleted': false
        });
    }
    if (otherFiles.isNotEmpty) {
      String messageId = await calcMessageId(uId, uId+otherUserId);
      conversation = chatsRef.document(uId);
      conversation.setData({'dummy': 'dummy'});
      conversationId = conversation.collection('conversations')
        .document(uId+otherUserId);
      conversationId.setData({'dummy': 'dummy'});
      conversationId.collection('messages').document(messageId)
        .setData({'id': messageId, 'from': uId, 'files': otherFiles,
          'timeStamp': DateTime.now(), 'to': otherUserId, 'type': 3,
          'isDeleted': false
        });
      conversation = chatsRef.document(otherUserId);
      conversation.setData({'dummy': 'dummy'});
      conversationId = conversation.collection('conversations')
          .document(otherUserId+uId);
      conversationId.setData({'dummy': 'dummy'});
      conversationId.collection('messages').document(messageId)
        .setData({'id': messageId, 'from': uId, 'files': otherFiles,
          'timeStamp': DateTime.now(), 'to': otherUserId, 'type': 3,
          'isDeleted': false
        });
    }
  }

  Future<String> calcMessageId(userId, conversationId) async {
    QuerySnapshot snapshot = await chatsRef
      .document(userId).collection('conversations')
      .document(conversationId).collection('messages')
      .orderBy('timeStamp', descending: true).limit(1).getDocuments();
    if (snapshot.documents.isNotEmpty) {
      int lastId = int.parse(snapshot.documents[0].documentID);
      return (lastId + 1).toString();
    } else { return '0'; }
  }

  Future<void> deleteMessage(conversationId, messageId) async {
    String uId = SharedObjects.prefs.getString(Constants.sessionUid);
    String otherUserId = conversationId.split(uId)[1];
    await chatsRef.document(uId)
      .collection('conversations').document(conversationId)
      .collection('messages').document(messageId)
      .updateData({'isDeleted': true});
    await chatsRef.document(otherUserId)
      .collection('conversations').document(otherUserId+uId)
      .collection('messages').document(messageId)
      .updateData({'isDeleted': true});
  }
}
