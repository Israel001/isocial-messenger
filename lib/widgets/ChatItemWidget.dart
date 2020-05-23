import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isocial_messenger/blocs/chat/Bloc.dart';
import 'package:isocial_messenger/pages/ConversationFiles.dart';
import 'package:isocial_messenger/pages/ConversationPageSlide.dart';
import 'package:isocial_messenger/pages/ConversationPhotos.dart';
import 'package:isocial_messenger/pages/ConversationVideos.dart';
import 'package:isocial_messenger/widgets/ProgressWidget.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:isocial_messenger/config/Constants.dart';
import 'package:isocial_messenger/config/Palette.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import 'package:isocial_messenger/config/Styles.dart';
import 'package:isocial_messenger/models/Message.dart';
import 'package:isocial_messenger/utils/SharedObjects.dart';

class ChatItemWidget extends StatefulWidget {
  final message;
  final conversationId;

  ChatItemWidget(this.message, this.conversationId);

  @override
  State<StatefulWidget> createState() {
    return ChatItemWidgetState(this.message, this.conversationId);
  }
}

class ChatItemWidgetState extends State<ChatItemWidget> {
  final message;
  final conversationId;
  String uId = SharedObjects.prefs.getString(Constants.sessionUid);
  bool showTime = false;
  ChatBloc chatBloc;

  ChatItemWidgetState(this.message, this.conversationId);

  @override
  void initState() {
    super.initState();
    chatBloc = BlocProvider.of<ChatBloc>(context);
  }

  Row buildMessageContainer(bool isSelf, BuildContext context) {
    double lrEdgeInsets = 1.0;
    double tbEdgeInsets = 1.0;
    if (message.runtimeType == TextMessage) {
      lrEdgeInsets = 15.0;
      tbEdgeInsets = 10.0;
    }
    return Row(
      children: <Widget>[
        Container(
          child: buildMessageContent(isSelf, context),
          padding: EdgeInsets.fromLTRB(
            lrEdgeInsets, tbEdgeInsets, lrEdgeInsets, tbEdgeInsets
          ),
          constraints: BoxConstraints(maxWidth: 200.0),
          decoration: BoxDecoration(
            color: isSelf
                ? Palette.selfMessageBackgroundColor
                : Color.fromARGB(200, 241, 240, 240),
            borderRadius: BorderRadius.circular(8.0)
          ),
          margin: EdgeInsets.only(
            right: isSelf ? 10.0 : 0,
            left: isSelf ? 0 : 10.0
          )
        )
      ],
      mainAxisAlignment: isSelf
        ? MainAxisAlignment.end : MainAxisAlignment.start,
    );
  }

