import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:isocial_messenger/providers/BaseProviders.dart';

class StorageProvider extends BaseStorageProvider {
  final FirebaseStorage firebaseStorage;

  StorageProvider({
    FirebaseStorage firebaseStorage
  }) : firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadFile(File file, String path) async {
    StorageReference reference = firebaseStorage.ref().child(path);
    StorageUploadTask uploadTask = reference.putFile(file);
    StorageTaskSnapshot result = await uploadTask.onComplete;
    String url = await result.ref.getDownloadURL();
    return url;
  }
}
