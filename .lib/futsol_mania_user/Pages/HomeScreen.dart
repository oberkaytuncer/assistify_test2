import 'dart:async';

import 'package:badges/badges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/Database/Firebase.dart';
import 'package:flutter_messaging_app/Pages/MainScreen.dart';
import 'package:flutter_messaging_app/Pages/PlayerRequestsFragment.dart';
import 'package:flutter_messaging_app/Pages/RegisterPlayerScreen.dart';
import 'package:flutter_messaging_app/Pages/RegisterTeamScreen.dart';
import 'package:flutter_messaging_app/Pages/TeamListScreen.dart';
import 'package:flutter_messaging_app/fragments/RequestListFragment.dart';
import 'package:flutter_messaging_app/fragments/TeamListFragment.dart';
import 'package:flutter_messaging_app/fragments/UserHomeFragment.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:flutter_messaging_app/utils/strings.dart';
import 'package:flutter_messaging_app/utils/strings.dart';
import 'package:flutter_messaging_app/fragments/UserProfileFragment.dart';
import 'package:flutter_messaging_app/Pages/EnterPhoneScreen.dart';
import 'package:flutter/services.dart';

import 'package:country_pickers/country.dart';
import 'package:flutter/services.dart';
import 'package:flutter_messaging_app/Pages/SignUpScreen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_messaging_app/utils/User_Defaults.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_messaging_app/Models/User.dart';

import 'EditProfileScreen.dart';
import 'ProfileScreen.dart';

var MainActivityRoute = <String, WidgetBuilder>{
  '/EnterPhoneScreen': (BuildContext contaxt) => EnterPhoneScreen()
};

class HomeScreen extends StatefulWidget {
  String text;

  HomeScreen({Key key, @required this.text}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState(this.text);
}

class _HomeScreenState extends State<HomeScreen> {
  String text;

  _HomeScreenState(this.text);
  String statuss= "";

  User_Defualts user_defualts = new User_Defualts();
  int _selectedPage = 0;
  DatabaseReference ref = FirebaseDatabase.instance.reference().child("users");
  DatabaseReference users_tokens = FirebaseDatabase.instance.reference().child("users_tokens");
  DatabaseReference joinRequests =
      FirebaseDatabase.instance.reference().child("join_team_request");
  DatabaseReference joinRequests1 =
      FirebaseDatabase.instance.reference().child("challenge_requests");
  DatabaseReference ref1 =
      FirebaseDatabase.instance.reference().child("team_request");
  String _drawerUserName = "";
  String _drawerUserEmail = "";
  String drawer_picture = "";
  String player_status;
  String team;
  String uid = "";
  int count = 0;

  final _pageOptions = [
    UserHomeFragment(),
    TeamListFragment(),
    RequestListFragment(),
    PlayerRequestsFragment()
  ];

  ProgressDialog progressDialog;

  @override
  void initState() {
    // TODO: implement initState
    _getUserData();
    super.initState();
  }

  void _getUserData() {
    FirebaseAuth.instance.currentUser().then((user) {
      uid = user.uid;
      print("USer id " + uid);
      ref.child(uid).once().then((DataSnapshot datasnapshot) {
        if (datasnapshot != null) {
          setState(() {
            print("Data");
            Map<dynamic, dynamic> user = datasnapshot.value;
            _drawerUserName = user['name'];
            print("Hellp $_drawerUserName");
            _drawerUserEmail = user['email'];
            print(_drawerUserEmail);
            drawer_picture = user['picture'];
            player_status = user['role'];
            team = user['team'];
            print(drawer_picture);
          });
        }
      });

      joinRequests
          .child("pending_requests")
          .child(user.uid)
          .once()
          .then((DataSnapshot datasnapshot) {
        if (datasnapshot == null || datasnapshot.value == null) {
          setState(() {
            count = count + 0;
          });
        } else {
          var keys = datasnapshot.value.keys;
          setState(() {
            for (var key in keys) {
              count = count + 1;
            }
          });
        }
      });

      joinRequests1
          .child("pending_challenges")
          .child(user.uid)
          .once()
          .then((DataSnapshot datasnapshot) {
        if (datasnapshot == null || datasnapshot.value == null) {
          setState(() {
            count = count + 0;
          });
        } else {
          var keys = datasnapshot.value.keys;
          setState(() {
            for (var key in keys) {
              count = count + 1;
            }
          });
        }
      });
    });
  }

