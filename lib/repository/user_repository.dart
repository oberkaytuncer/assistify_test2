import 'package:flutter_messaging_app/locator.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/services/auth_base.dart';
import 'package:flutter_messaging_app/services/fake_auth_service.dart';
import 'package:flutter_messaging_app/services/firabase_auth_service.dart';
import 'package:flutter_messaging_app/services/firestore_db_service.dart';

enum AppMode { DEBUG, RELEASE }

class UserRepository implements AuthBase {
  FirebaseAuthService _firebaseAuthService = locator<FirebaseAuthService>();
  FakeAuthenticationService _fakeAuthenticationService =
      locator<FakeAuthenticationService>();
  FirestoreDBService _firestoreDBService = locator<FirestoreDBService>();

  AppMode appMode = AppMode.RELEASE;

  @override
  Future<User> currentUser() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.currentUser();
    } else {
      User _user = await _firebaseAuthService.currentUser();

      User _readedUserFromFirestore =
          await _firestoreDBService.readUser(_user.userID);

      return _readedUserFromFirestore;
    }
  }

  @override
  Future<bool> signOut() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signOut();
    } else {
      return await _firebaseAuthService.signOut();
    }
  }

  @override
  Future<User> signInAnonymously() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signInAnonymously();
    } else {
      return await _firebaseAuthService.signInAnonymously();
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signInWithGoogle();
    } else {
      User _user = await _firebaseAuthService.signInWithGoogle();

      bool _result = await _firestoreDBService.saveUser(_user);

      if (_result == true) {
        User _readedUserFromFirestore =
            await _firestoreDBService.readUser(_user.userID);

        return _readedUserFromFirestore;
      }
    }
  }

  @override
  Future<User> signInWithFacebook() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signInWithFacebook();
    } else {
      User _user = await _firebaseAuthService.signInWithFacebook();

      bool _result = await _firestoreDBService.saveUser(_user);

      if (_result == true) {
        User _readedUserFromFirestore =
            await _firestoreDBService.readUser(_user.userID);

        return _readedUserFromFirestore;
      }
    }
  }

  @override
  Future<User> createUserWithEmailAndPassword(
      String email, String password) async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.createUserWithEmailAndPassword(
          email, password);
    } else {
      User _user = await _firebaseAuthService.createUserWithEmailAndPassword(
          email, password);

      bool _result = await _firestoreDBService.saveUser(_user);

      if (_result == true) {
        User _readedUserFromFirestore =
            await _firestoreDBService.readUser(_user.userID);

        return _readedUserFromFirestore;
      } else {
        return null;
      }
    }
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signInWithEmailAndPassword(
          email, password);
    } else {
      User _user = await _firebaseAuthService.signInWithEmailAndPassword(
          email, password);

      User _readedUserFromFirestore =
          await _firestoreDBService.readUser(_user.userID);
      return _readedUserFromFirestore;
    }
  }

  Future<bool> updateUserName(String userID, String newUserName) async {
    if (appMode == AppMode.DEBUG) {
      return false;
    } else {
      bool result =
          await _firestoreDBService.updateUserName(userID, newUserName);
      return result;
    }
  }
}
