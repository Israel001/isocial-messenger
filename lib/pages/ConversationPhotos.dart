import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isocial_messenger/config/Constants.dart';
import 'package:isocial_messenger/models/Message.dart';
import 'package:isocial_messenger/utils/SharedObjects.dart';
import 'package:isocial_messenger/widgets/ProgressWidget.dart';

// ignore: must_be_immutable
class ConversationPhotos extends StatefulWidget {
  final String conversationId;
  int photoIndex = 0;

  ConversationPhotos(this.conversationId, { this.photoIndex });

  @override
  State<StatefulWidget> createState() {
    return ConversationPhotosState(this.conversationId);
  }
}

class ConversationPhotosState extends State<ConversationPhotos> {
  PageController pageController = PageController();
  static List<String> images = [];
  final chatsRef = Firestore.instance.collection('chats');
  String uId = SharedObjects.prefs.getString(Constants.sessionUid);
  final String conversationId;
  bool showOptions = false;

  ConversationPhotosState(this.conversationId);

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photoIndex != 0) {
      pageController = PageController(initialPage: widget.photoIndex ?? 0);
    }
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: StreamBuilder(
          stream: chatsRef
            .document(uId).collection('conversations')
            .document(conversationId).collection('messages')
            .where('type', isEqualTo: 1).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: circularProgress(context));
            }
            snapshot.data.documents.forEach((doc) {
              ImageMessage message = ImageMessage.fromDocument(doc);
              for (int i = 0; i < message.images.length; i++) {
                if (!images.contains(message.images[i])) {
                  images.add(message.images[i]);
                }
              }
            });
            return PageView.builder(
              controller: pageController,
              itemCount: images.length,
              itemBuilder: (bc, index) => Container(
                color: Colors.black,
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      child: Hero(
                        tag: 'Image',
                        child: CachedNetworkImage(imageUrl: images[index])
                      ),
                      onTap: () => setState(() => showOptions = !showOptions),
                    ),
                    !showOptions ? Text('') : Container(
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
                    ),
                    !showOptions ? Text('') : Positioned(
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
                    ),
                    !showOptions ? Text('') : Positioned(
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
                            images[index]
                          ),
                        )
                      )
                    ),
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
