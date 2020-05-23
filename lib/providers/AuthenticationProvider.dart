import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isocial_messenger/config/Constants.dart';
import 'package:isocial_messenger/models/User.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isocial_messenger/utils/SharedObjects.dart';

import 'BaseProviders.dart';

class AuthenticationProvider extends BaseAuthenticationProvider {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final usersRef = Firestore.instance.collection('users');
  var currentUser;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<dynamic> signInWithGoogle() async {
    final GoogleSignInAccount user = await googleSignIn.signIn();
    DocumentSnapshot doc = await usersRef.document(user.id).get();
    if (!doc.exists) return 'User does not exist';
    return currentUser = User.fromDocument(doc);
  }

  Future<dynamic> signInWithPassword(email, password) async {
    FirebaseUser user = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password
    );
    if (user.isEmailVerified) {
      await SharedObjects.prefs.setString(Constants.sessionUid, user.uid);
      await SharedObjects.prefs.setString(Constants.sessionPassword, password);
      await SharedObjects.prefs.setString(Constants.signInMethod, 'password');
      DocumentSnapshot doc = await usersRef.document(user.uid).get();
      if (!doc.exists) return 'User does not exist';
      return currentUser = User.fromDocument(doc);
    } else {
      return 'User email is not verified';
    }
  }

  Future<void> signOutUser() async {
    if (SharedObjects.prefs.getString(Constants.signInMethod) == 'password') {
      return Future.wait([ firebaseAuth.signOut() ]);
    } else {
      return Future.wait([ googleSignIn.signOut() ]);
    }
  }

  Future<User> getCurrentUser() async {
    return currentUser;
  }

  Future<bool> isLoggedIn() async {
    String userId = SharedObjects.prefs.getString(Constants.sessionUid);
    if (userId != null) {
      currentUser = User.fromDocument(await usersRef.document(userId).get());
    } else {
      final GoogleSignInAccount user = await googleSignIn.signInSilently(
        suppressErrors: false
      );
      currentUser = User.fromDocument(await usersRef.document(user.id).get());
      return user != null;
    }
    return userId != null;
  }
}
