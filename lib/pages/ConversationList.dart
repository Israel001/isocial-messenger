import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:isocial_messenger/config/Assets.dart';
import 'package:isocial_messenger/config/Constants.dart';
import 'package:isocial_messenger/blocs/chat/Bloc.dart';
import 'package:isocial_messenger/models/Chat.dart';
import 'package:isocial_messenger/utils/SharedObjects.dart';
import 'package:isocial_messenger/widgets/ChatRowWidget.dart';
import 'package:isocial_messenger/widgets/ProgressWidget.dart';

import 'ProfilePage.dart';
import 'SearchPage.dart';

class ConversationList extends StatefulWidget {
  final Chat chat;

  ConversationList({this.chat});

  @override
  State<StatefulWidget> createState() {
    return _ConversationListState();
  }
}

class _ConversationListState extends State<ConversationList>
    with AutomaticKeepAliveClientMixin {
  final usersRef = Firestore.instance.collection('users');
  var image, uid;
  ChatBloc chatBloc;
  Widget element;
  FocusNode focusNode = FocusNode();
  List<Widget> chats = [];

  @override
  void initState() {
    super.initState();
    final fbm = FirebaseMessaging();
    fbm.configure(
      onMessage: (msg) {
        print(msg);
      },
      onLaunch: (msg) {},
      onResume: (msg) {}
    );
    chatBloc = BlocProvider.of<ChatBloc>(context);
    chatBloc.dispatch(FetchChatListEvent());
    chatBloc.state.listen((state) {
      if (mounted) {
        setState(() {
          if (state is FetchedChatListState) {
            for (int i = 0; i < state.chatList.length; i++) {
              fbm.subscribeToTopic(state.chatList[i].id);
            }
            element = ListView(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                children: buildChatRowWidgets(state.chatList)
            );
          } else if (state is NoChats && widget.chat != null) {
            fbm.subscribeToTopic(widget.chat.id);
            element = ListView(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              children: buildChatRowWidgets([]),
            );
          } else {
            element = Container(
                margin: EdgeInsets.only(
                    top: (MediaQuery
                        .of(context)
                        .size
                        .height / 2) - 150.0
                ),
                child: circularProgress(context)
            );
          }
        });
      }
    });
    setState(() {
      image = SharedObjects.prefs.getString(Constants.sessionPhoto);
      uid = SharedObjects.prefs.getString(Constants.sessionUid);
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  buildChatRowWidgets(List<Chat> chatList) {
    chats.clear();
    if (widget.chat != null) chatList.insert(0, widget.chat);
    for (int i = 0; i < chatList.length; i++) {
      chats.add(ChatRowWidget(chatList, chatList[i], i));
    }
    return chats;
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: ListView(
        children: <Widget>[
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage()
                )
              );
            },
            leading: CircleAvatar(
              backgroundImage: image != null
                  ? CachedNetworkImageProvider(image)
                  : AssetImage(Assets.user),
              backgroundColor: Colors.grey,
            ),
            title: Text(
              'Chats',
              style: Theme.of(context).textTheme.title
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 20.0)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50.0))
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50.0))
                ),
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 5.0),
              ),
              focusNode: focusNode,
              onTap: () {
                focusNode.unfocus();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage()
                  )
                );
              },
            )
          ),
          Padding(padding: EdgeInsets.only(top: 30.0)),
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is NoChats) {
                return Container(
                  margin: EdgeInsets.only(
                    top: (MediaQuery.of(context).size.height / 2) - 150.0
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Get started',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0
                        )
                      ),
                      Padding(padding: EdgeInsets.only(top: 10.0)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text(
                          'Search for people and start a conversation with them',
                          style: TextStyle(color: Theme.of(context).hintColor),
                          textAlign: TextAlign.center,
                        )
                      )
                    ],
                  )
                );
              } else {
                return element != null ? element : Text('');
              }
            }
          )
        ],
      )
    );
  }
}
