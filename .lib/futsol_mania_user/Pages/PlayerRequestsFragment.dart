import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_messaging_app/Calender/flutter_calendar.dart';
import 'package:flutter_messaging_app/Models/Ground1.dart';
import 'package:flutter_messaging_app/Models/PendingRequest.dart';
import 'package:flutter_messaging_app/Models/Team.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:flutter_messaging_app/utils/firebase_utils.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'package:flutter_messaging_app/utils/User_Defaults.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_messaging_app/Models/Slot.dart';

import 'dart:io' show Platform;

import 'package:flutter_messaging_app/main.dart';

import 'HomeScreen.dart';

class PlayerRequestsFragment extends StatefulWidget {

  @override
  _PlayerRequestsFragmentState createState() => _PlayerRequestsFragmentState();
}

class _PlayerRequestsFragmentState extends State<PlayerRequestsFragment> {
  ProgressDialog progressDialog;
  FirebaseDatabase database;
  DatabaseReference ref = FirebaseDatabase.instance.reference().child("teams");
  DatabaseReference ref_token = FirebaseDatabase.instance.reference().child("users_tokens");
  DatabaseReference ref_players =
  FirebaseDatabase.instance.reference().child("users");
  DatabaseReference join_team_db = FirebaseDatabase.instance
      .reference()
      .child("join_team_request/pending_requests");
  DatabaseReference join_team_db1 = FirebaseDatabase.instance
      .reference()
      .child("join_team_request/approved_requests");
  DatabaseReference join_team_db2 = FirebaseDatabase.instance
      .reference()
      .child("join_team_request/rejected_requests");
  List<PendingRequest> pendingRequests = null;
  String userStatus = null;
  int players_count = 0;


