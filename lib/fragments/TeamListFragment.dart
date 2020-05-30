import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_messaging_app/Models/Team.dart';
import 'package:flutter_messaging_app/Pages/ChallengeFragment.dart';
import 'package:flutter_messaging_app/Pages/HomeScreen.dart';
import 'package:flutter_messaging_app/Pages/TeamProfileHome.dart';
import 'package:flutter_messaging_app/main.dart';
import 'package:flutter_messaging_app/utils/firebase_utils.dart';
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

class TeamListFragment extends StatefulWidget {
  @override
  _TeamListFragmentState createState() => _TeamListFragmentState();
}

class _TeamListFragmentState extends State<TeamListFragment> {
  ProgressDialog progressDialog;

  String phone_no = "0";
  String country_code = "+92";
  String smsCode;
  String verficationID;
  FirebaseDatabase database;
  DatabaseReference ref = FirebaseDatabase.instance.reference().child("teams");
  DatabaseReference ref_tokens =
      FirebaseDatabase.instance.reference().child("users_tokens");
  DatabaseReference join_team_db = FirebaseDatabase.instance
      .reference()
      .child("join_team_request/pending_requests");
  DatabaseReference join_team_db1 = FirebaseDatabase.instance
      .reference()
      .child("join_team_request/approved_requests");
  DatabaseReference users =
      FirebaseDatabase.instance.reference().child("users");
  List<Team> teams = null;
  String userStatus = null;
  int players_count = 0;

