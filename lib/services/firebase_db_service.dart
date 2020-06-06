import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_messaging_app/model/user.dart';

class FirebaseDBService {
  DatabaseReference ground_owner_db =
      FirebaseDatabase.instance.reference().child("ground_owners");

  Future<bool> saveUser(User user) async {
    var data = {
   'fullName': user.fullName,
      'city': user.city,
      'role': user.role ,
      'age': user.age ,
      'gender': user.gender,
      'team': user.team ,
      'position': user.position,
      'postcount': user.postcount ,
      'followerscount': user.followerscount ,
      'followingcount': user.followingcount,
      'userID': user.userID,
      'email': user.email,
      'userName': user.userName ,
      'profilePhotoURL':
          user.profilePhotoURL,
      'createdAt': user.createdAt,
      'updatedAt': user.updatedAt ,
      'level': user.level ?? 1,
      'activeClient': user.activeClient,
      'totalLesson': user.totalLesson,
      'phoneNumber': user.phoneNumber,
      'tall': user.tall ,
      'weight': user.weight,
      'website': user.website ,
      'cv': user.cv ?? '',
      'languagePreference': user.languagePreference,
      'membershipPackage': user.membershipPackage,
      'active': user.active,
    };

    await ground_owner_db.child(user.userID).set(data).whenComplete(
          () => print('FIREBASE DATABASE IS DONE'),
        );
  }

/*

  final FirebaseDatabase _databaseReference = FirebaseDatabase.instance;

  Future<bool> saveUser(User user) async {
    var _resultPath = _databaseReference.reference().child('studio_owner');
    var userMap = user.toMap();
    var _result = await _resultPath.child(user.userID).set(userMap);
    return true;
  }*/
}
