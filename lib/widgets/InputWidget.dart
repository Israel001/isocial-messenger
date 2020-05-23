import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:isocial_messenger/pages/ConversationPageSlide.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isocial_messenger/blocs/chat/Bloc.dart';

class InputWidget extends StatefulWidget {
  final String uId;

  InputWidget(this.uId);

  @override
  InputWidgetState createState() => InputWidgetState(uId: this.uId);
}

class InputWidgetState extends State<InputWidget> {
  String uId;
  final TextEditingController textEditingController = new TextEditingController();
  bool showEmojiKeyboard = false;
  bool textIsEmpty = true;
  ChatBloc chatBloc;

  InputWidgetState({this.uId});

  @override
  void initState() {
    super.initState();
    chatBloc = BlocProvider.of<ChatBloc>(context);
    chatBloc.state.listen((state) {
      if (state is PageChangedState) setState(() => uId = state.chatId);
    });
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        if (visible) setState(() => showEmojiKeyboard = false );
      }
    );
    textEditingController.addListener(() {
      if (textEditingController.text.isNotEmpty) {
        setState(() => textIsEmpty = false);
      } else {
        setState(() => textIsEmpty = true);
      }
    });
  }

  void sendMessage(context) {
    BlocProvider.of<ChatBloc>(context).dispatch(SendTextMessageEvent(
      uId, textEditingController.text
    ));
    textEditingController.clear();
  }

  Widget displayEmojiKeyboard() {
    FocusScope.of(context).requestFocus(new FocusNode());
    return EmojiPicker(
      rows: 4,
      columns: 7,
      bgColor: Theme.of(context).backgroundColor,
      indicatorColor: Theme.of(context).accentColor,
      onEmojiSelected: (emoji, category) {
        textEditingController.text = textEditingController.text+emoji.emoji;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(uId);
    return Material(
      elevation: 60.0,
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Material(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.0),
                    child: IconButton(
                      icon: Icon(Icons.face),
                      color: Theme.of(context).accentColor,
                      onPressed: () {
                        setState(() => showEmojiKeyboard = !showEmojiKeyboard);
                      },
                    )
                  ),
                  color: Theme.of(context).primaryColor
                ),
                Flexible(
                  child: Material(
                    child: Container(
                      color: Theme.of(context).primaryColor,
                      child: TextField(
                        style: Theme.of(context).textTheme.body2,
                        controller: textEditingController,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Type a message',
                          hintStyle: TextStyle(
                            color: Theme.of(context).hintColor
                          )
                        )
                      )
                    )
                  )
                ),
                Material(
                  child: Container(
                    child: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: textIsEmpty ? null : () => sendMessage(context),
                      color: Theme.of(context).accentColor,
                    )
                  ),
                  color: Theme.of(context).primaryColor
                ),
                textIsEmpty ? Material(
                  child: Container(
                    child: IconButton(
                      icon: Icon(Icons.photo_camera),
                      onPressed: () async {
                        List<File> files = [];
                        File image = await ImagePicker.pickImage(
                          source: ImageSource.camera
                        );
                        files.add(image);
                        if (!files.contains(null)) {
                          BlocProvider.of<ChatBloc>(context).dispatch(
                            SendAttachmentEvent(uId, files)
                          );
                          SnackBar snackBar = SnackBar(
                            content: Text('Sending attachment(s)...',
                            overflow: TextOverflow.ellipsis),
                            backgroundColor: Colors.red,
                            duration: Duration(milliseconds: 3000)
                          );
                          ConversationPageSlideState.scaffoldKey.currentState
                            .showSnackBar(snackBar);
                        }
                      },
                      color: Theme.of(context).accentColor,
                    )
                  ),
                  color: Theme.of(context).primaryColor
                ) : Text('')
              ],
            ),
            showEmojiKeyboard ? displayEmojiKeyboard() : Container()
          ]
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).hintColor, width: 0.5)
          ),
          color: Theme.of(context).primaryColor
        )
      )
    );
  }
}
