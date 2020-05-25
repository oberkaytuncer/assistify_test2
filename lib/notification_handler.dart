import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_messaging_app/common_widget/platform_sensetive_widget/platform_sensetive_alert_dialog.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    final dynamic data = message['data'];
    print('Arka planda gelen data: ' + message['data'].toString());

    NotificationHandler.showNotification(message);
  }

  return Future<void>.value();
}

class NotificationHandler {
  FirebaseMessaging _fcm = FirebaseMessaging();

  static final NotificationHandler _singleton = NotificationHandler._internal();

  factory NotificationHandler() {
    return _singleton;
  }
  NotificationHandler._internal();

  initializeFCMNotification(BuildContext context) async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    _fcm.onTokenRefresh.listen((newToken) async {
      FirebaseUser _currentUser = await FirebaseAuth.instance.currentUser();
      await Firestore.instance
          .document('tokens/' + _currentUser.uid)
          .setData({'token': newToken});
    });

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage tetiklendiiiiiii: $message");
        showNotification(message);
        AlertDialogPlatformSensetive(
            title: message['data']['title'],
            content: message['data']['body'],
            mainActionButtonText: 'Tamam').show(context);
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch tetiklendi: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume tetiklendi: $message");
      },
    );
  }

  static void showNotification(Map<String, dynamic> message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '1234', 'Yeni Mesaj', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(0, message['data']['title'],
        message['data']['message'], platformChannelSpecifics,
        payload: 'Bildirime tıklanıldığında aktarılan değer');
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) {
    return null;
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('Notification payload: ' + payload);
    }
  }
}
