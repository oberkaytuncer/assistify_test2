import 'package:flutter_messaging_app/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_messaging_app/model/message.dart';

class NotificationSendingService {
  Future<bool> sendNotification(
      Messages willSentNotification, User willSentUser, String token) async {
    String endURl = 'https://fcm.googleapis.com/fcm/send';
    String firebaseKey =
        'AAAA7jMKhA4:APA91bHv6fM1zP0Jqb5YDbrxhO8y3yHALnp_6pFMgS7UeoIT1TycuUTcH7urdA1ROOSNumecjM17yhC8-NxVncHKYN6p2seE6aoZEsdx2Xysq1AnEQog6TxKPw3YC1NHlUOjOfAgOBli';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$firebaseKey'
    };
    String json =
        '{ "to" : "$token", "data" : {"message" : "${willSentNotification.messageContent}", "title" : "${willSentUser.userName} yeni mesaj", "profilePhotoURL" : "${willSentUser.profilePhotoURL}" } }';

    http.Response response =
        await http.post(endURl, headers: headers, body: json);
    if (response.statusCode == 200) {
      print("işlem başarılı");
    } else {
      print("işlem başarısız" + response.statusCode.toString());
      print("Json: " + json);
    }
    return true;
  }
}
