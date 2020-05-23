import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isocial_messenger/blocs/chat/Bloc.dart';
import 'package:isocial_messenger/models/Chat.dart';
import 'package:isocial_messenger/widgets/InputWidget.dart';

import 'ConversationPage.dart';

class ConversationPageSlide extends StatefulWidget {
  final List<Chat> chatList;
  final int chatIndex;

  ConversationPageSlide(this.chatList, this.chatIndex);

  @override
  State<StatefulWidget> createState() {
    return ConversationPageSlideState(this.chatList, this.chatIndex);
  }
}

class ConversationPageSlideState extends State<ConversationPageSlide>
    with SingleTickerProviderStateMixin {
  var controller;
  PageController pageController = PageController();
  final List<Chat> chatList;
  int chatIndex;
  ChatBloc chatBloc;
  static final scaffoldKey = GlobalKey<ScaffoldState>();

  ConversationPageSlideState(this.chatList, this.chatIndex);

  @override
  void initState() {
    super.initState();
    chatBloc = BlocProvider.of<ChatBloc>(context);
    if (chatIndex != 0) {
      pageController = PageController(initialPage: chatIndex ?? 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          InputWidgetState obj = new InputWidgetState(
            uId: chatList[chatIndex].user.id
          );
          if (!obj.showEmojiKeyboard) {
            chatBloc.dispatch(FetchChatListEvent());
            Navigator.pop(context);
            return Future.value(false);
          } else {
            obj.setState(() {
              obj.showEmojiKeyboard = false;
            });
          }
        },
        child: Scaffold(
          key: scaffoldKey,
          body: Column(
            children: <Widget>[
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: chatList.length,
                  onPageChanged: (index) {
                    chatBloc.dispatch(PageChangedEvent(
                      chatList[index].user.id
                    ));
                  },
                  itemBuilder: (bc, index) => ConversationPage(chatList[index]),
                )
              ),
              Container(child: InputWidget(chatList[chatIndex].user.id))
            ]
          )
        )
      )
    );
  }
}
