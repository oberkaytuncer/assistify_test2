import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_messaging_app/Calender/flutter_calendar.dart';
import 'package:flutter_messaging_app/Models/Ground1.dart';
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

class ChallengeFragment extends StatefulWidget {
  Team team;

  ChallengeFragment({Key key, @required this.team}) : super(key: key);

  @override
  _ChallengeFragmentState createState() => _ChallengeFragmentState(this.team);
}

class _ChallengeFragmentState extends State<ChallengeFragment> {
  Team team;

  _ChallengeFragmentState(this.team);

  DatabaseReference challenge_team_db = FirebaseDatabase.instance
      .reference()
      .child("challenge_requests/pending_challenges");


  DatabaseReference ref_tokens_db = FirebaseDatabase.instance
      .reference()
      .child("users_tokens");


  String date_value;
  String selectedGround;
  Slot selectedSlot = null;
  List<String> _grounds = [];
  List<String> slots = [];
  List<Slot> slot = [];

  List<Ground1> _allground = [];

  String _position = "Not Available";
  String _team_name = "Not Joined";
  User_Defualts user_defualts = new User_Defualts();
  String drawer_picture;
  String uid;
  String selectDate = new DateTime.now().toString();
  DatabaseReference ref =
      FirebaseDatabase.instance.reference().child("grounds");
  DatabaseReference ref1 =
  FirebaseDatabase.instance.reference().child("teams");
  ProgressDialog progressDialog;
  var globalKey = GlobalKey<RefreshIndicatorState>();
  String team_name;
  var team_name_controller = TextEditingController();

