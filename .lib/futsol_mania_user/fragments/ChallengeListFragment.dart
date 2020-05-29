import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_messaging_app/Models/ChallengesRequest.dart';
import 'package:flutter_messaging_app/utils/firebase_utils.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io' show Platform;

import 'package:flutter_messaging_app/main.dart';

class ChallengeListFragment extends StatefulWidget {
  @override
  _ChallengeListFragmentState createState() => _ChallengeListFragmentState();
}

class _ChallengeListFragmentState extends State<ChallengeListFragment> {
  ProgressDialog progressDialog;
  FirebaseDatabase database;

  DatabaseReference ref = FirebaseDatabase.instance.reference().child("teams");
  DatabaseReference grounds = FirebaseDatabase.instance.reference().child("grounds");
  DatabaseReference ref_token = FirebaseDatabase.instance.reference().child("users_tokens");
  DatabaseReference ref_players = FirebaseDatabase.instance.reference().child("users");
  DatabaseReference join_team_db = FirebaseDatabase.instance.reference().child("challenge_requests/pending_challenges");
  DatabaseReference ground_match_requests = FirebaseDatabase.instance.reference().child("ground_match_requests/pending_requests");
  DatabaseReference join_team_db1 = FirebaseDatabase.instance.reference().child("join_team_request/approved_requests");
  DatabaseReference join_team_db2 = FirebaseDatabase.instance.reference().child("challenge_requests/rejected_challenges");
  DatabaseReference join_team_db3 = FirebaseDatabase.instance.reference().child("challenge_requests/accepted_challenges");
  List<ChallengesRequest> pendingRequests = null;
  String userStatus = null;
  int players_count = 0;

