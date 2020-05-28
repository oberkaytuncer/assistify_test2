import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_messaging_app/Pages/GroundSignUpScreen.dart';
import 'package:flutter_messaging_app/Pages/HomeScreen.dart';
import 'package:flutter_messaging_app/Pages/MainScreen.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_messaging_app/Pages/SignUpScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/HexColor.dart';
import 'package:flutter_messaging_app/utils/User_Defaults.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'dart:io' show Platform;

var MainActivityRoute = <String,WidgetBuilder>
{
  '/MainScreen': (BuildContext contaxt) => MainScreen(),
  '/SignUpScreen': (BuildContext contaxt) => SignUpScreen(),
  '/HomeScreen': (BuildContext contaxt) => HomeScreen()
};

Future<void> main() async {

  /*
  WidgetsFlutterBinding.ensureInitialized();

  final FirebaseApp app = await FirebaseApp.configure(
    name: 'db2',
    options: Platform.isIOS
        ? const FirebaseOptions(
      googleAppID: '1:48160595211:ios:510a6579712fafeddb560e',
      databaseURL: 'https://fusole-mania-project.firebaseio.com/',
    )
        : const FirebaseOptions(
      googleAppID: '1:48160595211:android:170ffac89ddd9a29db560e',
      apiKey: 'AIzaSyBPmOK1mTSfa2MExaX_MCOA7-QJEeHOqRI',
      databaseURL: 'https://fusole-mania-project.firebaseio.com/',
    ),
  );*/
      runApp(new MaterialApp(
    theme:
    ThemeData(primaryColor: HexColor("39B54A"), accentColor: Colors.green),
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
    routes: MainActivityRoute,

  ));
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  //final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  DatabaseReference ref = FirebaseDatabase.instance.reference().child("users_tokens");
  //FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  User_Defualts user_defaults = new User_Defualts();

  String _phone = "";
  String _user_id = "";
  String _user_name = "";
  String _user_ground = "";

  @override
  void initState() {
      /*
    //Firebase Messaging Setup Configuration in Splash Screen
    _firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) async
    {
      String title = message['notification']['title'];
      String body = message['notification']['body'];
      showNotification(title,body);

    },onLaunch: (Map<String, dynamic> message) async
    {
      final notification = message['data'];
    }, onResume: (Map<String, dynamic> message) async
    {
      final notification = message['data'];
      setState(() {});
    });

    //Register Notification Settings for Android and iOS
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
    });

    //Local Notification Settings.
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings,onSelectNotification: onSelectNotification);
    */
    getData();
    super.initState();

  }

  //Check and Get Current User Data
  void getData() async
  {
    _phone = await user_defaults.getUserPhoneNumber();
    _user_id = await user_defaults.getUserUserID();
    _user_name = await user_defaults.getUserName();
    _user_ground = await user_defaults.getGroundName();

    if(_user_ground==null || _user_ground=="") {
      if (_user_name == null || _user_name == "") {
        if (_phone != null && _phone != "") {
          if (_user_id != null && _user_id != "") {
            Timer(Duration(seconds: 1), () =>Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) {
              return SignUpScreen();
            })));
          }
          else {
            Timer(Duration(seconds: 1), () =>Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) {
              return MainScreen();
            })));
          }
        }
        else {
          Timer(Duration(seconds: 1), () =>Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) {
            return MainScreen();
          })));
        }
      } else {
        if(FirebaseAuth.instance.currentUser()==null)
          {
            Timer(Duration(seconds: 1), () =>Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) {
              return MainScreen();
            })));
          }
        else {
          Timer(Duration(seconds: 1), () =>
              Navigator.pushReplacement(
                  context, new MaterialPageRoute(builder: (context) {
                return HomeScreen();
              })));
        }
      }
    }else
      {
       // updateFirebaseToken();
      }
  }
  //Notification Click
  Future onSelectNotification(String payload)
  {
    Navigator.pushReplacement(context,
        new MaterialPageRoute(builder: (context) {
          return SplashScreen();
        }));
  }
    /*
  //Show Notification
  showNotification(String title,String body) async
  {
    var android = new AndroidNotificationDetails('channel Id', 'channel Name', 'channel Description');
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(0, title, body, platform);
  }*/

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/logo.png',width: 330,height: 170),
          ],
        ),
      )
    );
  }
    /*
  //Update User Token in Firebase
  void updateFirebaseToken() {
    String _token;

    _firebaseMessaging.getToken().then((token) {
      _token = token;
      var data = {"token": _token};
      FirebaseAuth.instance.currentUser().then((user) {
        ref.child(user.uid).update(data).whenComplete(() {
            Timer(
                Duration(seconds: 1),
                    () =>
                    Navigator.pushReplacement(context,
                        new MaterialPageRoute(builder: (context) {
                          return HomeScreen();
                        })));

        }).catchError((e) {
          print(e);
        });
      });
    });
  }

  //Remove Firebase token
  void removeFirebaseTokenIfExists() {
    if (FirebaseAuth.instance.currentUser() != null) {
      FirebaseAuth.instance.currentUser().then((user) {
        ref.child(user.uid).remove();
      });
    }
  }*/
}