  void signOut(BuildContext context) {
    progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
    progressDialog.show();
    FirebaseAuth.instance.currentUser().then((user){
      users_tokens.child(user.uid).remove();
      setState(() {

        FirebaseAuth.instance.signOut().whenComplete(() {
          user_defualts.logout();
          setState(() {
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                MainScreen()), (Route<dynamic> route) => false);
          });
        });
      });

    });

  }

  void become_player(BuildContext context) {
    Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return RegisterPlayerScreen();
    }));
    /* */
  }

  void become_captain(BuildContext context) {
    if (team == "Select Team" || team == "No Fan Team" || team == "") {
      FirebaseAuth.instance.currentUser().then((user) {
        ref1.child(user.uid).once().then((DataSnapshot datasnapshot) {
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
    } else {
      Fluttertoast.showToast(
          msg:
              "You cannot Become Captain. Because you Already Part of Other Team.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2);
    }
    /* Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return RegisterTeamScreen();
    }));*/
  }

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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: new SizedBox(
          width: double.infinity,
          height: 40.0,
          child: new Container(
            child: TextFormField(

              textInputAction: TextInputAction.none,
              onTap: ()
              {
                FocusScope.of(context).requestFocus(new FocusNode());
                Navigator.push(context,
                    new MaterialPageRoute(builder: (context) {
                      return TeamListScreen();
                    }));
              },
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(top: 7.0),
                  focusedBorder: border,
                  border: border,
                  enabledBorder: border,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black54,
                  ),
                  hintStyle: TextStyle(
                      color: Colors.black54, fontFamily: "WorkSansLight"),
                  filled: true,
                  fillColor: Colors.black12,
                  hintText: 'Search'),
            ),
          ),
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
                        Navigator.pushReplacement(context,
                            new MaterialPageRoute(builder: (context) {
                          return HomeScreen(text: "Requests");
                        }));
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
            Container(
                // This align moves the children to the bottom
                child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    // This container holds all the children that will be aligned
                    // on the bottom and should not scroll with the above ListView
                    child: Container(
                        child: (player_status != null &&
                                player_status == "Guest")
                            ? Column(
                                children: <Widget>[
                                  Divider(),
                                  InkWell(
                                      onTap: () {
                                        become_player(context);
                                      },
                                      child: ListTile(
                                          leading: ImageIcon(new AssetImage(
                                              "assets/logo.png")),
                                          title: Text('Become a Player'))),
                                ],
                              )
                            : (player_status != null &&
                                    player_status == "Player")
                                ? Column(
                                    children: <Widget>[
                                      Divider(),
                                      InkWell(
                                          onTap: () {
                                            become_captain(context);
                                          },
                                          child: ListTile(
                                              leading: ImageIcon(new AssetImage(
                                                  "assets/logo.png")),
                                              title: Text('Become a Captain'))),
                                    ],
                                  )
                                : (player_status != null &&
                                        player_status == "Captain")
                                    ? Column(
                                        children: <Widget>[
                                          Divider(),
                                          InkWell(
                                              onTap: () {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "You Are Already Captain",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    timeInSecForIosWeb: 1);
                                              },
                                              child: ListTile(
                                                  leading: ImageIcon(
                                                      new AssetImage(
                                                          "assets/logo.png")),
                                                  title:
                                                      Text('You Are Captain'))),
                                        ],
                                      )
                                    : Column(
                                        children: <Widget>[
                                          Divider(),
                                          InkWell(
                                              onTap: () {
                                                // become_captain(context);
                                              },
                                              child: ListTile(
                                                  leading: ImageIcon(
                                                      new AssetImage(
                                                          "assets/logo.png")),
                                                  title: Text(''))),
                                        ],
                                      ))))
          ],
        ),
      ),
      body: statuss == "Player" && _selectedPage==2
      ? _pageOptions[3]
      :_pageOptions[_selectedPage] ,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPage,
        elevation: 0,
        onTap: (int index) {
          if (index != 2) {
            setState(() {
              _selectedPage = index;
            });
          } else {
            FirebaseAuth.instance.currentUser().then((user) {
              ref.child(user.uid).once().then((DataSnapshot datasnapShot) {
                if (datasnapShot.value != null) {
                  if (datasnapShot.value['role'] != "Captain") {
                    setState(() {
                      statuss ="Player";
                      _selectedPage = index;

                    });
                  } else {
                    setState(() {
                      statuss = "Captain";
                      _selectedPage = index;
                    });
                  }
                }
              });
            });
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), title: Text("")),
          BottomNavigationBarItem(
              icon: ImageIcon(new AssetImage("assets/teams.png")),
              title: Text("")),
          BottomNavigationBarItem(
              icon:
                  Badge(child: ImageIcon(new AssetImage("assets/request.png")),badgeContent: Text("$count"),badgeColor: Colors.green,),
              title: Text("")),
        ],
      ),
    );
  }
}
