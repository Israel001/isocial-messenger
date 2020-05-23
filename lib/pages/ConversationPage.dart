import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isocial_messenger/blocs/chat/Bloc.dart';
import 'package:isocial_messenger/config/Constants.dart';
import 'package:isocial_messenger/config/Palette.dart';
import 'package:isocial_messenger/models/Chat.dart';
import 'package:isocial_messenger/utils/SharedObjects.dart';
import 'package:isocial_messenger/widgets/ChatAppBar.dart';
import 'package:isocial_messenger/widgets/ChatListWidget.dart';

class ConversationPage extends StatefulWidget {
  final Chat chat;

  ConversationPage(this.chat);

  @override
  State<StatefulWidget> createState() {
    return _ConversationPageState(this.chat);
  }
}

class _ConversationPageState extends State<ConversationPage> 
    with AutomaticKeepAliveClientMixin {
  ChatBloc chatBloc;
  final Chat chat;
  String uId = SharedObjects.prefs.getString(Constants.sessionUid);

  _ConversationPageState(this.chat);

  @override
  void initState() {
    super.initState();
    chatBloc = BlocProvider.of<ChatBloc>(context);
  }
  
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    print(uId+chat.user.id);
    super.build(context);
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 100),
          color: Theme.of(context).backgroundColor,
          child: ChatListWidget(uId+chat.user.id)
        ),
        SizedBox.fromSize(
          size: Size.fromHeight(100),
          child: ChatAppBar(chat)
        )
      ]
    );
  }
}
