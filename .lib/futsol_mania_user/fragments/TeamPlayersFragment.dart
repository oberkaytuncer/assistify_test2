import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_messaging_app/Models/Player.dart';
import 'package:flutter_messaging_app/Models/Team.dart';
import 'package:flutter_messaging_app/Models/User.dart';
import 'package:flutter_messaging_app/Pages/PlayerProfileScreen.dart';
import 'package:flutter_messaging_app/Pages/TeamProfileHome.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:flutter_messaging_app/utils/firebase_utils.dart';
import 'package:flutter_messaging_app/utils/strings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:country_pickers/country.dart';
import 'package:flutter/services.dart';
import 'package:flutter_messaging_app/fragments/UserProfileFragment.dart';
import 'package:flutter_messaging_app/Pages/HomeScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter_messaging_app/utils/User_Defaults.dart';
import 'package:flutter_messaging_app/Models/User.dart';

class TeamPlayersFragment extends StatefulWidget {

  @override
  _TeamPlayersFragmentState createState() => _TeamPlayersFragmentState();
}

class _TeamPlayersFragmentState extends State<TeamPlayersFragment> {

  String team_id  = "";

  User_Defualts user_defualts = new User_Defualts();
  ProgressDialog progressDialog;
  FirebaseDatabase database;
  DatabaseReference playerDb = FirebaseDatabase.instance.reference().child("teams");
  DatabaseReference users =
  FirebaseDatabase.instance.reference().child("users");
  List<Player> players = null;
  List<Player> playersTmp = null;
  DatabaseReference ref_tokens =
  FirebaseDatabase.instance.reference().child("users_tokens");

  DatabaseReference join_team_db = FirebaseDatabase.instance
      .reference()
      .child("join_team_request/pending_requests");
  DatabaseReference join_team_db1 = FirebaseDatabase.instance
      .reference()
      .child("join_team_request/approved_requests");

  @override
  void initState() {
   getData();
    super.initState();
  }
  void getData() async {
    team_id = await user_defualts.getTeamID();
    setState(() {
      print("User _id: $team_id");
      getDataOfPlayers();
    });
  }

