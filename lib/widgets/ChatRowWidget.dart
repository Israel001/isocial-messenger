import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isocial_messenger/config/Constants.dart';
import 'package:isocial_messenger/config/Transitions.dart';
import 'package:isocial_messenger/pages/ConversationPageSlide.dart';
import 'package:isocial_messenger/utils/SharedObjects.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:isocial_messenger/blocs/chat/Bloc.dart';
import 'package:isocial_messenger/config/Styles.dart';
import 'package:isocial_messenger/models/Chat.dart';

// ignore: must_be_immutable
class ChatRowWidget extends StatelessWidget {
  final List<Chat> chatList;
  final Chat chat;
  final int index;
  String date;
  ChatBloc chatBloc;
  String uid = SharedObjects.prefs.getString(Constants.sessionUid);

  ChatRowWidget(this.chatList, this.chat, this.index);

  String configureMessage() {
    String msg = 'No message';
    if (chat.textMessage != null) {
      if (chat.textMessage.from == chat.user.id) {
        msg = chat.textMessage.text;
      } else {
        msg = 'You: ${chat.textMessage.text}';
      }
      date = chat.textMessage.timeStamp.toDate().day > 1
          ? DateFormat.yMMMMd().format(chat.textMessage.timeStamp.toDate())
          : timeago.format(chat.textMessage.timeStamp.toDate());
    } else if (chat.imageMessage != null) {
      if (chat.imageMessage.from == chat.user.id) {
        msg = '${chat.user.displayName} sent a photo';
      } else {
        msg = 'You sent a photo';
      }
      date = chat.imageMessage.timeStamp.toDate().day > 1
          ? DateFormat.yMMMMd().format(chat.imageMessage.timeStamp.toDate())
          : timeago.format(chat.imageMessage.timeStamp.toDate());
    } else if (chat.videoMessage != null) {
      if (chat.videoMessage.from == chat.user.id) {
        msg = '${chat.user.displayName} sent a video';
      } else {
        msg = 'You sent a video';
      }
      date = chat.videoMessage.timeStamp.toDate().day > 1
          ? DateFormat.yMMMMd().format(chat.videoMessage.timeStamp.toDate())
          : timeago.format(chat.videoMessage.timeStamp.toDate());
    } else if (chat.fileMessage != null) {
      if (chat.fileMessage.from == chat.user.id) {
        msg = '${chat.user.displayName} sent a file';
      } else {
        msg = 'You sent a file';
      }
      date = chat.fileMessage.timeStamp.toDate().day > 1
          ? DateFormat.yMMMMd().format(chat.fileMessage.timeStamp.toDate())
          : timeago.format(chat.fileMessage.timeStamp.toDate());
    }
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    configureMessage();
    return Column(
      children: <Widget>[
        ListTile(
          onTap: () {
            Navigator.push(
              context, SlideLeftRoute(
                page: ConversationPageSlide(chatList, index)
              )
            );
          },
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: CachedNetworkImageProvider(chat.user.photoUrl)
          ),
          title: Text(
            chat.user.displayName,
            style: Theme.of(context).textTheme.body1
          ),
          subtitle: Text(
            configureMessage(),
            style: Styles.subText
          ),
          trailing: date != null ? Text(date, style: Styles.date) : Text('')
        ),
        Divider(color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white : Colors.black45 )
      ]
    );
  }
}
