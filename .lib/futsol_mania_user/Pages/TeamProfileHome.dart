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
import 'package:flutter_messaging_app/fragments/TeamFicturesFragment.dart';
import 'package:flutter_messaging_app/fragments/TeamGalleryFragment.dart';
import 'package:flutter_messaging_app/fragments/TeamListFragment.dart';
import 'package:flutter_messaging_app/fragments/TeamPlayersFragment.dart';
import 'package:flutter_messaging_app/fragments/TeamProfileAboutFragment.dart';
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

class TeamProfileHome extends StatefulWidget {
  String team_id;

  TeamProfileHome({Key key, @required this.team_id}) : super(key: key);

  @override
  _TeamProfileHomeState createState() => _TeamProfileHomeState(this.team_id);
}

class _TeamProfileHomeState extends State<TeamProfileHome> {

  static String team_id;

  _TeamProfileHomeState(String team_idd)
  {
    team_id = team_idd;
  }
  String statuss= "";
  int _selectedPage = 0;

  final _pageOptions = [
    TeamProfileAboutFragment(),
    TeamPlayersFragment(),
    TeamFicturesFragment(),
    TeamGalleryFragment(),
  ];

  ProgressDialog progressDialog;

  @override
  void initState() {
    super.initState();
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
     appBar:AppBar(
        automaticallyImplyLeading: false,
        title: Text("Team Profile",
            style: TextStyle(color: Colors.black, fontSize: 22.0)),
        backgroundColor: HexColor("FFFFFF"),
      ),
      body:_pageOptions[_selectedPage],
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.green,
        currentIndex: _selectedPage,
        elevation: 0,
        onTap: (int index) {
            setState(() {
              _selectedPage = index;
            });
        },
        items: [
          BottomNavigationBarItem(icon: new Icon(Icons.info_outline),title: Text("About")),
          BottomNavigationBarItem(icon: ImageIcon(new AssetImage("assets/teams.png")),title: Text("Players")),
          BottomNavigationBarItem(icon:  new Icon(Icons.access_time),title: Text("Fixtures")),
          BottomNavigationBarItem(icon: new Icon(Icons.picture_in_picture),title: Text("Gallery")),
        ],
      ),
    );
  }
}
