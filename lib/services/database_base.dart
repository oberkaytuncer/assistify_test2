import 'package:flutter_messaging_app/model/conversation.dart';
import 'package:flutter_messaging_app/model/message.dart';
import 'package:flutter_messaging_app/model/user.dart';

abstract class DBBase {
  Future<bool> saveUser(User user);
  Future<User> readUser(String userID);
  Future<bool> updateUserName(String userID, String newUserName);
  Future<bool> updateProfilePhoto(String userID, String profilePhotoURL);
  Future<List<User>> getAllUsers();
  Future<List<Conversation>> getAllConversations(String userID);
  Stream<List<Message>> getMessages(
      String currentUserID, String oppositeUserID);
  Future<bool> saveMessage(Message willSaveMessage);
  Future<DateTime> showTime(String userID);
}
