import 'dart:io';
import 'package:flutter_messaging_app/locator.dart';
import 'package:flutter_messaging_app/model/conversation.dart';
import 'package:flutter_messaging_app/model/message.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/services/auth_base.dart';
import 'package:flutter_messaging_app/services/fake_auth_service.dart';
import 'package:flutter_messaging_app/services/firebase_auth_service.dart';
import 'package:flutter_messaging_app/services/firebase_storage_service.dart';
import 'package:flutter_messaging_app/services/firestore_db_service.dart';
import 'package:flutter_messaging_app/services/notification_sending_service.dart';
import 'package:timeago/timeago.dart' as timeago;

enum AppMode { DEBUG, RELEASE }

class UserRepository implements AuthBase {
  FirebaseAuthService _firebaseAuthService = locator<FirebaseAuthService>();
  FakeAuthenticationService _fakeAuthenticationService =
      locator<FakeAuthenticationService>();
  FirestoreDBService _firestoreDBService = locator<FirestoreDBService>();
  FirebaseStorageService _firebaseStorageService =
      locator<FirebaseStorageService>();
  NotificationSendingService _notificationSendingService =
      locator<NotificationSendingService>();

  AppMode appMode = AppMode.RELEASE;

  List<User> allUsersList = [];
  Map<String, String> userTokens = Map<String, String>();

  @override
  Future<User> currentUser() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.currentUser();
    } else {
      User _user = await _firebaseAuthService.currentUser();

      if (_user != null)
        return await _firestoreDBService.readUser(_user.userID);
      else
        return null;
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

      if (_user != null) {
        bool _result = await _firestoreDBService.saveUser(_user);

        if (_result) {
          return await _firestoreDBService.readUser(_user.userID);
        } else {
          await _firebaseAuthService.signOut();
          return null;
        }
      } else
        return null;
    }
  }

  @override
  Future<User> signInWithFacebook() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signInWithFacebook();
    } else {
      User _user = await _firebaseAuthService.signInWithFacebook();

      if (_user != null) {
        bool _result = await _firestoreDBService.saveUser(_user);
        if (_result == true) {
          User _readedUserFromFirestore =
              await _firestoreDBService.readUser(_user.userID);

          return _readedUserFromFirestore;
        } else {
          await _firebaseAuthService.signOut();
          return null;
        }
      } else
        return null;
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

  Future<String> uploadFile(
      String userID, String fileType, File willUploadFile) async {
    if (appMode == AppMode.DEBUG) {
      return 'file_download_URL';
    } else {
      String profilePhotoURL = await _firebaseStorageService.uploadFile(
          userID, fileType, willUploadFile);

      await _firestoreDBService.updateProfilePhoto(userID, profilePhotoURL);

      return profilePhotoURL;
    }
  }

  Stream<List<Messages>> getMessages(
      String currentUserID, String oppositeUserID) {
    if (appMode == AppMode.DEBUG) {
      return Stream.empty();
    } else {
      var result =
          _firestoreDBService.getMessages(currentUserID, oppositeUserID);
      return result;
    }
  }

  Future<bool> saveMessage(Messages willSaveMessage, User currentUser) async {
    if (appMode == AppMode.DEBUG) {
      return true;
    } else {
      var savingResult = await _firestoreDBService.saveMessage(willSaveMessage);
      if (savingResult) {
        var token = '';
        if (userTokens.containsKey(willSaveMessage.messageTo)) {
          token = userTokens[willSaveMessage.messageTo];
          print('Localden geldi: ' + token);
        } else {
          token = await _firestoreDBService.getToken(willSaveMessage.messageTo);
          if(token != null)
          userTokens[willSaveMessage.messageTo] = token;
          print('Veritabanından geldi: ' + token);
        }
        if(token !=null)
        await _notificationSendingService.sendNotification(
            willSaveMessage, currentUser, token);
            return true;
      }else return false;
    }
  }

  Future<List<Conversation>> getAllConversations(userID) async {
    if (appMode == AppMode.DEBUG) {
      return [];
    } else {
      DateTime _time = await _firestoreDBService.showTime(userID);

      var conversationList =
          await _firestoreDBService.getAllConversations(userID);

      for (var currentConversation in conversationList) {
        var userInUserList = findUserInList(currentConversation.chat_guest);

        if (userInUserList != null) {
          print('VERİLER LOCAL CACHE DEN GETİRİLDİ..');
          currentConversation.guestUserName = userInUserList.userName;
          currentConversation.guestUserProfilePhotoURL =
              userInUserList.profilePhotoURL;
        } else {
          print('VERİLER VERİ TABANIN DAN GETİRİLDİ..');
          print(
              'aranılan user daha önceden veri tabanındna getirlmemiştri. O yüzden veritabanından bu değeri okumalıyız.');

          var readedUserFromDatabase = await _firestoreDBService
              .readUser(currentConversation.chat_guest);
          currentConversation.guestUserName = readedUserFromDatabase.userName;
          currentConversation.guestUserProfilePhotoURL =
              readedUserFromDatabase.profilePhotoURL;
        }

        calculateTimeago(currentConversation, _time);
      }
      return conversationList;
    }
  }

  User findUserInList(userID) {
    for (int i = 0; i < allUsersList.length; i++) {
      if (allUsersList[i].userID == userID) {
        return allUsersList[i];
      }
    }
    return null;
  }

  void calculateTimeago(Conversation currentConversation, DateTime time) {
    currentConversation.lastReadTime = time;

    timeago.setLocaleMessages('tr', timeago.TrMessages());
    var _duration =
        time.difference(currentConversation.created_date_message.toDate());
    currentConversation.timeDifference =
        timeago.format(time.subtract(_duration), locale: 'tr');
  }

  Future<List<User>> getUserWithPagination(
      User lastGottenUser, int postsPerPage) async {
    if (appMode == AppMode.DEBUG) {
      return [];
    } else {
      List<User> _userList = await _firestoreDBService.getUserWithPagination(
          lastGottenUser, postsPerPage);
      allUsersList.addAll(_userList);
      return _userList;
    }
  }

  Future<List<Messages>> getMessageWithPagination(
      String currentUserID,
      String oppositeUserID,
      Messages lastGottenMessage,
      int postsPerPage) async {
    if (appMode == AppMode.DEBUG) {
      return [];
    } else {
      return await _firestoreDBService.getMessageWithPagination(
          currentUserID, oppositeUserID, lastGottenMessage, postsPerPage);
    }
  }
}
