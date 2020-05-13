import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/services/auth_base.dart';

class FakeAuthenticationService implements AuthBase {
  String userID = '849123';

  @override
  Future<User> currentUser() async {
    return Future.value(User(userID: userID, email: 'fakeuser@assistify.com'));
  }

  @override
  Future<bool> signOut() {
    return Future.value(true);
  }

  @override
  Future<User> signInAnonymously() async {
    return await Future.delayed(Duration(seconds: 2),
        () => User(userID: userID, email: 'fakeuser@assistify.com'));
  }

  @override
  Future<User> signInWithGoogle() async {
    return await Future.delayed(
        Duration(seconds: 2),
        () => User(
            userID: 'google_user_ID: goog.3+ff',
            email: 'fakeuser@assistify.com'));
  }

  @override
  Future<User> signInWithFacebook() async {
    return await Future.delayed(
        Duration(seconds: 2),
        () => User(
            userID: 'facebook_user_ID: faceb.s?*ldf82',
            email: 'fakeuser@assistify.com'));
  }

  @override
  Future<User> createUserWithEmailAndPassword(
      String email, String password) async {
    return await Future.delayed(
        Duration(seconds: 2),
        () => User(
            userID: 'created_user_ID: mail.bd?*ldf82',
            email: 'fakeuser@assistify.com'));
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    return await Future.delayed(
        Duration(seconds: 2),
        () => User(
            userID: 'signedIn_user_ID: mail.bd?*ldf82',
            email: 'fakeuser@assistify.com'));
  }
}
