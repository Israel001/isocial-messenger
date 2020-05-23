import 'Message.dart';
import 'User.dart';

class Chat {
  String id;
  User user;
  TextMessage textMessage;
  ImageMessage imageMessage;
  VideoMessage videoMessage;
  FileMessage fileMessage;

  Chat(
    this.id,
    this.user,
    {this.textMessage, this.imageMessage, this.videoMessage, this.fileMessage}
  );
}
