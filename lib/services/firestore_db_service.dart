import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/model/conversation.dart';
import 'package:flutter_messaging_app/model/message.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/services/database_base.dart';

class FirestoreDBService implements DBBase {
  final Firestore _firebaseDB = Firestore.instance;

  @override
  Future<bool> saveUser(User user) async {
    await _firebaseDB
        .collection('users')
        .document(user.userID)
        .setData(user.toMap()); //Burada user firestore database ekleniyor.

    DocumentSnapshot _readedUser = await Firestore.instance
        .document('users/' + user.userID)
        .get(); //Burada user firebase'den okunuyor.

    Map _readedUserInformationMap = _readedUser.data;

    User _readedUserInformation = User.fromMap(_readedUserInformationMap);

    print('Okunan User Nesnesi: ' + _readedUserInformation.toString());

    return true;
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

  @override
  Future<bool> updateProfilePhoto(String userID, String profilePhotoURL) async {
    await _firebaseDB
        .collection('users')
        .document(userID)
        .updateData({'profilePhotoURL': profilePhotoURL});
    return true;
  }

  @override
  Future<List<User>> getAllUsers() async {
    QuerySnapshot querySnapshot =
        await _firebaseDB.collection('users').getDocuments();

    List<User> allUsers = [];

    for (DocumentSnapshot oneUser in querySnapshot.documents) {
      User _oneUser = User.fromMap(oneUser.data);
      allUsers.add(_oneUser);
    }

/*Aynı işlemi MAP methodu ile daha kolay bir şekilde yapabiliriz.
   allUsers = querySnapshot.documents.map((theOne) => User.fromMap(theOne.data)).toList(); 
 */
    debugPrint(' *******' + allUsers.toString() + '\n');
    return allUsers;
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
  Stream<List<Message>> getMessages(
      String currentUserID, String oppositeUserID) {
    var snapShot = _firebaseDB
        .collection('chats')
        .document(currentUserID + '--' + oppositeUserID)
        .collection('messages')
        .orderBy('messageDate', descending: true)
        .snapshots();

    var result = snapShot.map((messageList) => messageList.documents
        .map((message) => Message.fromMap(message.data))
        .toList());
    return result;
  }

  Future<bool> saveMessage(Message willSaveMessage) async {
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
}
