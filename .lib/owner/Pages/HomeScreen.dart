import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/Pages/EditProfileScreen.dart';
import 'package:flutter_messaging_app/Pages/MainScreen.dart';
import 'package:flutter_messaging_app/Pages/RegisterPlayerScreen.dart';
import 'package:flutter_messaging_app/Pages/RegisterTeamScreen.dart';
import 'package:flutter_messaging_app/fragments/ChallengeListFragment.dart';
import 'package:flutter_messaging_app/fragments/TeamListFragment.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:flutter_messaging_app/fragments/TimeSlotFragment.dart';
import 'package:flutter_messaging_app/Pages/EnterPhoneScreen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_messaging_app/utils/ProgressHub.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_messaging_app/utils/User_Defaults.dart';
import 'package:firebase_database/firebase_database.dart';

import 'EditGroundScreen.dart';
import 'ProfileScreen.dart';

var MainActivityRoute = <String, WidgetBuilder>{
  '/EnterPhoneScreen': (BuildContext contaxt) => EnterPhoneScreen()
};

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  
  User_Defualts user_defualts = new User_Defualts();

  DatabaseReference ground_owners_db =      FirebaseDatabase.instance.reference().child("ground_owners");
  DatabaseReference users_tokens_db =      FirebaseDatabase.instance.reference().child("users_tokens");
  //DatabaseReference team_request_db =      FirebaseDatabase.instance.reference().child("team_request");

  String uid = "";
  int _selectedPage = 0;
  String _drawerUserName = "";
  String _drawerUserEmail = "";
  String drawer_picture;
  String player_status;
  ProgressDialog progressDialog;

  final _pageOptions = [
    TimeSlotFragment(),
    TeamListFragment(),
    ChallengeListFragment(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    _getUserData();
    super.initState();
  }

  //Get User Data for Drawer Others
  void _getUserData() {
    FirebaseAuth.instance.currentUser().then((user) {
      uid = user.uid;
      ground_owners_db
          .child(uid)
          .orderByPriority()
          .once()
          .then((DataSnapshot datasnapshot) {
        if (datasnapshot.value != null) {
          setState(() {
            Map<dynamic, dynamic> user = datasnapshot.value;
            _drawerUserName = user['name'];
            _drawerUserEmail = user['email'];
            drawer_picture = user['picture'];
            player_status = user['role'];
          });
        }
      });
    });
  }

  //Implementation of SignUp
  void signOut(BuildContext context) {
    progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
    progressDialog.show();
    FirebaseAuth.instance.currentUser().then((user) {
      users_tokens_db.child(user.uid).remove();
      setState(() {
        FirebaseAuth.instance.signOut().whenComplete(() {
          user_defualts.logout();
          setState(() {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => MainScreen()),
                (Route<dynamic> route) => false);
          });
        });
      });
    });
  }


/*
  //Implementation of Become Player
  void become_player(BuildContext context) {
    Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return RegisterPlayerScreen();
    }));
  }

  //Implementation of Become Captain
  void become_captain(BuildContext context) {
    FirebaseAuth.instance.currentUser().then((user) {
      team_request_db.child(user.uid).once().then((DataSnapshot datasnapshot) {
        if (datasnapshot == null || datasnapshot.value == null) {
          Navigator.push(context, new MaterialPageRoute(builder: (context) {
            return RegisterTeamScreen();
          }));
        } else {
          Fluttertoast.showToast(
              msg: "You request is Already in Pending.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1);
        }
      });
    });
  }
*/
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final border = OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(90.0)),
        borderSide: BorderSide(
          color: Colors.transparent,
        ));
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Ground Owner Home",
            style: TextStyle(color: HexColor("39B54A")),
          ),
          backgroundColor: HexColor("FFFFFF"),
          actions: <Widget>[
            Container(
                margin: const EdgeInsets.all(5.0),
                width: 45.0,
                height: 45.0,
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        new MaterialPageRoute(builder: (context) {
                      return ProfileScreen();
                    }));
                  },
                  child: CircleAvatar(
                      backgroundColor: HexColor("39B54A"),
                      radius: 50.0,
                      child: ClipOval(
                        child: (drawer_picture == null || drawer_picture == "")
                            ? new Container(
                                height: 20,
                                width: 20,
                                alignment: Alignment.center,
                                child: new CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                ),
                              )
                            : Image.network(
                                "" + drawer_picture,
                                width: 60,
                                height: 60,
                                fit: BoxFit.fill,
                              ),
                      )),
                )),
          ],
        ),
        drawer: new Drawer(
          child: Column(
            children: <Widget>[
              Expanded(
                // ListView contains a group of widgets that scroll inside the drawer
                child: new ListView(
                  children: <Widget>[
                    new UserAccountsDrawerHeader(
                      accountName: Text(
                        _drawerUserName,
                        style: TextStyle(color: Colors.white),
                      ),
                      accountEmail: Text(_drawerUserEmail,
                          style: TextStyle(color: Colors.white)),
                      currentAccountPicture: GestureDetector(
                        child: new CircleAvatar(
                          child: CircleAvatar(
                              backgroundColor: HexColor("ffffff"),
                              radius: 50.0,
                              child: ClipOval(
                                child: (drawer_picture != null)
                                    ? Image.network(
                                        "" + drawer_picture,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        "assets/logo.png",
                                        width: 80.0,
                                        height: 80.0,
                                      ),
                              )),
                        ),
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()),
                              (Route<dynamic> route) => false);
                        },
                        child: ListTile(
                          title: Text("Home Page"),
                          leading: Icon(Icons.home),
                          selected: true,
                        )),
                    InkWell(
                        onTap: () {
                          Navigator.push(context,
                              new MaterialPageRoute(builder: (context) {
                            return EditProfileScreen();
                          }));
                        },
                        child: ListTile(
                            title: Text("Edit Profile"),
                            leading: Icon(Icons.person_add))),
                    InkWell(
                        onTap: () {
                          Navigator.push(context,
                              new MaterialPageRoute(builder: (context) {
                            return EditGroundScreen();
                          }));
                        },
                        child: ListTile(
                            title: Text("Edit Ground"),
                            leading: new ImageIcon(
                                new AssetImage("assets/ground.png")))),
                    InkWell(
                        onTap: () {},
                        child: ListTile(
                            title: Text("Settings"),
                            leading: Icon(Icons.settings))),
                    InkWell(
                        onTap: () {},
                        child: ListTile(
                            title: Text("About Us"),
                            leading: Icon(Icons.info_outline))),
                    InkWell(
                        onTap: () {},
                        child: ListTile(
                            title: Text("Rate Us"),
                            leading: Icon(Icons.rate_review))),
                    InkWell(
                        onTap: () {
                          signOut(context);
                        },
                        child: ListTile(
                            title: Text("Sign Out"),
                            leading: Icon(Icons.power_settings_new)))
                  ],
                ),
              ),
              // This container holds the align
            ],
          ),
        ),
        body: _pageOptions[_selectedPage],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedPage,
          elevation: 0,
          onTap: (int index) {
            setState(() {
              _selectedPage = index;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.access_time), title: Text("")),
            BottomNavigationBarItem(icon: Icon(Icons.message), title: Text("")),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), title: Text("")),
          ],
        ));
  }
}
