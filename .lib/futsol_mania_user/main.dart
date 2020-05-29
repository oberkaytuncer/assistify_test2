import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_messaging_app/Pages/HomeScreen.dart';
import 'package:flutter_messaging_app/Pages/MainScreen.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_messaging_app/Pages/SignUpScreen.dart';
import 'utils/HexColor.dart';
import 'package:flutter_messaging_app/utils/User_Defaults.dart';
import 'package:firebase_core/firebase_core.dart';

import 'dart:io' show Platform;

var MainActivityRoute = <String, WidgetBuilder>{
  '/MainScreen': (BuildContext contaxt) => MainScreen(),
  '/SignUpScreen': (BuildContext contaxt) => SignUpScreen(),
  '/HomeScreen': (BuildContext contaxt) => HomeScreen()
};

Future<void> main() async {
  //WidgetsFlutterBinding.ensureInitialized();

  /*
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
  String text;

  SplashScreen({Key key, @required this.text}) : super(key: key);

  @override
  _SplashScreenState createState() => new _SplashScreenState(this.text);
}

class _SplashScreenState extends State<SplashScreen> {

  String text;
  _SplashScreenState(this.text);
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  User_Defualts user_defaults = new User_Defualts();
  String _phone = "";
  String _user_id = "";
  String _user_name = "";
  DatabaseReference users_tokens_db = FirebaseDatabase.instance.reference().child("users_tokens");

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  void getData() async {
    _phone = await user_defaults.getUserPhoneNumber();
    _user_id = await user_defaults.getUserUserID();
    _user_name = await user_defaults.getUserName();
    if (_user_name == null || _user_name == "") {
      if (_phone != null && _phone != "") {
        if (_user_id != null && _user_id != "") {
          removeFirebaseTokenIfExists();
          Timer(Duration(seconds: 1),
              () => Navigator.pushReplacementNamed(context, "/SignUpScreen"));
        } else {
          removeFirebaseTokenIfExists();
          Timer(Duration(seconds: 1),
              () => Navigator.pushReplacementNamed(context, "/MainScreen"));
        }
      } else {
        removeFirebaseTokenIfExists();
        Timer(Duration(seconds: 1),
            () => Navigator.pushReplacementNamed(context, "/MainScreen"));
      }
    } else {
      updateFirebaseToken();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //Firebase Setup
    _firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) async
    {
      String title = message['notification']['title'];
      String body = message['notification']['body'];
      showNotification(title,body);

    }, onLaunch: (Map<String, dynamic> message) async
    {
     final notification = message['data'];
    }, onResume: (Map<String, dynamic> message) async
    {
      final notification = message['data'];
      setState(() {});
    });

    //Register Notiification Settings
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    //Local Notification Settings.
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings,onSelectNotification: onSelectNotification);
    
    
    //Check UserDefaults Data
    getData();
  }

  Future onSelectNotification(String payload)
  {
    Navigator.pushReplacement(context,
        new MaterialPageRoute(builder: (context) {
          return SplashScreen(text: "Notification");
        }));
  }

  showNotification(String title,String body) async
  {
    var android = new AndroidNotificationDetails('channel Id', 'channel Name', 'channel Description');
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(0, title, body, platform);
    


  }

  showDialog(String title, String body)
  {
    print("Hello");
    print(title);
    print(body);
    try
    {
      return AlertDialog(
        title: new Text(title),
        content: new Text(body),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new FlatButton(
            child: new Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }catch(e)
    {
      print(e);
    }

  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/logo.png', width: 330, height: 170),
        ],
      ),
    ));
  }
  
  void updateFirebaseToken() {
    String _token;

    _firebaseMessaging.getToken().then((token) {
      _token = token;
      var data = {"token": _token};
      FirebaseAuth.instance.currentUser().then((user) {
        users_tokens_db.child(user.uid).update(data).whenComplete(() {
          if(text=="Notification")
            {
              Timer(
                  Duration(seconds: 1),
                      () =>
                      Navigator.pushReplacement(context,
                          new MaterialPageRoute(builder: (context) {
                            return HomeScreen(text: "Requests",);
                          })));
            }
          else {
            Timer(
                Duration(seconds: 1),
                    () =>
                    Navigator.pushReplacement(context,
                        new MaterialPageRoute(builder: (context) {
                          return HomeScreen();
                        })));
          }
        }).catchError((e) {
          print(e);
        });
      });
    });
  }

  //Remove Firebase Token of Users
  void removeFirebaseTokenIfExists() {
    if (FirebaseAuth.instance.currentUser() != null) {
      FirebaseAuth.instance.currentUser().then((user) {
        if(user.uid!=null) {
          users_tokens_db.child(user.uid).remove();
        }
      });
    }
  }
}