  @override
  void initState() {
    // TODO: implement initState
    String team_name;
    String player_name;
    String team_id;
    String player_id;
    String phone_no;
    String city;
    String age;
    String position;
    String player_picture;
    pendingRequests = [];
    FirebaseAuth.instance.currentUser().then((user) {
      join_team_db.child(user.uid).once().then((DataSnapshot datasnapshot) {
        if(datasnapshot.value!=null) {
          var keys = datasnapshot.value.keys;
          var data = datasnapshot.value;

          for (var key in keys) {
            player_id = data[key]['player_id'];
            team_id = data[key]['team_id'];

            ref.child(team_id).once().then((DataSnapshot teamsnapshot) {
              if (teamsnapshot.value != null) {

                var team_data = teamsnapshot.value;
                team_name = team_data['team_name'];

                ref_players.child(player_id).once().then((
                    DataSnapshot playerSnapshot) {
                  if (playerSnapshot.value != null) {

                    var player_data = playerSnapshot.value;
                    phone_no = player_data['phone_no'];
                    player_name = player_data['name'];
                    city = player_data['city'];
                    age = player_data['age'];
                    position = player_data['position'];
                    player_picture = player_data['picture'];

                    setState(() {
                      userStatus = "";
                      PendingRequest pendingRequest = PendingRequest(
                          team_name,
                          player_name,
                          team_id,
                          player_id,
                          phone_no,
                          city,
                          age,
                          position,
                          player_picture);
                      pendingRequests.add(pendingRequest);
                    });
                  }
                });
              }
            });
          }
        }
        setState(() {
          userStatus = "";
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
                    : Container(
                  margin: const EdgeInsets.only(
                      top: 10.0, left: 10.0, right: 10.0),
                  child: pendingRequests.length == 0
                      ? new Text(
                    "No Pending Requests Available",
                    style: TextStyle(
                        color: HexColor("39B54A"),
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )
                      : new ListView.builder(
                    itemCount: pendingRequests.length,
                    itemBuilder: (_, index) {
                      return Slidable(
                          actionExtentRatio: 0.25,
                            actionPane: SlidableDrawerActionPane(),
                          actions: <Widget>[
                            IconSlideAction(
                              caption: 'Accept',
                              color: Colors.green,
                              icon: Icons.check,
                              onTap: () {
                                acceptJoiningRequest(pendingRequests[index],context,index);

                              },
                            ),
                          ],
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              caption: 'Reject',
                              color: Colors.red,
                              icon: Icons.cancel,
                              onTap: () {

                                rejectJoiningRequest(pendingRequests[index],context,index);

                              },
                            ),
                          ],
                          child: listitem(
                              pendingRequests[index]));
                    },
                  ),
                )
              ],
            )));
  }

  listitem(PendingRequest detail) {
    return new Card(
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
                                  radius: 35.0,
                                  child: ClipOval(
                                    child: (detail.player_picture != null)
                                        ? Image.network(
                                      "" + detail.player_picture,
                                      width: 65,
                                      height: 65,
                                      fit: BoxFit.fill,
                                    )
                                        : Image.asset(
                                      "assets/logo.png",
                                      width: 65.0,
                                      height: 65.0,
                                    ),
                                  )),
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
                              "Team Joining Request",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          new Container(
                            margin: const EdgeInsets.only(right: 10.0),
                            alignment: FractionalOffset.topLeft,
                            child: new Text(
                              "${detail.player_name} send request to Join their Team(${detail.team_name}).",
                              style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
//                              Container(
//                                  alignment: FractionalOffset.centerRight,
//                                  child: FlatButton.icon(
//                                      color: Colors.transparent,
//                                      onPressed: null,
//                                      icon: Icon(Icons.person_add, size: 17),
//                                      label: Text(
//                                        detail.age,
//                                        style: TextStyle(
//                                          color: Colors.black87,
//                                          fontSize: 17.0,
//                                        ),
//                                      ))),



                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }

  void rejectJoiningRequest(PendingRequest pendingRequest, BuildContext context,int index) {
    ProgressDialog progressDialog = ProgressDialog(context,type:ProgressDialogType.Normal);
    progressDialog.show();
    String token;
    ref_token.child(pendingRequest.team_id).once().then((DataSnapshot datasnapshot){

      if(datasnapshot.value!=null)
      {
        setState(() {
          token = datasnapshot.value['token'];
        });
      }


    });

    //Firebase Send Reject Notification to Player

    String title = "Reject Team Joining Request";
    String body = "${pendingRequest.player_name} rejected your Request.";
    join_team_db.child(pendingRequest.player_id).child(pendingRequest.team_id).remove();
    var data={
      "player_id":pendingRequest.player_id,
      "team_id": pendingRequest.team_id,
      "status":"Rejected"
    };
    join_team_db2.child(pendingRequest.team_id).child(pendingRequest.player_id).set(data).whenComplete(()
    {
      progressDialog.hide();
      callOnFcmApiSendPushNotifications(token,title,body);
      setState(() {
        pendingRequests.removeAt(index);
      });
      Fluttertoast.showToast(
          msg:
          "Successfully Rejected Request",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);

    }).catchError((e){
      progressDialog.hide();
      Fluttertoast.showToast(
          msg:
          "Not Rejected.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);


    });





  }

  void acceptJoiningRequest(PendingRequest pendingRequest, BuildContext context,int index) {
    print("Hello");
    ProgressDialog progressDialog = ProgressDialog(context,type:ProgressDialogType.Normal);
    progressDialog.show();
    String token;
    ref_token.child(pendingRequest.team_id).once().then((DataSnapshot datasnapshot){

      if(datasnapshot.value!=null)
      {
        setState(() {
          token = datasnapshot.value['token'];
        });
      }


    });

    //Firebase Send Reject Notification to Player

    String title = "Accept Team Joining Request";
    String body = "${pendingRequest.player_name} accepted your Request.";
    join_team_db.child(pendingRequest.player_id).child(pendingRequest.team_id).remove();
    var data={
      "player_id":pendingRequest.player_id,
      "team_id": pendingRequest.team_id,
      "status":"Rejected"
    };

    join_team_db1.child(pendingRequest.team_id).child(pendingRequest.player_id).set(data).whenComplete(()
    {
      var player_data = {
        "role": pendingRequest.position,
        "player_id": pendingRequest.player_id
      };
      var player_data1 = {
        "team": pendingRequest.team_name
      };
      ref.child(pendingRequest.team_id).child("Players").child(pendingRequest.player_id).set(player_data).whenComplete((){

        ref_players.child(pendingRequest.player_id).update(player_data1).whenComplete((){
          progressDialog.hide();
          callOnFcmApiSendPushNotifications(token, title, body);
          setState(() {
            pendingRequests.removeAt(index);
          });
          Fluttertoast.showToast(
              msg:
              "Successfully Accepted Request",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1);

        });

      });



    }).catchError((e){
      progressDialog.hide();
      Fluttertoast.showToast(
          msg:
          "Not Rejected.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);


    });






  }


}
