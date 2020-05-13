import 'package:cloud_firestore/cloud_firestore.dart';
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
  }

