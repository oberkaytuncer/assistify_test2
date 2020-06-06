import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

//Send Notification to One User
Future<bool> callOnFcmApiSendPushNotifications(
    String userToken, String title, String body) async {
  final postUrl = 'https://fcm.googleapis.com/fcm/send';
  final data = {
    "to": userToken,
    "priority": "high",
    "collapse_key": "type_a",
    "notification": {
      "title": title,
      "body": body,
    }
  };

  final headers = {
    'content-type': 'application/json',
    'Authorization':
    'key=AAAA7jMKhA4:APA91bHv6fM1zP0Jqb5YDbrxhO8y3yHALnp_6pFMgS7UeoIT1TycuUTcH7urdA1ROOSNumecjM17yhC8-NxVncHKYN6p2seE6aoZEsdx2Xysq1AnEQog6TxKPw3YC1NHlUOjOfAgOBli'
  };

  final response = await http.post(postUrl,
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
      headers: headers);

  if (response.statusCode == 200) {
    // on success do sth
    print('test ok push CFM');
    return true;
  } else {
    print(' CFM error');
    print(response.body);
    // on failure do sth
    return false;
  }
}

//Send Notification to List of Users
Future<bool> callOnFcmApiSendPushNotificationstoAll(
    List<String> userToken, String title, String body) async {
  final postUrl = 'https://fcm.googleapis.com/fcm/send';
  final data = {
    "to": userToken,
    "priority": "high",
    "collapse_key": "type_a",
    "notification": {
      "title": title,
      "body": body,
    }
  };

  final headers = {
    'content-type': 'application/json',
    'Authorization':
    'key=AAAA7jMKhA4:APA91bHv6fM1zP0Jqb5YDbrxhO8y3yHALnp_6pFMgS7UeoIT1TycuUTcH7urdA1ROOSNumecjM17yhC8-NxVncHKYN6p2seE6aoZEsdx2Xysq1AnEQog6TxKPw3YC1NHlUOjOfAgOBli'
  };

  final response = await http.post(postUrl,
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
      headers: headers);

  if (response.statusCode == 200) {
    // on success do sth
    print('test ok push CFM');
    return true;
  } else {
    print(' CFM error');
    print(response.body);
    // on failure do sth
    return false;
  }
}

//Push Pending Notification Data in Firebase RealTime Database.
void sendNotificationDataToFirebase(String id,String title,String body)
{
  DatabaseReference ref = FirebaseDatabase.instance.reference().child("pending_notifications");
  var data ={
    "id": id,
    "title": title,
    "body": body
  };
  ref.child(id).set(data).whenComplete((){

  });
}