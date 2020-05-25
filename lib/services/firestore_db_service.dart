import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_messaging_app/model/conversation.dart';
import 'package:flutter_messaging_app/model/message.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/services/database_base.dart';
import 'package:flutter_messaging_app/services/user_defaults.dart';



class FirestoreDBService implements DBBase {
  final Firestore _firebaseDB = Firestore.instance;
  User_Defaults user_defaults = User_Defaults();

  @override
  Future<bool> saveUser(User user) async {
    DocumentSnapshot _readedUser =
        await Firestore.instance 
            .document('users/${user.userID}')
            .get();

    if (_readedUser.data == null)  {
      await _firebaseDB
          .collection('users')
          .document(user.userID)
          .setData(user.toMap()); 

      return true;

    } else {
      return true;
    }
  }




  @override
  Future<User> readUser(String userID) async {
    DocumentSnapshot _readedUser =
        await _firebaseDB.collection('users').document(userID).get();
    Map<String, dynamic> _readedUserInfoMap = _readedUser.data;
    User _readedUserObject = User.fromMap(_readedUserInfoMap);
    print('Okunan User Nesnesi: ' + _readedUserObject.toString());
    return _readedUserObject;
  }

  @override
  Future<List<Conversation>> getAllConversations(String userID) async {
    QuerySnapshot querySnapshot = await _firebaseDB
        .collection('chats')
        .where('chat_owner', isEqualTo: userID)
        .orderBy('created_date_message', descending: true)
        .getDocuments();

    List<Conversation> allConversation = [];

    for (DocumentSnapshot oneConversation in querySnapshot.documents) {
      Conversation _oneConversation =
          Conversation.fromMap(oneConversation.data);

      allConversation.add(_oneConversation);
    }

    return allConversation;
  }

  @override
  Stream<List<Messages>> getMessages(
      String currentUserID, String oppositeUserID) {
    var snapShot = _firebaseDB
        .collection('chats')
        .document(currentUserID + '--' + oppositeUserID)
        .collection('messages')
        .orderBy('messageDate', descending: true)
        .limit(1)
        .snapshots();

    var result = snapShot.map((messageList) => messageList.documents
        .map((message) => Messages.fromMap(message.data))
        .toList());
    return result;
  }

  Future<bool> saveMessage(Messages willSaveMessage) async {
    var _messageID = _firebaseDB.collection('chats').document().documentID;
    var _myDocumentID =
        willSaveMessage.messageFrom + '--' + willSaveMessage.messageTo;
    var _receiverDocumentID =
        willSaveMessage.messageTo + '--' + willSaveMessage.messageFrom;

    var _willSaveMessageMap = willSaveMessage.toMap();

    await _firebaseDB
        .collection('chats')
        .document(_myDocumentID)
        .collection('messages')
        .document(_messageID)
        .setData(_willSaveMessageMap);

    await _firebaseDB.collection('chats').document(_myDocumentID).setData({
      'chat_owner': willSaveMessage.messageFrom,
      'chat_guest': willSaveMessage.messageTo,
      'last_sent_message': willSaveMessage.messageContent,
      'seen_message': false,
      'created_date_message': FieldValue.serverTimestamp(),
    });

    _willSaveMessageMap.update('isItFromMe', (value) => false);

    await _firebaseDB
        .collection('chats')
        .document(_receiverDocumentID)
        .collection('messages')
        .document(_messageID)
        .setData(_willSaveMessageMap);

    await _firebaseDB
        .collection('chats')
        .document(_receiverDocumentID)
        .setData({
      'chat_owner': willSaveMessage.messageTo,
      'chat_guest': willSaveMessage.messageFrom,
      'last_sent_message': willSaveMessage.messageContent,
      'seen_message': false,
      'created_date_message': FieldValue.serverTimestamp(),
    });

    return true;
  }

  @override
  Future<DateTime> showTime(String userID) async {
    await _firebaseDB.collection('server').document(userID).setData({
      'time': FieldValue.serverTimestamp(),
    });
    var readedMap =
        await _firebaseDB.collection('server').document(userID).get();

    Timestamp readedTime = readedMap.data['time'];
    return readedTime.toDate();
  }

  @override
  Future<List<User>> getUserWithPagination(
      User lastGottenUser, int postsPerPage) async {
    QuerySnapshot _querySnapshot;
    List<User> _allUsers = [];

    if (lastGottenUser == null) {
      _querySnapshot = await Firestore.instance
          .collection('users')
          .orderBy('userName')
          .limit(postsPerPage)
          .getDocuments();
    } else {
      _querySnapshot = await Firestore.instance
          .collection('users')
          .orderBy('userName')
          .startAfter([lastGottenUser.userName])
          .limit(postsPerPage)
          .getDocuments();
      await Future.delayed(Duration(milliseconds: 300));
    }

    for (DocumentSnapshot snap in _querySnapshot.documents) {
      User _oneUser = User.fromMap(snap.data);
      _allUsers.add(_oneUser);
    }

    return _allUsers;
  }

  Future<List<Messages>> getMessageWithPagination(
      String currentUserID,
      String oppositeUserID,
      Messages lastGottenMessage,
      int postsPerPage) async {
    QuerySnapshot _querySnapshot;
    List<Messages> _allMessages = [];

    if (lastGottenMessage == null) {
      _querySnapshot = await Firestore.instance
          .collection('chats')
          .document(currentUserID + '--' + oppositeUserID)
          .collection('messages')
          .orderBy('messageDate', descending: true)
          .limit(postsPerPage)
          .getDocuments();
    } else {
      _querySnapshot = await Firestore.instance
          .collection('chats')
          .document(currentUserID + '--' + oppositeUserID)
          .collection('messages')
          .orderBy('messageDate', descending: true)
          .startAfter([lastGottenMessage.messageDate])
          .limit(postsPerPage)
          .getDocuments();
      await Future.delayed(Duration(milliseconds: 300));
    }

    for (DocumentSnapshot snap in _querySnapshot.documents) {
      Messages _oneMessage = Messages.fromMap(snap.data);
      _allMessages.add(_oneMessage);
    }

    return _allMessages;
  }

  Future<String> getToken(String messageTo) async {
    DocumentSnapshot _token =
        await _firebaseDB.document('tokens/' + messageTo).get();
    if (_token != null) 
      return _token.data['token'];
     else 
      return null;
    
  }

  @override
  Future<bool> updateProfilePhoto(String userID, String profilePhotoURL) async {
    await _firebaseDB
        .collection('users')
        .document(userID)
        .updateData({'profilePhotoURL': profilePhotoURL});
    return true;
  }

  @override
  Future<bool> updateUserName(String userID, String newUserName) async {
    var users = await _firebaseDB
        .collection('users')
        .where('userName', isEqualTo: newUserName)
        .getDocuments();
    if (users.documents.length >= 1) {
      return false;
    } else {
      await _firebaseDB
          .collection('users')
          .document(userID)
          .updateData({'userName': newUserName});
      return true;
    }
  }
}
