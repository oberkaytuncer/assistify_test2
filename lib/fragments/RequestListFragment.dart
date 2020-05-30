import 'dart:async';
import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:firebase_auth/firebase_auth.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_messaging_app/Models/Team.dart';
import 'package:flutter_messaging_app/Pages/HomeScreen.dart';
import 'package:flutter_messaging_app/fragments/ChallengeListFragment.dart';
import 'package:flutter_messaging_app/fragments/PendingRequestListFragment.dart';
import 'package:flutter_messaging_app/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:flutter_messaging_app/utils/strings.dart';
import 'package:country_pickers/country_pickers.dart';
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

import 'dart:io' show Platform;

import 'package:flutter_messaging_app/main.dart';

class RequestListFragment extends StatefulWidget {
  @override
  _RequestListFragmentState createState() => _RequestListFragmentState();
}

class _RequestListFragmentState extends State<RequestListFragment> {

  int joinRequestsCount = 0;
  int challengesCount = 0;


  DatabaseReference joinRequests =
  FirebaseDatabase.instance.reference().child("join_team_request");
  DatabaseReference joinRequests1 =
  FirebaseDatabase.instance.reference().child("challenge_requests");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FirebaseAuth.instance.currentUser().then((user){

      joinRequests
          .child("pending_requests")
          .child(user.uid)
          .once()
          .then((DataSnapshot datasnapshot) {
        if (datasnapshot == null || datasnapshot.value == null) {
          setState(() {
            joinRequestsCount = joinRequestsCount + 0;
          });
        } else {
          var keys = datasnapshot.value.keys;
          setState(() {
            for (var key in keys) {
              joinRequestsCount = joinRequestsCount + 1;
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
            challengesCount = challengesCount + 0;
          });
        } else {
          var keys = datasnapshot.value.keys;
          setState(() {
            for (var key in keys) {
              challengesCount = challengesCount + 1;
            }
          });
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = new TextEditingController();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    int _selectedPage = 0;
    final _pageOptions = [
      PendingRequestListFragment(),
      PendingRequestListFragment(),
      PendingRequestListFragment(),
    ];

    return MaterialApp(
      theme: ThemeData(
        primaryColor: HexColor("39B54A"),
      ),
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
          length: 2,
          child: new Container(
              margin: const EdgeInsets.all(10.0),
              child:
              Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: PreferredSize(
                    preferredSize: Size.fromHeight(30.0),
                    child:
                    TabBar(

                        labelColor: Colors.white,
                        unselectedLabelColor: HexColor("39B54A"),
                    indicator: ShapeDecoration(
                        color: HexColor("39B54A"),
                        shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: HexColor("39B54A")))),
                    tabs: [
                      Tab(
                        child: Badge(child:
                        Container(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text("Joining Requests"),
                          ),
                        ),
                        badgeColor: Colors.green,badgeContent: Text("$joinRequestsCount"),),
                      ),
                      Tab(
                        child: Badge(child:
                        Container(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text("Challenges"),
                          ),
                        ),
                          badgeColor: Colors.green,badgeContent: Text("$challengesCount"),),
                      )

                    ]),),
              body: TabBarView(children: <Widget>[
                PendingRequestListFragment(),
                ChallengeListFragment(),
              ],))),
    ),
    );
  }
}
