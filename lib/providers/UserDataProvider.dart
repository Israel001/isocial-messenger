import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isocial_messenger/config/Constants.dart';
import 'package:isocial_messenger/config/Paths.dart';
import 'package:isocial_messenger/models/User.dart';
import 'package:isocial_messenger/providers/BaseProviders.dart';
import 'package:isocial_messenger/utils/Exceptions.dart';
import 'package:isocial_messenger/utils/SharedObjects.dart';

class UserDataProvider extends BaseUserDataProvider {
  final Firestore fireStoreDb;
  final usersRef = Firestore.instance.collection('users');

  UserDataProvider({
    Firestore fireStoreDb
  }) : fireStoreDb = fireStoreDb ?? Firestore.instance;

  @override
  Future<User> getUser(String username) async {
    String uid = await getUidByUsername(username);
    DocumentReference ref = fireStoreDb
      .collection(Paths.usersPath).document(uid);
    DocumentSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      return User.fromDocument(snapshot);
    } else {
      throw UserNotFoundException();
    }
  }

  @override
  Future<String> getUidByUsername(String username) async {
    QuerySnapshot user = await usersRef
      .where('username', isEqualTo: username)
      .getDocuments();
    if (user != null && user.documents != null && user.documents.length > 0) {
      return user.documents[0].documentID;
    } else {
      throw UsernameMappingUndefinedException();
    }
  }

  @override
  Future<void> cacheUserData(User user) async {
    await SharedObjects.prefs.setString(Constants.sessionUid, user.id);
    await SharedObjects.prefs.setString(Constants.sessionUsername, user.username);
    await SharedObjects.prefs.setString(Constants.sessionName, user.displayName);
    await SharedObjects.prefs.setString(Constants.sessionPhoto, user.photoUrl);
  }

  @override
  Future<void> clearUserDataCache() async {
    await SharedObjects.prefs.setString(Constants.sessionUid, null);
    await SharedObjects.prefs.setString(Constants.sessionUsername, null);
    await SharedObjects.prefs.setString(Constants.sessionName, null);
    await SharedObjects.prefs.setString(Constants.sessionPhoto, null);
    await SharedObjects.prefs.setString(Constants.sessionPassword, null);
    await SharedObjects.prefs.setString(Constants.signInMethod, null);
  }
}
