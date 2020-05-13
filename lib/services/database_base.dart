import 'package:flutter_messaging_app/model/user.dart';

abstract class DBBase{
    Future<bool> saveUser(User user);
    Future<User> readUser(String userID);
    Future<bool> updateUserName(String userID, String newUserName);
}