  @override
  void initState() {
    teams = [];
    // TODO: implement initState
    //Getting Daa of Teams and check which user is Online Guest/Player/Captain
    FirebaseAuth.instance.currentUser().then((user) {
      users.child(user.uid).once().then((DataSnapshot userDataSnap) {
        var data1 = userDataSnap.value;
        userStatus = data1['role'];

        ref.once().then((DataSnapshot datasnapshot) {
          var keys = datasnapshot.value.keys;
          var data = datasnapshot.value;

          for (var key in keys) {
            players_count = 0;
            var players = data[key]['Players'].keys;
            for (var keyss in players) {
              players_count = players_count + 1;
            }
            Team d = new Team(
                data[key]['team_name'],
                data[key]['team_logo'],
                data[key]['about'],
                data[key]['city'],
                data[key]['website'],
                data[key]['user_id'],
                players_count);
            teams.add(d);
          }

          setState(() {
            print("Teams :  ${teams.length}");
          });
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = new TextEditingController();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
        body: Builder(
            builder: (context) => Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    userStatus == null
                        ? new Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.center,
                            child: new CircularProgressIndicator(),
                          )
                        : userStatus == "Player"
                            ? Container(
                                margin: const EdgeInsets.only(
                                    top: 10.0, left: 10.0, right: 10.0),
                                child: teams.length == 0
                                    ? new Text(
                                        "Nom Teams Available",
                                        style: TextStyle(
                                            color: HexColor("39B54A"),
                                            fontSize: 24.0,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      )
                                    : new ListView.builder(
                                        itemCount: teams.length,
                                        itemBuilder: (_, index) {
                                          return Slidable(
                                              actionExtentRatio: 0.25,
                                              actionPane: SlidableDrawerActionPane(),
                                              secondaryActions: <Widget>[
                                                IconSlideAction(
                                                  caption: 'Join Team',
                                                  color: Colors.green,
                                                  icon: Icons.send,
                                                  onTap: () {
                                                    requestToJoinTeam(
                                                        teams[index], context);
                                                  },
                                                ),
                                              ],
                                              child: listitem(
                                                  teams[index].user_id,
                                                  teams[index].team_name,
                                                  teams[index].logo,
                                                  teams[index].city,
                                                  teams[index].about,
                                                  teams[index].players));
                                        },
                                      ),
                              )
                            : userStatus == "Captain"
                                ? Container(
                                    margin: const EdgeInsets.only(
                                        top: 10.0, left: 10.0, right: 10.0),
                                    child: teams.length == 0
                                        ? new Text(
                                            "Nom Teams Available",
                                            style: TextStyle(
                                                color: HexColor("39B54A"),
                                                fontSize: 24.0,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          )
                                        : new ListView.builder(
                                            itemCount: teams.length,
                                            itemBuilder: (_, index) {
                                              return Slidable(
                                                  actionExtentRatio: 0.25,
                                                   actionPane: SlidableDrawerActionPane(),
                                                  secondaryActions: <Widget>[
                                                    IconSlideAction(
                                                      caption: 'Challenge',
                                                      color: Colors.green,
                                                      icon: Icons.forward,
                                                      onTap: () {
                                                        FirebaseAuth.instance
                                                            .currentUser()
                                                            .then((user) {
                                                          setState(() {
                                                            if (user.uid ==
                                                                teams[index]
                                                                    .user_id) {
                                                              Fluttertoast.showToast(
                                                                  msg:
                                                                      "Cannot Send Request to Your own team . -:)",
                                                                  toastLength: Toast
                                                                      .LENGTH_SHORT,
                                                                  gravity:
                                                                      ToastGravity
                                                                          .BOTTOM,
                                                                  timeInSecForIosWeb:
                                                                      1);
                                                            } else {
                                                              Navigator.push(
                                                                  context,
                                                                  new MaterialPageRoute(
                                                                      builder:
                                                                          (context) {
                                                                return ChallengeFragment(
                                                                    team: teams[
                                                                        index]);
                                                              }));
                                                            }
                                                          });
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                  child: listitem(
                                                      teams[index].user_id,
                                                      teams[index].team_name,
                                                      teams[index].logo,
                                                      teams[index].city,
                                                      teams[index].about,
                                                      teams[index].players));
                                            },
                                          ),
                                  )
                                : Container(
                                    margin: const EdgeInsets.only(
                                        top: 10.0, left: 10.0, right: 10.0),
                                    child: teams.length == 0
                                        ? new Text(
                                            "Nom Teams Available",
                                            style: TextStyle(
                                                color: HexColor("39B54A"),
                                                fontSize: 24.0,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          )
                                        : new ListView.builder(
                                            itemCount: teams.length,
                                            itemBuilder: (_, index) {
                                              return listitem(
                                                  teams[index].user_id,
                                                  teams[index].team_name,
                                                  teams[index].logo,
                                                  teams[index].city,
                                                  teams[index].about,
                                                  teams[index].players);
                                            },
                                          ),
                                  )
                  ],
                )));
  }

  listitem(String team_id,String name, String logo, String city, String about, int players) {
    return
      new GestureDetector(
        onTap: () {
          User_Defualts user_defualts = new User_Defualts();
          setState(() {
            user_defualts.setTeam_ID(team_id);
          });
          Navigator.push(context,
              new MaterialPageRoute(builder: (context) {
                return TeamProfileHome(team_id: team_id);
              }));
        },
        child: new Card(
        elevation: 15.0,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20.0)),
        child: new Container(
          margin: const EdgeInsets.all(5.0),
          child: new Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      flex: 2,
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            new Container(
                              margin: new EdgeInsets.symmetric(vertical: 10.0),
                              alignment: FractionalOffset.centerLeft,
                              child: CircleAvatar(
                                  backgroundColor: HexColor("39B54A"),
                                  radius: 50.0,
                                  child: ClipOval(
                                      child: (logo == null)
                                          ? new Container(
                                              height: 20,
                                              width: 20,
                                              alignment: Alignment.center,
                                              child:
                                                  new CircularProgressIndicator(
                                                backgroundColor: Colors.white,
                                              ),
                                            )
                                          : Image.network(
                                              "" + logo,
                                              width: 92,
                                              height: 92,
                                              fit: BoxFit.fill,
                                            ))),
                            ),
                          ],
                        ),
                      )),
                  Expanded(
                    flex: 5,
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          new Container(
                            alignment: FractionalOffset.topLeft,
                            child: new Text(
                              name,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 23.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          new Row(
                            children: <Widget>[
                              Container(
                                  alignment: FractionalOffset.topLeft,
                                  child: FlatButton.icon(
                                      color: Colors.transparent,
                                      onPressed: null,
                                      icon: Icon(
                                        Icons.location_on,
                                        size: 19,
                                      ),
                                      label: Text(
                                        city,
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 17.0,
                                        ),
                                      ))),
                              Container(
                                  alignment: FractionalOffset.centerRight,
                                  child: FlatButton.icon(
                                      color: Colors.transparent,
                                      onPressed: null,
                                      icon: Icon(Icons.person_add, size: 19),
                                      label: Text(
                                        players.toString(),
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 17.0,
                                        ),
                                      ))),
                            ],
                          ),
                          new Container(
                            alignment: FractionalOffset.topLeft,
                            child: new Text(
                              about,
                              style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        )));
  }

  void requestToJoinTeam(Team team, BuildContext context) {
    ProgressDialog progressDialogg =
        ProgressDialog(context, type: ProgressDialogType.Normal);
    print("Sending Notification");
    String user_id = team.user_id;
    String token  = "";
    String user_name;
    String age;
    String position;
    String player_id;
    bool already_request = false;

    if (team.players > 11) {
      Fluttertoast.showToast(
          msg: "Cannot Join Team. Team is Full",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    } else {
      progressDialogg.show();

      FirebaseAuth.instance.currentUser().then((user) {
        player_id = user.uid;
        join_team_db = FirebaseDatabase.instance.reference().child(
            "join_team_request/pending_requests/${user_id}/${player_id}");

        join_team_db1 = FirebaseDatabase.instance.reference().child(
            "join_team_request/approved_requests/${user_id}/${player_id}");

        join_team_db.once().then((DataSnapshot datanapshot) {
          if (datanapshot == null || datanapshot.value == null) {
            join_team_db1.once().then((DataSnapshot datanapshot1) {
              if (datanapshot1 == null || datanapshot1.value == null) {
                already_request = false;
                sendNotificationofJoining(already_request, progressDialogg,
                    player_id, user_id, user_name, position, age, token, team);
              } else {
                already_request = true;
                sendNotificationofJoining(already_request, progressDialogg,
                    player_id, user_id, user_name, position, age, token, team);
              }
            });
          } else {
            already_request = true;
            sendNotificationofJoining(already_request, progressDialogg,
                player_id, user_id, user_name, position, age, token, team);
          }
        });
      });
    }
  }

  sendNotificationofJoining(
      bool already_request,
      ProgressDialog progressDialogg,
      String player_id,
      String user_id,
      String user_name,
      String position,
      String age,
      String token,
      Team team) {
    if (already_request) {
      progressDialogg.hide();
      Fluttertoast.showToast(
          msg:
              "Already sent Request to This Team. Please Wait until They Reponse.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    } else {
      FirebaseAuth.instance.currentUser().then((user) {
        player_id = user.uid;
        users
            .child(user.uid)
            .orderByPriority()
            .once()
            .then((DataSnapshot datasnapshot) {
          if (datasnapshot != null) {
            setState(() {
              Map<dynamic, dynamic> user = datasnapshot.value;
              user_name = user['name'];
              position = user['position'];
              age = user['age'];
              ref_tokens
                  .child(user_id)
                  .orderByPriority()
                  .once()
                  .then((DataSnapshot datasnapshot) {
                if (datasnapshot != null && datasnapshot.value!=null) {
                  setState(() {
                    Map<dynamic, dynamic> token_data = datasnapshot.value;
                    if(token_data['token']!=null) {
                      token = token_data['token'];
                    }
                    //Send Notiifcation
                    String title = "Request to Join Team";
                    String body =
                        "$user_name wants to join your Team ( ${team.team_name} )";

                    //Sending Request Data to Firebase Real-Time Database
                    var data = {
                      "team_id": team.user_id,
                      "player_id": player_id,
                      "status": "Pending"
                    };
                    join_team_db = FirebaseDatabase.instance
                        .reference()
                        .child("join_team_request");

                    // FirebaseDatabase.instance.reference().child("join_team_request/pending_requests");
                    join_team_db
                        .child("pending_requests")
                        .child(team.user_id)
                        .child(player_id)
                        .set(data)
                        .whenComplete(() {
                      //Send Flutter Request Notification
                      progressDialogg.hide();
                      if(token!="") {
                        callOnFcmApiSendPushNotifications(token, title, body);
                      }
                      Fluttertoast.showToast(
                          msg:
                              "Request Sent To Captain. Wait until Team Response",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1);
                    }).catchError((e) {
                      progressDialogg.hide();
                      Fluttertoast.showToast(
                          msg: "Request not Send there is some Error.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1);
                    });
                  });
                }
                else
                  {
                    setState(() {
                      String title = "Request to Join Team";
                      String body =
                          "$user_name wants to join your Team ( ${team.team_name} )";
                      sendNotificationDataToFirebase(user_id,title,body);
                      //Sending Request Data to Firebase Real-Time Database
                      var data = {
                        "team_id": team.user_id,
                        "player_id": player_id,
                        "status": "Pending"
                      };
                      join_team_db = FirebaseDatabase.instance
                          .reference()
                          .child("join_team_request");
                      // FirebaseDatabase.instance.reference().child("join_team_request/pending_requests");
                      join_team_db
                          .child("pending_requests")
                          .child(team.user_id)
                          .child(player_id)
                          .set(data)
                          .whenComplete(() {
                        //Send Flutter Request Notification
                        progressDialogg.hide();
                        Fluttertoast.showToast(
                            msg:
                            "Request Sent To Captain. Wait until Team Response",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1);
                      }).catchError((e) {
                        progressDialogg.hide();
                        Fluttertoast.showToast(
                            msg: "Request not Send there is some Error.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1);
                      });
                    });
                  }
              });
            });
          }
        });
      });
    }
  }
}