  @override
  void initState() {
    // TODO: implement initState

    String sender_team_name;
    String opponent_team_name;
    String sender_team_id;
    String opponent_team_id;
    String date;
    String ground_id;
    String slot_id;
    String slot_time;
    String ground_name;
    String ground_address;
    String sender_team_picture;

    pendingRequests = [];
    FirebaseAuth.instance.currentUser().then((user) {
      join_team_db.child(user.uid).once().then((DataSnapshot datasnapshot) {
        if (datasnapshot.value != null) {
          var keys = datasnapshot.value.keys;
          var data = datasnapshot.value;

          for (var key in keys) {
            sender_team_id = data[key]['sender_team_id'];
            opponent_team_id = data[key]['team_id'];
            date = data[key]['date'];
            slot_id = data[key]['slot_id'];
            slot_time = data[key]['slot_time'];
            ground_id = data[key]['ground_id'];

            ref.child(sender_team_id).once().then((DataSnapshot teamsnapshot) {
              if (teamsnapshot.value != null) {
                var team_data = teamsnapshot.value;
                sender_team_name = team_data['team_name'];
                sender_team_picture = team_data['team_logo'];

                ref.child(opponent_team_id).once().then((DataSnapshot teamsnapshot) {
                  if (teamsnapshot.value != null) {
                    var team_data = teamsnapshot.value;
                    opponent_team_name = team_data['team_name'];

                    grounds.child(ground_id).once().then((DataSnapshot groundSnapshot) {
                      if (groundSnapshot.value != null) {
                        var player_data = groundSnapshot.value;

                        ground_name = player_data['ground_name'];
                        ground_address = player_data['address'];

                        setState(() {
                          userStatus = "";
                          ChallengesRequest pendingRequest = ChallengesRequest(
                              sender_team_name,
                              opponent_team_name,
                              sender_team_id,
                              opponent_team_id,
                              date,
                              ground_id,
                              slot_id,
                              slot_time,
                              ground_name,
                              ground_address,sender_team_picture);
                          pendingRequests.add(pendingRequest);
                        });
                      }
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
                                                acceptJoiningRequest(
                                                    pendingRequests[index],
                                                    context,
                                                    index);
                                              },
                                            ),
                                          ],
                                          secondaryActions: <Widget>[
                                            IconSlideAction(
                                              caption: 'Reject',
                                              color: Colors.red,
                                              icon: Icons.cancel,
                                              onTap: () {
                                                rejectJoiningRequest(
                                                    pendingRequests[index],
                                                    context,
                                                    index);
                                              },
                                            ),
                                          ],
                                          child:
                                              listitem(pendingRequests[index]));
                                    },
                                  ),
                          )
                  ],
                )));
  }

  listitem(ChallengesRequest detail) {
    return new Card(
        elevation: 15.0,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)),
        child: new Container(
          margin: const EdgeInsets.all(5.0),
          child: new Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      flex: 1,
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
                                    child: (detail.sender_team_picture != null)
                                        ? Image.network(
                                      "" + detail.sender_team_picture ,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.fill,
                                    )
                                        : Image.asset(
                                      "assets/logo.png",
                                      width: 70.0,
                                      height: 70.0,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      )),
                  Expanded(
                    flex: 5,
                    child: Container(
                      margin: const EdgeInsets.all(5.0),
                      child: Column(
                        children: <Widget>[
                          new Container(
                            alignment: FractionalOffset.topLeft,
                            child: Center(
                              child: new Text(
                              "Team Challenge",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold),
                            ),),
                          ),
                          new Container(
                            margin: const EdgeInsets.only(right: 10.0),
                            alignment: FractionalOffset.topLeft,
                            child: new Text(
                              "${detail.sender_team_name} Challenge your team.(${detail.opponent_team_name}).",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          new Container(
                            margin: const EdgeInsets.only(right: 10.0),
                            alignment: FractionalOffset.topLeft,
                            child: new Text(
                              "Ground: ${detail.ground_name} -> ${detail.ground_address}",
                              style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          new Container(
                            margin: const EdgeInsets.only(right: 10.0),
                            alignment: FractionalOffset.topLeft,
                            child: new Text(
                              "Date: ${detail.date}",
                              style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          new Container(
                            margin: const EdgeInsets.only(right: 10.0),
                            alignment: FractionalOffset.topLeft,
                            child: new Text(
                              "Slot Time: ${detail.slot_time}",
                              style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 13.0,
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

  void rejectJoiningRequest(ChallengesRequest pendingRequest, BuildContext context, int index) {
    ProgressDialog progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
    progressDialog.style(message: "Rejecting Request. Please Wait.......");
    progressDialog.show();
    String token="";
    ref_token.child(pendingRequest.sender_team_id).once().then((DataSnapshot datasnapshot) {
      if (datasnapshot.value != null) {
        setState(() {
          token = datasnapshot.value['token'];
        });
      }
    });

    //Firebase Send Reject Notification to Player
    String title = "Reject Challenge";
    String body = "${pendingRequest.sender_team_name}'s captain rejected your Challenge.";
    join_team_db.child(pendingRequest.sender_team_id).child(pendingRequest.opponent_team_id).remove();

    var data = {
        "team_id": pendingRequest.opponent_team_id,
        "sender_team_id": pendingRequest.sender_team_id,
        "ground_id": pendingRequest.ground_id,
        "date": pendingRequest.date,
        "slot_id": pendingRequest.slot_id,
        "slot_time": pendingRequest.slot_time,
        "status": "Rejected"
      };

    join_team_db2.child(pendingRequest.sender_team_id).child(pendingRequest.opponent_team_id).set(data).whenComplete(() {
      progressDialog.hide();
      if(token=="")
        {
          sendNotificationDataToFirebase(pendingRequest.sender_team_id,title,body);
        }else {
        callOnFcmApiSendPushNotifications(token, title, body);
      }
      setState(() {
        pendingRequests.removeAt(index);
      });
      Fluttertoast.showToast(msg: "Successfully Rejected Challenge",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    }).catchError((e) {
      progressDialog.hide();
      Fluttertoast.showToast(
          msg: "Not Rejected.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    });
  }


  void acceptJoiningRequest(ChallengesRequest pendingRequest, BuildContext context, int index) {
    ProgressDialog progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
    progressDialog.style(message: "Accepting Request. Please Wait.......");
    progressDialog.show();
    String sender_token="";
    String ground_token="";
    ref_token.child(pendingRequest.sender_team_id).once().then((DataSnapshot datasnapshot) {
      if (datasnapshot.value != null) {
        setState(() {
          sender_token = datasnapshot.value['token'];
        });
      }
    });
    ref_token.child(pendingRequest.ground_id).once().then((DataSnapshot datasnapshot) {
      if (datasnapshot.value != null) {
        setState(() {
          ground_token = datasnapshot.value['token'];
        });
      }
    });

    //Firebase Send Reject Notification to Player
    String title1 = "Accept Challenge";
    String body1 = "${pendingRequest.opponent_team_name}'s captain accepted your Challenges. Wait until Ground Owner Response";
    String title2 = "Match Request";
    String body2 = "${pendingRequest.opponent_team_name} and ${pendingRequest.sender_team_name} want to play match on ${pendingRequest.date} at ${pendingRequest.slot_time}";
    join_team_db.child(pendingRequest.opponent_team_id).child(pendingRequest.sender_team_id).remove();

    var data = {
      "team_id": pendingRequest.opponent_team_id,
      "sender_team_id": pendingRequest.sender_team_id,
      "ground_id": pendingRequest.ground_id,
      "date": pendingRequest.date,
      "slot_id": pendingRequest.slot_id,
      "slot_time": pendingRequest.slot_time,
      "status": "Pending"
    };

    ground_match_requests.child(pendingRequest.ground_id).child(pendingRequest.sender_team_id).set(data).whenComplete(() {
      join_team_db3.child(pendingRequest.opponent_team_id).child(pendingRequest.sender_team_id).push().set(data).whenComplete(() {
            if(sender_token!="") {
              //Send Notitification to Sender
              callOnFcmApiSendPushNotifications(sender_token, title1, body1);
            }
            else
              {
                sendNotificationDataToFirebase(pendingRequest.sender_team_id,title1,body1);
              }
            if(ground_token!="") {
              //Send Notitification to Ground Owner
              callOnFcmApiSendPushNotifications(ground_token, title2, body2);
            }
            else
              {
                sendNotificationDataToFirebase(pendingRequest.ground_id,title2,body2);
              }
          progressDialog.hide();

          setState(() {
            pendingRequests.removeAt(index);
          });
          Fluttertoast.showToast(
              msg: "Successfully Accepted Challenge Wait until Ground Owner Response",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1);

      });
    }).catchError((e) {
      progressDialog.hide();
      Fluttertoast.showToast(
          msg: "Not Rejected.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    });
  }
}
