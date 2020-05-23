import 'package:cloud_firestore/cloud_firestore.dart';

class TextMessage {
  final String id;
  final String from;
  final String to;
  final Timestamp timeStamp;
  final String text;

  TextMessage({this.id, this.from, this.to, this.timeStamp, this.text});

  factory TextMessage.fromDocument(DocumentSnapshot doc) {
    return TextMessage(
      id: doc['id'],
      from: doc['from'],
      to: doc['to'],
      timeStamp: doc['timeStamp'],
      text: doc['text']
    );
  }
}

class ImageMessage{
  final String id;
  final String from;
  final String to;
  final Timestamp timeStamp;
  final dynamic images;

  ImageMessage({this.id, this.from, this.to, this.timeStamp, this.images});

  factory ImageMessage.fromDocument(DocumentSnapshot doc) {
    return ImageMessage(
      id: doc['id'],
      from: doc['from'],
      to: doc['to'],
      timeStamp: doc['timeStamp'],
      images: doc['images']
    );
  }
}

class VideoMessage {
  final String from;
  final String to;
  final Timestamp timeStamp;
  final dynamic videos;

  VideoMessage({this.from, this.to, this.timeStamp, this.videos});

  factory VideoMessage.fromDocument(DocumentSnapshot doc) {
    return VideoMessage(
      from: doc['from'],
      to: doc['to'],
      timeStamp: doc['timeStamp'],
      videos: doc['videos']
    );
  }
}

class FileMessage {
  final String id;
  final String from;
  final String to;
  final Timestamp timeStamp;
  final dynamic files;

  FileMessage({this.id, this.from, this.to, this.timeStamp, this.files});

  factory FileMessage.fromDocument(DocumentSnapshot doc) {
    return FileMessage(
      id: doc['id'],
      from: doc['from'],
      to: doc['to'],
      timeStamp: doc['timeStamp'],
      files: doc['files']
    );
  }
}
