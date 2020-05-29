import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_messaging_app/model/ChallengesRequest.dart';
import 'package:flutter_messaging_app/utils/firebase_utils.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';


class ChallengeListFragment extends StatefulWidget {
  @override
  _ChallengeListFragmentState createState() => _ChallengeListFragmentState();
}

class _ChallengeListFragmentState extends State<ChallengeListFragment> {
  ProgressDialog progressDialog;
  FirebaseDatabase database;

  DatabaseReference teams_db = FirebaseDatabase.instance.reference().child("teams");
  DatabaseReference grounds_db = FirebaseDatabase.instance.reference().child("grounds");
  DatabaseReference users_tokens_db = FirebaseDatabase.instance.reference().child("users_tokens");
  DatabaseReference users_db = FirebaseDatabase.instance.reference().child("users");
  DatabaseReference pen_challenge_db = FirebaseDatabase.instance.reference().child("challenge_requests/pending_challenges");
  DatabaseReference ground_match_requests = FirebaseDatabase.instance.reference().child("ground_match_requests/pending_requests");
  DatabaseReference ground_match_reject_requests = FirebaseDatabase.instance.reference().child("ground_match_requests/rejected_requests");
  DatabaseReference match_apprequest_db = FirebaseDatabase.instance.reference().child("ground_match_requests/approved_requests");
  DatabaseReference app_request_db = FirebaseDatabase.instance.reference().child("join_team_request/approved_requests");
  DatabaseReference reject_request_db = FirebaseDatabase.instance.reference().child("challenge_requests/rejected_challenges");
  DatabaseReference accep_request_db = FirebaseDatabase.instance.reference().child("challenge_requests/accepted_challenges");
  List<ChallengesRequest> pendingRequests = null;
  String userStatus = null;
  int players_count = 0;
  String reason = "";

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
    String opponent_team_picture;