  Map<int, bool> itemsSelectedValue = Map();
  String key_value;
  @override
  void initState() {
    // TODO: implement initState
    team_name = team.team_name;
    team_name_controller.text = team_name;
    ref.once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value == null) {
        _grounds.add("No Ground Available");
      } else {
        var keys = dataSnapshot.value.keys;
        var data = dataSnapshot.value;

        for (var key in keys) {
          String key_value = key.toString();
          _grounds.add(data[key]['ground_name']);
          Ground1 ground = Ground1(key_value, data[key]['ground_name']);
          _allground.add(ground);
        }
        setState(() {
          selectedGround = _grounds.first;
          if (_grounds.length > 0) {
            getGroundSlots(selectDate, 0);
          } else {
            Fluttertoast.showToast(
                msg: "No Grounds Available",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1);
          }
        });
      }
    });

    super.initState();
  }

  void getGroundSlots(String date, int key) async {
    slot.clear();
    slot = [];
    selectedSlot = null;
    setState(() {});
     key_value = _allground[key].ground_id;
    DateTime dateTime = DateTime.parse(selectDate);
    int day = dateTime.day;
    int month = dateTime.month;
    int year = dateTime.year;
    date_value = "$day-$month-$year";
    //date_value = selectDate;

    print("Date $date_value");
    print("key $key_value");

    print("Key Value $key_value");
    print("Date Value $date_value");
    //Getting Data
    ref.child(key_value)
        .child("Slots")
        .child(date_value)
        .once()
        .then((DataSnapshot dataSnapShot) {
      if (dataSnapShot.value == null) {
        slots.add("No Slots Available");
        Fluttertoast.showToast(
            msg: "No Slot Available on $date_value",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1
        );
      } else {
        var keys = dataSnapShot.value.keys;
        var data = dataSnapShot.value;

        for (var keyss in keys) {
          if (data[keyss]['status'] == "Not Booked") {
            Slot slot1 = Slot(
                data[keyss]['slot_id'],
                data[keyss]['time'],
                data[keyss]['startTime'],
                data[keyss]['endTime'],
                data[keyss]['date'],
                data[keyss]['status'],
                data[keyss]['team1_logo'],
                data[keyss]['team1_name'],
                data[keyss]['team2_logo'],
                data[keyss]['team2_name']);
            slots.add(data[keyss]['time']);
            slot.add(slot1);
          }
        }
        setState(() {
          print("Slots Length: ${slot.length}");
        });
      }
      setState(() {
        print("Slots Length: ${slot.length}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Challenge Team",
            style: TextStyle(color: Colors.black, fontSize: 22.0)),
        backgroundColor: HexColor("FFFFFF"),
      ),
      body: Builder(
        builder: (context) => Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Opacity(
                opacity: 0.01,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/sherry.jpg'),
                          fit: BoxFit.cover)),
                )),
            Padding(
              padding: EdgeInsets.only(left: 3.0, right: 3.0, top: 10.0),
            ),
            new Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 10.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: const EdgeInsets.only(left: 5, right: 5),
                        child: new Calendar(
                          onDateSelected: (value) {
                            selectDate = value.toString();
                            if (_grounds.length > 0) {
                              getGroundSlots(
                                  selectDate, _grounds.indexOf(selectedGround));
                            } else {
                              Fluttertoast.showToast(
                                  msg: "No Grounds Available",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1);
                            }
                            //getData();
                          },
                        ),
                      ),
                    )
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: 10.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        flex: 5,
                        child: Container(
                          margin: const EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new SizedBox(
                                width: double.infinity,
                                height: 50.0,
                                child: new TextField(
                                  controller: team_name_controller,
                                  onChanged: (value) {
                                    team_name = value;
                                  },
                                  decoration: new InputDecoration(
                                      border: new OutlineInputBorder(
                                        borderSide: new BorderSide(
                                            color: HexColor("39B54A")),
                                      ),
                                      hintText: 'Team Name',
                                      labelText: 'Team Name',
                                      suffixStyle:
                                          const TextStyle(color: Colors.green)),
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
                          margin: const EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new SizedBox(
                                width: double.infinity,
                                height: 54.0,
                                child: Container(
                                  child: DropdownButtonHideUnderline(
                                      child: DropdownButtonFormField(
                                    decoration: new InputDecoration(
                                        border: new OutlineInputBorder(
                                          borderSide: new BorderSide(
                                              color: HexColor("39B54A")),
                                        ),
                                        hintText: 'Choose Ground',
                                        labelText: 'Choose Ground',
                                        suffixStyle: const TextStyle(
                                            color: Colors.green)),
                                    items: _grounds
                                        .map((value) => DropdownMenuItem(
                                              child: Text(value),
                                              value: value,
                                            ))
                                        .toList(),
                                    onChanged: (String value) {
                                      setState(() {
                                        selectedGround = value;
                                        if (_grounds.length > 0) {
                                          getGroundSlots(selectDate,
                                              _grounds.indexOf(selectedGround));
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: "No Grounds Available",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1);
                                        }
                                      });
                                    },
                                    value: selectedGround,
                                  )),
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
                        child: new Container(
                            height: 50,
                            margin: const EdgeInsets.only(left: 10, right: 10),
                            child: slot.length == 0
                                ? new Text(
                                    "Nom Slots Available.",
                                    style: TextStyle(
                                        color: HexColor("39B54A"),
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  )
                                : new ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: slot.length,
                                    itemBuilder: (context, index) {
                                      bool isCurrentIndexSelected =
                                          itemsSelectedValue[index] == null
                                              ? false
                                              : itemsSelectedValue[index];

                                      Container contianer;

                                      if (isCurrentIndexSelected) {
                                        contianer = new Container(
                                          width: 150,
                                          height: 100,
                                          child: new SizedBox(
                                              child: new Card(
                                            color: HexColor("39B54A"),
                                            elevation: 10,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        50.0)),
                                            child: Center(
                                                child: new Text(
                                              slot[index].time,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.white),
                                            )),
                                          )),
                                        );
                                      } else {
                                        contianer = new Container(
                                          width: 150,
                                          height: 150,
                                          child: new SizedBox(
                                              child: new Card(
                                            color: Colors.white,
                                            elevation: 10,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        50.0)),
                                            child: Center(
                                                child: new Text(
                                              slot[index].time,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 17),
                                            )),
                                          )),
                                        );
                                      }

                                      return GestureDetector(
                                        onTap: () {
                                          for (int i = 0;
                                              i < slot.length;
                                              i++) {
                                            print("Hellow");
                                            itemsSelectedValue[i] = false;
                                            setState(() {});
                                          }
                                          itemsSelectedValue[index] =
                                              !isCurrentIndexSelected;

                                          setState(() {
                                            print(
                                                "OnClick : $index + ${itemsSelectedValue[index]}");
                                            if(itemsSelectedValue[index]==true) {
                                              selectedSlot = slot[index];
                                            }else
                                              {
                                                selectedSlot = null;
                                              }
                                          });
                                        },
                                        child: contianer,
                                      );
                                    })))
                  ],
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: Container(
          width: 200.0,
          height: 50.0,
          child: new RaisedButton(
              color: HexColor("39B54A"),
              onPressed: () {
                challengeTeam(context);
              },
              child: Text("Challenge Team",
                  style: TextStyle(color: HexColor("FFFFFF"), fontSize: 14.0)),
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  listitem(Slot slot) {
    return new SizedBox(
        width: 150,
        height: 100,
        child: new Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          child: Center(
              child: new Text(
            slot.time,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          )),
        ));
  }

  void challengeTeam(BuildContext context) {
    if (selectDate != null || date_value != "") {
      if (selectedGround != null ||
          selectedGround != "" ||
          selectedGround != "No Grounds Available") {
        if (selectedSlot != null) {
          if (selectedSlot.slot_id != null) {
            sendChallengeRequest(context);
          } else {
            Fluttertoast.showToast(
                msg: "No Slots Available",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1);
          }
        } else {
          Fluttertoast.showToast(
              msg: "No Slot Available",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1);
        }
      } else {
        Fluttertoast.showToast(
            msg: "No Grounds Available",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please Select Date",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    }
  }

  void sendChallengeRequest(BuildContext context) {

    ProgressDialog progressDialog = ProgressDialog(context,type:ProgressDialogType.Normal);
    progressDialog.show();
    String token="";
    String team_id = team.user_id;
    String user_id ;
    String title;
    String body;

    //Getting Token of Captain

    FirebaseAuth.instance.currentUser().then((user) {
      user_id = user.uid;
      challenge_team_db.child(team_id).child(user_id)..once().then((DataSnapshot datasnapshot){
        if(datasnapshot.value!=null)
          {
            progressDialog.hide();
            Fluttertoast.showToast(
                msg: "Request is Already in Pending",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1
            );
          }
        else
          {
            ref_tokens_db.child(team.user_id).once().then((
                DataSnapshot datasnapshot) {
              if (datasnapshot.value != null) {
                token = datasnapshot.value['token'];

                setState(() {
                  var data = {
                    "team_id": team_id,
                    "sender_team_id": user_id,
                    "ground_id": key_value,
                    "date": date_value,
                    "slot_id": selectedSlot.slot_id,
                    "slot_time": selectedSlot.time,
                    "status": "Pending"
                  };

                  challenge_team_db.child(team_id).child(user_id)
                      .set(data)
                      .whenComplete(() {

                        ref1.child(user_id).once().then((DataSnapshot datasnapshot)
                        {
                          title = "Match Challenge";
                          body = "${datasnapshot.value['team_name']} challenge you on ${date_value} and time ${selectedSlot
                              .time}";
                          //Send Notification to Captain.
                          callOnFcmApiSendPushNotifications(token, title, body);

                          print("Token : $token");
                          progressDialog.hide();
                          Fluttertoast.showToast(
                              msg: "Challenge Sent Successfully",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1
                          );
                          Navigator.pushReplacement(context,
                              new MaterialPageRoute(builder: (context) {
                                return HomeScreen();
                              }));
                        });

                  });
                });
              } else {
                setState(() {
                  var data = {
                    "team_id": team_id,
                    "sender_team_id": user_id,
                    "ground_id": key_value,
                    "date": date_value,
                    "slot_id": selectedSlot.slot_id,
                    "slot_time": selectedSlot.time,
                    "status": "Pending"
                  };

                  challenge_team_db.child(team_id).child(user_id)
                      .set(data)
                      .whenComplete(() {

                    ref1.child(user_id).once().then((DataSnapshot datasnapshot)
                    {
                      title = "Match Challenge";
                      body = "${datasnapshot.value['team_name']} challenge you on ${date_value} and time ${selectedSlot
                          .time}";
                      sendNotificationDataToFirebase(team.user_id,title,body);
                      print("Token : $token");
                      progressDialog.hide();
                      Fluttertoast.showToast(
                          msg: "Challenge Sent Successfully",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1
                      );
                      Navigator.pushReplacement(context,
                          new MaterialPageRoute(builder: (context) {
                            return HomeScreen();
                          }));
                    });

                  });
                });
              }
            });
          }


      });

    });



  }
}
