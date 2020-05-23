import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:isocial_messenger/config/Constants.dart';
import 'package:isocial_messenger/pages/ConversationFiles.dart';
import 'package:isocial_messenger/pages/ConversationPageSlide.dart';
import 'package:isocial_messenger/blocs/chat/Bloc.dart';
import 'package:isocial_messenger/config/Assets.dart';
import 'package:isocial_messenger/models/Chat.dart';
import 'package:isocial_messenger/pages/ConversationPhotos.dart';
import 'package:isocial_messenger/pages/ConversationVideos.dart';
import 'package:isocial_messenger/utils/SharedObjects.dart';

class ChatAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double height = 100;
  final Chat chat;

  ChatAppBar(this.chat);

  @override
  _ChatAppBarState createState() => _ChatAppBarState(this.chat);

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _ChatAppBarState extends State<ChatAppBar> {
  String username = '';
  String name = '';
  dynamic image = Image.asset(Assets.user);
  ChatBloc chatBloc;
  final Chat chat;
  String uId = SharedObjects.prefs.getString(Constants.sessionUid);

  _ChatAppBarState(this.chat);

  @override
  void initState() {
    super.initState();
    chatBloc = BlocProvider.of<ChatBloc>(context);
    setState(() {
      image = CachedNetworkImageProvider(chat.user.photoUrl);
      name = chat.user.displayName;
      username = chat.user.username;
    });
  }

  showFilePicker() async {
    List<File> files = [];
    files = await FilePicker.getMultiFile();
    if (files.contains(null)) return;
    chatBloc.dispatch(SendAttachmentEvent(chat.user.id, files));
    SnackBar snackBar = SnackBar(
      content: Text('Sending attachment(s)...', overflow: TextOverflow.ellipsis),
      backgroundColor: Colors.red,
      duration: Duration(milliseconds: 3000)
    );
    ConversationPageSlideState.scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).hintColor,
              blurRadius: 2.0,
              spreadRadius: 0.1
            )
          ]
        ),
        child: Container(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          color: Theme.of(context).primaryColor,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 7,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: IconButton(
                                    icon: Icon(Icons.attach_file,),
                                    onPressed: () => showFilePicker(),
                                  )
                                )
                              ),
                              Expanded(
                                flex: 6,
                                child: Container(
                                  child: BlocBuilder<ChatBloc, ChatState>(
                                    builder: (context, state) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            name,
                                            style: Theme.of(context).textTheme.title
                                          ),
                                          Text(
                                            '@'+username,
                                            style: Theme.of(context)
                                              .textTheme.subtitle.copyWith(
                                              fontSize: 13.0
                                            )
                                          )
                                        ],
                                      );
                                    }
                                  )
                                )
                              ),
                            ],
                          )
                        )
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(20, 5, 5, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                child: Text(
                                  'Photos',
                                  style: Theme.of(context).textTheme.button
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ConversationPhotos(
                                        uId+chat.user.id
                                      )
                                    )
                                  );
                                }
                              ),
                              VerticalDivider(
                                width: 30,
                                color: Theme.of(context).textTheme.button.color
                              ),
                              GestureDetector(
                                child: Text(
                                  'Videos',
                                  style: Theme.of(context).textTheme.button
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ConversationVideos(
                                        uId+chat.user.id
                                      )
                                    )
                                  );
                                }
                              ),
                              VerticalDivider(
                                width: 30,
                                color: Theme.of(context).textTheme.button.color
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ConversationFiles(
                                        uId+chat.user.id
                                      )
                                    )
                                  );
                                },
                                child: Text(
                                  'Files',
                                  style: Theme.of(context).textTheme.button
                                )
                              )
                            ],
                          )
                        )
                      )
                    ],
                  )
                )
              ),
              Expanded(
                flex: 3,
                child: Container(
                  child: Center(
                    child: BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        return CircleAvatar(
                          radius: 30,
                          backgroundImage: image.runtimeType == Image
                              ? image.image : image,
                        );
                      }
                    )
                  )
                )
              )
            ],
          )
        )
      )
    );
  }
}