    pendingRequests = [];
    FirebaseAuth.instance.currentUser().then((user) {
      ground_match_requests.child(user.uid).once().then((DataSnapshot datasnapshot) {

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

            teams_db.child(sender_team_id).once().then((DataSnapshot teamsnapshot) {
              if (teamsnapshot.value != null) {
                var team_data = teamsnapshot.value;
                sender_team_name = team_data['team_name'];
                sender_team_picture = team_data['team_logo'];

                teams_db.child(opponent_team_id).once().then((DataSnapshot teamsnapshot) {
                  if (teamsnapshot.value != null) {
                    var team_data = teamsnapshot.value;
                    opponent_team_name = team_data['team_name'];
                    opponent_team_picture = team_data['team_logo'];

                    grounds_db.child(ground_id).once().then((DataSnapshot groundSnapshot) {
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
                              ground_address,
                              sender_team_picture,
                              opponent_team_picture);
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
                                   actionPane:Container(),
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
                                                bottomSheetOfReason(pendingRequests[index], context, index);
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

  //List Item of Challenges
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
                                            "" + detail.sender_team_picture,
                                            width: 70,
                                            height: 68,
                                            fit: BoxFit.fill,
                                          )
                                        : Image.asset(
                                            "assets/logo.png",
                                            width: 70.0,
                                            height: 68.0,
                                          ),
                                  )),
                            ),
                          ],
                        ),
                      )),
                  Expanded(
                    flex: 4,
                    child: Container(
                      margin: const EdgeInsets.all(5.0),
                      child: Column(
                        children: <Widget>[
                          new Container(
                            alignment: FractionalOffset.topLeft,
                            child: Center(
                              child: new Text(
                                "Match Request",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          new Container(
                            margin: const EdgeInsets.only(right: 10.0),
                            alignment: FractionalOffset.topLeft,
                            child: new Text(
                              "${detail.sender_team_name} and ${detail.opponent_team_name} want to Play Match",
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
                        ],
                      ),
                    ),
                  ),
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
                                    child: (detail.opponent_team_picture !=
                                            null)
                                        ? Image.network(
                                            "" + detail.opponent_team_picture,
                                            width: 70,
                                            height: 68,
                                            fit: BoxFit.fill,
                                          )
                                        : Image.asset(
                                            "assets/logo.png",
                                            width: 70.0,
                                            height: 68.0,
                                          ),
                                  )),
                            ),
                          ],
                        ),
                      ))
                ],
              )
            ],
          ),
        ));
  }

  void rejectJoiningRequest(ChallengesRequest pendingRequest, BuildContext context, int index) {
    ProgressDialog progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
    progressDialog.show();
    String sender_token = "";
    String opponent_token = "";
    String ground_owner;

    users_tokens_db.child(pendingRequest.sender_team_id).once().then((DataSnapshot datasnapshot) {
      if (datasnapshot.value != null) {
        setState(() {
          sender_token = datasnapshot.value['token'];
        });
      }
    });

    users_tokens_db.child(pendingRequest.opponent_team_id).once().then((DataSnapshot datasnapshot) {
      if (datasnapshot.value != null) {
        setState(() {
          opponent_token = datasnapshot.value['token'];
        });
      }
    });

    //Firebase Send Reject Notification to Player
    ground_match_requests.child(pendingRequest.ground_id).child(pendingRequest.sender_team_id).remove();

    var data = {
      "team_id": pendingRequest.opponent_team_id,
      "sender_team_id": pendingRequest.sender_team_id,
      "ground_id": pendingRequest.ground_id,
      "date": pendingRequest.date,
      "slot_id": pendingRequest.slot_id,
      "slot_time": pendingRequest.slot_time,
      "status": "Rejected"
    };

    ground_match_reject_requests.child(pendingRequest.ground_id).child(pendingRequest.sender_team_id)
        .set(data).whenComplete(() {
      grounds_db.child(pendingRequest.ground_id).once().then((DataSnapshot datasnap) {
        if (datasnap.value != null) {
          setState(() {
            ground_owner = datasnap.value['ground_name'];
            String title = "Reject Match Request";
            String body = "${ground_owner}'s owner rejected your Match Request.\n Reason: ${reason}";

            if(sender_token!="") {
              callOnFcmApiSendPushNotifications(sender_token, title, body);
            }else
              {
                sendNotificationDataToFirebase(pendingRequest.sender_team_id,title,body);
              }
            if(opponent_token!="")
              {
            callOnFcmApiSendPushNotifications(opponent_token, title, body);
          }else
              {
              sendNotificationDataToFirebase(pendingRequest.opponent_team_id,title,body);
              }
          });
        }
      });

      //progressDialog.dismiss();
      setState(() {
        pendingRequests.removeAt(index);
      });
      Fluttertoast.showToast(msg: "Successfully Rejected Match",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    }).catchError((e) {
     // progressDialog.dismiss();
      Fluttertoast.showToast(msg: "Not Rejected.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    });
  }

  void acceptJoiningRequest(ChallengesRequest pendingRequest, BuildContext context, int index) {
    ProgressDialog progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
    progressDialog.show();
    String sender_token="";
    String opponent_token="";
    List<String> playersList;
    String ground_owner;

    teams_db.child(pendingRequest.sender_team_id).child("Players").once().then((DataSnapshot datasnapshot) {
      var keys = datasnapshot.value.keys;
      for (var keyss in keys) {
        users_tokens_db.child(keyss).once().then((DataSnapshot datasnapshot1) {
          if (datasnapshot1.value != null) {
            setState(() {
              playersList.add(datasnapshot1.value['token']);
            });
          }
        });
      }
    });

    teams_db.child(pendingRequest.opponent_team_id).child("Players").once().then((DataSnapshot datasnapshot) {
      var keys = datasnapshot.value.keys;
      for (var keyss in keys) {
        users_tokens_db.child(keyss).once().then((DataSnapshot datasnapshot1) {
          if (datasnapshot1.value != null) {
            setState(() {
              playersList.add(datasnapshot1.value['token']);
            });
          }
        });
      }
    });

    users_tokens_db.child(pendingRequest.sender_team_id).once().then((DataSnapshot datasnapshot) {
      if (datasnapshot.value != null) {
        setState(() {
          sender_token = datasnapshot.value['token'];
        });
      }
    });

    users_tokens_db.child(pendingRequest.opponent_team_id).once().then((DataSnapshot datasnapshot) {
      if (datasnapshot.value != null) {
        setState(() {
          opponent_token = datasnapshot.value['token'];
        });
      }
    });

    //Firebase Send Reject Notification to Player
    ground_match_requests.child(pendingRequest.ground_id).child(pendingRequest.sender_team_id).remove();
    var data = {
      "team_id": pendingRequest.opponent_team_id,
      "sender_team_id": pendingRequest.sender_team_id,
      "ground_id": pendingRequest.ground_id,
      "date": pendingRequest.date,
      "slot_id": pendingRequest.slot_id,
      "slot_time": pendingRequest.slot_time,
      "status": "Rejected"
    };

    var data1 = {
      "team1_logo": pendingRequest.sender_team_picture,
      "team1_name": pendingRequest.sender_team_name,
      "team2_logo": pendingRequest.opponent_team_picture,
      "team2_name": pendingRequest.opponent_team_name,
      "status": "Booked"
    };

    match_apprequest_db.child(pendingRequest.ground_id).child(pendingRequest.sender_team_id).set(data).whenComplete(() {
      grounds_db.child(pendingRequest.ground_id).once().then((DataSnapshot datasnap) {
        if (datasnap.value != null) {
          setState(() {
            ground_owner = datasnap.value['ground_name'];
            String title = "Accept Match Request";
            String body = "${ground_owner}'s owner Accept your Match Request.";

            grounds_db.child(pendingRequest.ground_id).child("Slots").child(pendingRequest.date).child(pendingRequest.slot_id).update(data1).whenComplete(() {
              String title1 = "Schedule Match";
              String body1 = "Match between ${pendingRequest.opponent_team_name} and ${pendingRequest.sender_team_name} on \n ${pendingRequest.date} - ${pendingRequest.slot_time}  at ${pendingRequest.ground_name}";

              if(sender_token!="") {
                callOnFcmApiSendPushNotifications(sender_token, title, body);
              }else
              {
                sendNotificationDataToFirebase(pendingRequest.sender_team_id,title,body);
              }
              if(opponent_token!="")
              {
                callOnFcmApiSendPushNotifications(opponent_token, title, body);
              }else
              {
                sendNotificationDataToFirebase(pendingRequest.opponent_team_id,title,body);
              }
              if(playersList.length>0) {
                callOnFcmApiSendPushNotificationstoAll(
                    playersList, title1, body1);
              }
            //  progressDialog.dismiss();
              setState(() {
                pendingRequests.removeAt(index);
              });
              Fluttertoast.showToast(
                  msg: "Successfully Rejected Match",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1);
            });
          });
        }
      });
    }).catchError((e) {
     // progressDialog.dismiss();
      Fluttertoast.showToast(
          msg: "Not Rejected.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    });
  }

  void bottomSheetOfReason(
      ChallengesRequest pendingRequest, BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              height: 210,
              child: new Container(
                  margin: EdgeInsets.all(7.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(30),
                          topRight: const Radius.circular(30))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(top: 12.0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                              flex: 5,
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    new SizedBox(
                                      width: double.infinity,
                                      child: new Text(
                                        "Description of Rejecting Match Request",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17.0),
                                      ),
                                    )
                                  ],
                                ),
                              ))
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 10.0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                              flex: 5,
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    new SizedBox(
                                      width: double.infinity,
                                      height: 50.0,
                                      child: new TextField(
                                        onChanged: (value) {
                                          reason = value;
                                        },
                                        decoration: new InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    top: 30.0,
                                                    right: 20,
                                                    bottom: 20.0,
                                                    left: 10.0),
                                            border: new OutlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: HexColor("39B54A")),
                                            ),
                                            hintText: 'Reason of Rejecting',
                                            labelText: 'Reason of Rejecting',
                                            suffixStyle: const TextStyle(
                                                color: Colors.green)),
                                      ),
                                    )
                                  ],
                                ),
                              ))
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 10.0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                              flex: 5,
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    new SizedBox(
                                      width: double.infinity,
                                      height: 40.0,
                                      child: new RaisedButton(
                                        child: Text("Submit",
                                            style: TextStyle(
                                                color: HexColor("FFFFFF"),
                                                fontSize: 14.0)),
                                        onPressed: () => rejectJoiningRequest(
                                            pendingRequest, context, index),
                                        color: HexColor("39B54A"),
                                      ),
                                    )
                                  ],
                                ),
                              ))
                        ],
                      )
                    ],
                  )));
        });
  }
}