  buildMessageContent(bool isSelf, BuildContext context) {
    if (message.runtimeType == TextMessage) {
      return GestureDetector(
        onTap: () => setState(() => showTime = !showTime),
        onLongPress: () {
          ConversationPageSlideState.scaffoldKey.currentState.showBottomSheet(
            (context) {
              return Container(
                height: 80,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.content_copy),
                            onPressed: () {
                              Navigator.pop(context);
                              Clipboard.setData(
                                new ClipboardData(text: message.text)
                              );
                              ConversationPageSlideState.scaffoldKey.currentState.showSnackBar(
                                SnackBar(
                                  content: Text('Text copied to clipboard!')
                                )
                              );
                            },
                          ),
                          Text('Copy')
                        ],
                      )
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.forward),
                            onPressed: () {},
                          ),
                          Text('Forward')
                        ],
                      )
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              Navigator.pop(context);
                              chatBloc.dispatch(DeleteMessageEvent(
                                message.id, conversationId
                              ));
                            },
                          ),
                          Text('Remove')
                        ],
                      )
                    )
                  ],
                ),
              );
            }
          );
        },
        child: Text(
          message.text,
          style: TextStyle(
            color: isSelf ? Palette.selfMessageColor : Palette.otherMessageColor
          )
        )
      );
    } else if (message.runtimeType == ImageMessage) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConversationPhotos(
                conversationId,
                photoIndex: ConversationPhotosState.images.indexOf(
                  message.images[0]
                ),
              )
            )
          );
        },
        onDoubleTap: () => setState(() => showTime = !showTime),
        onLongPress: () {
          ConversationPageSlideState.scaffoldKey.currentState.showBottomSheet(
            (context) {
              return Container(
                height: 80,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.file_download),
                            onPressed: () {
                              Navigator.pop(context);
                              SharedObjects.downloadFile(message.images[0]);
                            },
                          ),
                          Text('Save Image')
                        ],
                      )
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.forward),
                            onPressed: () {},
                          ),
                          Text('Forward')
                        ],
                      )
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              Navigator.pop(context);
                              chatBloc.dispatch(DeleteMessageEvent(
                                message.id, conversationId
                              ));
                            },
                          ),
                          Text('Remove')
                        ],
                      )
                    )
                  ],
                ),
              );
            }
          );
        },
        child: Hero(
          tag: 'Image message',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(
              imageUrl: message.images[0],
              placeholder: (_, url) => circularProgress(context)
            )
          )
        )
      );
    } else if (message.runtimeType == VideoMessage) {
      VideoPlayerController controller = VideoPlayerController.network(
        message.videos[0]
      );
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            GestureDetector(
              onTap: () => setState(() => showTime = !showTime),
              onLongPress: () {
                ConversationPageSlideState.scaffoldKey.currentState.showBottomSheet(
                  (context) {
                    return Container(
                      height: 80,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.file_download),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    SharedObjects.downloadFile(
                                      message.videos[0]
                                    );
                                  },
                                ),
                                Text('Save Video')
                              ],
                            )
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.forward),
                                  onPressed: () {},
                                ),
                                Text('Forward')
                              ],
                            )
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    chatBloc.dispatch(DeleteMessageEvent(
                                      message.id, conversationId
                                    ));
                                  },
                                ),
                                Text('Remove')
                              ],
                            )
                          )
                        ],
                      ),
                    );
                  }
                );
              },
              child: AspectRatio(
                aspectRatio: 300 / 300,
                child: FutureBuilder(
                  future: controller.initialize(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return VideoPlayer(controller);
                    }
                    return circularProgress(context);
                  }
                )
              )
            ),
            Container(
              height: 40,
              child: IconButton(
                icon: Icon(
                  Icons.play_arrow,
                  color: isSelf
                    ? Palette.selfMessageColor : Palette.otherMessageColor
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConversationVideos(
                        conversationId,
                        videoIndex: ConversationVideosState.videos.indexOf(
                          message.videos[0]
                        ),
                      )
                    )
                  );
                },
              )
            )
          ],
        )
      );
    } else if (message.runtimeType == FileMessage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConversationFiles(
                      conversationId,
                      fileIndex: ConversationFilesState.files.indexOf(
                        message.files[0]
                      )
                    )
                  )
                );
              },
              onDoubleTap: () => setState(() => showTime = !showTime),
              onLongPress: () {
                ConversationPageSlideState.scaffoldKey.currentState.showBottomSheet(
                  (context) {
                    return Container(
                      height: 80,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.file_download),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    SharedObjects.downloadFile(
                                      message.files[0]
                                    );
                                  },
                                ),
                                Text('Save File')
                              ],
                            )
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.forward),
                                  onPressed: () {},
                                ),
                                Text('Forward')
                              ],
                            )
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    chatBloc.dispatch(DeleteMessageEvent(
                                      message.id, conversationId
                                    ));
                                  },
                                ),
                                Text('Remove')
                              ],
                            )
                          )
                        ],
                      ),
                    );
                  }
                );
              },
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  Container(
                    color: Palette.secondaryColor,
                    height: 80
                  ),
                  Column(
                    children: <Widget>[
                      Icon(
                        Icons.insert_drive_file,
                        color: Palette.primaryColor
                      ),
                      SizedBox(height: 5),
                      Text(
                        SharedObjects.extractFileName(message.files[0]),
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelf
                            ? Palette.selfMessageColor
                            : Palette.otherMessageColor
                        ),
                        overflow: TextOverflow.ellipsis
                      )
                    ],
                  )
                ],
              )
            ),
            Container(
              height: 40,
              child: IconButton(
                icon: Icon(
                  Icons.file_download,
                  color: isSelf
                    ? Palette.selfMessageColor : Palette.otherMessageColor
                ),
                onPressed: () => SharedObjects.downloadFile(message.files[0]),
              )
            )
          ],
        )
      );
    }
  }

  Widget buildTimeStamp(bool isSelf, BuildContext context) {
    return showTime ? Row(
      mainAxisAlignment: isSelf
        ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Text(
            message.timeStamp.toDate().day > 1
                ? DateFormat.yMMMMd().format(message.timeStamp.toDate())
                + ' at '+DateFormat.Hm().format(message.timeStamp.toDate())
                : timeago.format(message.timeStamp.toDate()),
            style: Styles.date
          ),
          margin: EdgeInsets.only(
            left: isSelf ? 5.0 : 0.0,
            right: isSelf ? 0.0 : 5.0,
            top: 5.0, bottom: 5.0
          )
        )
      ],
    ) : Text('');
  }

  @override
  Widget build(BuildContext context) {
    bool isSelf = message.from == uId;
    return Container(
      child: Column(
        children: <Widget>[
          buildMessageContainer(isSelf, context),
          buildTimeStamp(isSelf, context)
        ],
      )
    );
  }
}