  void getDataOfPlayers()
  {
    print("User _id1: $team_id");
    playerDb.child(team_id).child("Players").once().then((
        DataSnapshot datasnapshot) {
      if (datasnapshot == null || datasnapshot.value == null) {
        players = [];
      }
      else {
        players = [];
        var data = datasnapshot.value;
        var keys = datasnapshot.value.keys;
        for (var key in keys) {
          String player_name = "";
          String player_id = "";
          String player_position = "";
          String player_age = "";
          String player_city = "";
          String player_picture = "";
          String player_phone = "";
          player_id = data[key]['player_id'];
          player_age = data[key]['role'];
          users.child(player_id).once().then((DataSnapshot userDataSnap) {
            if (userDataSnap.value == null) {
              print("user is null");
            }
            else {
              setState(() {
                print("PlayerList Size ${userDataSnap.value['name']}");
                player_name = userDataSnap.value['name'];
                player_city = userDataSnap.value['city'];
                player_picture = userDataSnap.value['picture'];
                player_position = userDataSnap.value['position'];
                player_phone = userDataSnap.value['phone'];
                Player player = Player(
                    player_name,
                    player_id,
                    player_position,
                    player_age,
                    player_city,
                    player_picture,
                    player_phone);
                players.add(player);
              });
            }
          });
        }
        setState(() {
          playersTmp = players;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = new TextEditingController();
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
          title: new SizedBox(
            width: double.infinity,
            height: 40.0,
            child: new Container(
              child: TextFormField(
                onChanged: (text)
                {

                  text = text.toLowerCase();
                  setState(() {
                    playersTmp = players.where((plaayer ){
                      var title = plaayer.player_name.toLowerCase();
                      return title.contains(text);
                    }).toList();
                  });
                },
                textInputAction: TextInputAction.none,
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
                    hintText: 'Search Player...'),
              ),
            ),
          ),
          backgroundColor: HexColor("FFFFFF"),
        ),
        body: Builder(

            builder: (context) => Stack(
              fit: StackFit.expand,
              children: <Widget>[
                playersTmp == null
                    ? new Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  child: new CircularProgressIndicator(),
                )
                :Container(
                  margin: const EdgeInsets.only(
                      top: 10.0, left: 10.0, right: 10.0),
                  child: playersTmp.length == 0
                      ? new Text(
                    "Not Players Available",
                    style: TextStyle(
                        color: HexColor("39B54A"),
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )
                      : new ListView.builder(
                    itemCount: playersTmp.length,
                    itemBuilder: (_, index) {
                      return Slidable(
                          actionExtentRatio: 0.25,
                        actionPane: SlidableDrawerActionPane(),
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              caption: 'Invite',
                              color: Colors.green,
                              icon: Icons.forward,
                              onTap: () {
                                FirebaseAuth.instance
                                    .currentUser()
                                    .then((user) {
                                  setState(() {
                                    print("id ${user.uid}");
                                    print("id ${playersTmp[index]
                                        .player_id}");
                                    if (user.uid ==
                                        playersTmp[index]
                                            .player_id) {
                                      Fluttertoast.showToast(
                                          msg:
                                          "Cannot Send Request to Own . -:)",
                                          toastLength: Toast
                                              .LENGTH_SHORT,
                                          gravity:
                                          ToastGravity
                                              .BOTTOM,
                                          timeInSecForIosWeb:
                                          1);
                                    } else {
                                      FirebaseAuth.instance.currentUser().then((user){
                                        users.child(user.uid).once().then((DataSnapshot datasnapshot){
                                          if(datasnapshot.value['role']=="Captain")
                                            {
                                              users.child(playersTmp[index].player_id).once().then((DataSnapshot datasnapshot){

                                                setState(() {
                                                  print(datasnapshot.value['team']);
                                                  if(datasnapshot.value['team']!="" && datasnapshot.value['team']!="No Fan Team" )
                                                  {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                        "Player is Already Part of Other Team",
                                                        toastLength: Toast
                                                            .LENGTH_SHORT,
                                                        gravity:
                                                        ToastGravity
                                                            .BOTTOM,
                                                        timeInSecForIosWeb:
                                                        1);
                                                  }
                                                  else
                                                  {
                                                    requestToJoinTeam(
                                                        playersTmp[index], context);
                                                  }
                                                });

                                              });
                                            }
                                          else
                                            {
                                              Fluttertoast.showToast(
                                                  msg:
                                                  "You Are not Captain",
                                                  toastLength: Toast
                                                      .LENGTH_SHORT,
                                                  gravity:
                                                  ToastGravity
                                                      .BOTTOM,
                                                  timeInSecForIosWeb:
                                                  1);
                                            }
                                        });
                                      });


                                    }
                                  });
                                });
                              },
                            ),
                          ],
                          child: listitem(
                              index,context));
                    },
                  ),
                )
              ],
            )));
  }

  listitem(int index,BuildContext context) {
    return new GestureDetector(
        onTap: () {
          Navigator.push(context,
              new MaterialPageRoute(builder: (context) {
                return PlayerProfileScreen(id: playersTmp[index].player_id);
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
                                        child: (playersTmp[index].player_picture == null)
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
                                          "" + playersTmp[index].player_picture,
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
                                "${playersTmp[index].player_name} (${playersTmp[index].player_age})",
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
                                          playersTmp[index].player_city,
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
                                "He is ${playersTmp[index].player_position}",
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
          ))
    );
  }

  void requestToJoinTeam(Player player, BuildContext context) {
    ProgressDialog progressDialogg =
    ProgressDialog(context, type: ProgressDialogType.Normal);
    String user_id = player.player_id;
    String token="";
    String user_name;
    String age;
    String position;
    String team_id;
    bool already_request = false;

      progressDialogg.show();

      FirebaseAuth.instance.currentUser().then((user) {
        team_id = user.uid;

        join_team_db = FirebaseDatabase.instance.reference().child(
            "join_team_request/pending_requests/${user_id}/${team_id}");
        join_team_db1 = FirebaseDatabase.instance.reference().child(
            "join_team_request/approved_requests/${user_id}/${team_id}");
        join_team_db.once().then((DataSnapshot datanapshot) {
          if (datanapshot == null || datanapshot.value == null) {
            join_team_db1.once().then((DataSnapshot datanapshot1) {
              if (datanapshot1 == null || datanapshot1.value == null) {
                already_request = false;
                sendNotificationofJoining(already_request, progressDialogg,
                    team_id, user_id, user_name, position, age, token, player);
              } else {
                already_request = true;
                sendNotificationofJoining(already_request, progressDialogg,
                    team_id, user_id, user_name, position, age, token, player);
              }
            });
          } else {
            already_request = true;
            sendNotificationofJoining(already_request, progressDialogg,
                team_id, user_id, user_name, position, age, token, player);
          }
        });
      });

  }

  sendNotificationofJoining(
      bool already_request,
      ProgressDialog progressDialogg,
      String team_id,
      String user_id,
      String user_name,
      String position,
      String age,
      String token,
      Player player) {
    if (already_request) {
      progressDialogg.hide();
      Fluttertoast.showToast(
          msg:
          "Already sent Request to This Player. Please Wait until Reponse.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    } else {
    String team_name;
      FirebaseAuth.instance.currentUser().then((user) {
        team_id = user.uid;
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
              team_name = user['team'];
              age = user['age'];
              ref_tokens
                  .child(user_id)
                  .orderByPriority()
                  .once()
                  .then((DataSnapshot datasnapshot) {
                if (datasnapshot.value != null) {
                  setState(() {
                    Map<dynamic, dynamic> token_data = datasnapshot.value;
                    token = token_data['token'];
                    //Send Notiifcation
                    String title = "Request to Join Team";
                    String body =
                        "$user_name sent request to you to join their Team ( ${team_name} )";

                    //Sending Request Data to Firebase Real-Time Database
                    var data = {
                      "player_id": user_id,
                      "team_id": team_id,
                      "status": "Pending"
                    };
                    join_team_db = FirebaseDatabase.instance
                        .reference()
                        .child("join_team_request");

                    // FirebaseDatabase.instance.reference().child("join_team_request/pending_requests");
                    join_team_db
                        .child("pending_requests")
                        .child(user_id)
                        .child(team_id)
                        .set(data)
                        .whenComplete(() {
                      //Send Flutter Request Notification
                      progressDialogg.hide();
                      if(token!="")
                        {
                      callOnFcmApiSendPushNotifications(token, title, body);
                      }
                      else
                        {
                          sendNotificationDataToFirebase(user_id,title,body);
                        }
                      Fluttertoast.showToast(
                          msg:
                          "Request Sent To Player. Wait until Response",
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
                }else
                  {
                    setState(() {
                      String title = "Request to Join Team";
                      String body =
                          "$user_name sent request to you to join their Team ( ${team_name} )";
                      sendNotificationDataToFirebase(user_id,title,body);
                      //Sending Request Data to Firebase Real-Time Database
                      var data = {
                        "player_id": user_id,
                        "team_id": team_id,
                        "status": "Pending"
                      };
                      join_team_db = FirebaseDatabase.instance
                          .reference()
                          .child("join_team_request");

                      // FirebaseDatabase.instance.reference().child("join_team_request/pending_requests");
                      join_team_db
                          .child("pending_requests")
                          .child(user_id)
                          .child(team_id)
                          .set(data)
                          .whenComplete(() {
                        //Send Flutter Request Notification
                        progressDialogg.hide();
                        Fluttertoast.showToast(
                            msg:
                            "Request Sent To Player. Wait until Response",
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
