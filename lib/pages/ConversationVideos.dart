import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isocial_messenger/config/Constants.dart';
import 'package:isocial_messenger/models/Message.dart';
import 'package:isocial_messenger/utils/SharedObjects.dart';
import 'package:isocial_messenger/widgets/ProgressWidget.dart';
import 'package:isocial_messenger/widgets/VideoPlayerWidget.dart';

// ignore: must_be_immutable
class ConversationVideos extends StatefulWidget {
  final String conversationId;
  int videoIndex = 0;

  ConversationVideos(this.conversationId, { this.videoIndex });

  @override
  State<StatefulWidget> createState() {
    return ConversationVideosState(this.conversationId);
  }
}

class ConversationVideosState extends State<ConversationVideos> {
  PageController pageController = PageController();
  static List<String> videos = [];
  final chatsRef = Firestore.instance.collection('chats');
  String uId = SharedObjects.prefs.getString(Constants.sessionUid);
  final String conversationId;
  bool showOptions = false;

  ConversationVideosState(this.conversationId);

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoIndex != 0) {
      pageController = PageController(initialPage: widget.videoIndex ?? 0);
    }
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: StreamBuilder(
          stream: chatsRef
            .document(uId).collection('conversations')
            .document(conversationId).collection('messages')
            .where('type', isEqualTo: 2).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: circularProgress(context));
            }
            snapshot.data.documents.forEach((doc) {
              VideoMessage message = VideoMessage.fromDocument(doc);
              for (int i = 0; i < message.videos.length; i++) {
                if (!videos.contains(message.videos[i])) {
                  videos.add(message.videos[i]);
                }
              }
            });
            return PageView.builder(
              controller: pageController,
              itemCount: videos.length,
              itemBuilder: (bc, index) => Container(
                color: Colors.black,
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 2 - 200.0
                        ),
                        child: VideoPlayerWidget(
                          videoType: 'network', video: videos[index]
                        )
                      ),
                      onTap: () => setState(() => showOptions = false)
                    ),
                    showOptions ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(100, 0, 0, 0),
                            Color.fromARGB(100, 0, 0, 0),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter
                        )
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: 80
                    ) : Text(''),
                    showOptions ? Positioned(
                      top: 20.0,
                      left: 0.0,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30.0
                        ),
                        onPressed: () => Navigator.pop(context),
                      )
                    ) : Text(''),
                    showOptions ? Positioned(
                      top: 20.0,
                      right: 0.0,
                      child: Padding(
                        padding: EdgeInsets.only(right: 30.0),
                        child: IconButton(
                          icon: Icon(
                            Icons.file_download,
                            color: Colors.white,
                            size: 30.0
                          ),
                          onPressed: () => SharedObjects.downloadFile(
                            videos[index]
                          ),
                        )
                      )
                    ) : Text(''),
                  ]
                )
              )
            );
          }
        )
      )
    );
  }
}
