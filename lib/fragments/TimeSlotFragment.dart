import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_messaging_app/Calender/flutter_calendar.dart';
import 'package:flutter_messaging_app/Pages/AddMonthlySlotScreen.dart';
import 'package:flutter_messaging_app/Pages/AddSlotScreen.dart';
import 'package:flutter_messaging_app/Pages/EditSlotScreen.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter_messaging_app/utils/User_Defaults.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_messaging_app/Models/Slot.dart';

class TimeSlotFragment extends StatefulWidget {
  @override
  _TimeSlotFragmentState createState() => _TimeSlotFragmentState();
}

class _TimeSlotFragmentState extends State<TimeSlotFragment> {
  User_Defualts user_defualts = new User_Defualts();
  String drawer_picture;
  String uid;
  String selectDate = new DateTime.now().toString();

  DatabaseReference grounds_db =
      FirebaseDatabase.instance.reference().child("grounds");
  ProgressDialog progressDialog;
  var globalKey = GlobalKey<RefreshIndicatorState>();
  List<Slot> slots = null;

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  //Get Data of Slots
  Future<Null> getData() async {
    globalKey.currentState?.show();
    await Future.delayed(Duration(seconds: 2));
    slots = [];
    slots.clear();
    setState(() {});
    String date = "";
    DateTime dateTime = DateTime.parse(selectDate);
    int day = dateTime.day;
    int month = dateTime.month;
    int year = dateTime.year;
    date = "$day-$month-$year";

    FirebaseAuth.instance.currentUser().then((user) {
      grounds_db
          .child(user.uid)
          .child("Slots")
          .child(date)
          .once()
          .then((DataSnapshot datasnapshot) {
        if (datasnapshot != null && datasnapshot.value != null) {
          slots.clear();
          var keys = datasnapshot.value.keys;
          var data = datasnapshot.value;
          for (var key in keys) {
            setState(() {
              Slot d = new Slot(
                  data[key]['slot_id'],
                  data[key]['time'],
                  data[key]['startTime'],
                  data[key]['endTime'],
                  data[key]['date'],
                  data[key]['status'],
                  data[key]['team1_logo'],
                  data[key]['team1_name'],
                  data[key]['team2_logo'],
                  data[key]['team2_name']);
              slots.add(d);
            });
          }
          print("Length of List ${slots.length}");
        } else {
          print("Length of List ${slots.length}");
        }
      });
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Container(
                  child: new Calendar(
                    onDateSelected: (value) {
                      selectDate = value.toString();
                      getData();
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                      margin: const EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0),
                      child: RefreshIndicator(
                          key: globalKey,
                          child: slots == null
                              ? new Container(
                                  width: 50,
                                  height: 50,
                                  alignment: Alignment.center,
                                  child: new CircularProgressIndicator(),
                                )
                              : slots.length == 0
                                  ? new Text(
                                      "No Slot Available",
                                      style: TextStyle(
                                          color: HexColor("39B54A"),
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    )
                                  : new ListView.builder(
                                      itemCount: slots.length,
                                      itemBuilder: (_, index) {
                                        return Slidable(
                                          actionExtentRatio: 0.25,
                                          actionPane: SlidableDrawerActionPane(),
                                          secondaryActions: <Widget>[
                                            IconSlideAction(
                                              caption: 'Edit',
                                              color: Colors.green,
                                              icon: Icons.edit,
                                              onTap: () {
                                                Navigator.pushReplacement(
                                                    context,
                                                    new MaterialPageRoute(
                                                        builder: (context) {
                                                  return EditSlotScreen(
                                                    slot: slots[index],
                                                  );
                                                }));
                                              },
                                            ),
                                            IconSlideAction(
                                              caption: 'Delete',
                                              color: Colors.red,
                                              icon: Icons.delete,
                                              onTap: () {
                                                deleteSlot(slots[index],
                                                    context, index);
                                              },
                                            ),
                                          ],
                                          child: listitem(
                                            slots[index].time,
                                            slots[index].status,
                                            slots[index].team1_logo,
                                            slots[index].team2_logo,
                                            slots[index].team1_name,
                                            slots[index].team2_name,
                                          ),
                                        );
                                      },
                                    ),
                          onRefresh: getData)),
                )
              ],
            )
          ],
        ),
      ),
      floatingActionButton: Container(
          width: 300.0,
          height: 50.0,
          child: new Row(
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child: new RaisedButton(
                      color: HexColor("39B54A"),
                      onPressed: () {
                        addTimeSlot1(context);
                      },
                      child: Text("Add One Slot",
                          style: TextStyle(
                              color: HexColor("FFFFFF"), fontSize: 14.0)),
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0)))),
              Padding(padding: EdgeInsets.only(right: 2.5, left: 2.5)),
              Expanded(
                  flex: 1,
                  child: new RaisedButton(
                      color: HexColor("39B54A"),
                      onPressed: () {
                        addTimeSlot(context);
                      },
                      child: Text("Add Monthly Slots",
                          style: TextStyle(
                              color: HexColor("FFFFFF"), fontSize: 14.0)),
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0))))
            ],
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  //Add Monthly Slot Implementation
  void addTimeSlot(BuildContext context) {
    Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return AddMonthlySlotScreen(
        text: selectDate,
      );
    }));
  }

  //Implementation of One Day Slot
  void addTimeSlot1(BuildContext context) {
    Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return AddSlotScreen(
        text: selectDate,
      );
    }));
  }

  //Delete Slot From Firebase RealTime Database
  void deleteSlot(Slot slot, BuildContext context, int index) {
    progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
    progressDialog.show();
    FirebaseAuth.instance.currentUser().then((user) {
      grounds_db
          .child(user.uid)
          .child("Slots")
          .child(slot.date)
          .child(slot.slot_id)
          .remove()
          .whenComplete(() {
        slots.removeAt(index);
        //progressDialog.dismiss();
        setState(() {
          Fluttertoast.showToast(
              msg: "Slot Deleted Successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1);
        });
      }).catchError((e) {
        //  progressDialog.dismiss();
        Fluttertoast.showToast(
            msg: "There is some Error.Try Again",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
      });
    });
  }

  //Slot List Item
  listitem(String time, String status, logo1, logo2, name1, name2) {
    if (status == "Booked") {
      return new Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(27.0)),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(5.0),
                child: CircleAvatar(
                    backgroundColor: HexColor("39B54A"),
                    radius: 40.0,
                    child: ClipOval(
                        child: (logo1 != "")
                            ? Image.network(
                                logo1,
                                width: 65,
                                height: 65,
                                fit: BoxFit.cover,
                              )
                            : new Container())),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                  padding: EdgeInsets.all(5.0),
                  child: Align(
                      alignment: Alignment.center,
                      child: new Column(
                        children: <Widget>[
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Text(
                                time,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Column(
                                children: <Widget>[
                                  new Text(
                                    name1,
                                    style: TextStyle(
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  new Text(
                                    " vs ",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  new Text(
                                    name2,
                                    style: TextStyle(
                                      fontSize: 15.0,
                                    ),
                                  )
                                ],
                              )
                            ],
                          )
                        ],
                      ))),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(5.0),
                child: CircleAvatar(
                    backgroundColor: HexColor("39B54A"),
                    radius: 40.0,
                    child: ClipOval(
                        child: (logo2 != "")
                            ? Image.network(
                                logo2,
                                width: 65,
                                height: 65,
                                fit: BoxFit.cover,
                              )
                            : new Container())),
              ),
            ),
          ],
        ),
      );
    } else {
      return new Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(27.0)),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(5.0),
                child: CircleAvatar(
                    backgroundColor: Colors.black12,
                    radius: 40.0,
                    child: ClipOval(
                        child: (logo1 != "")
                            ? Image.network(
                                "" + logo1,
                                width: 65,
                                height: 65,
                                fit: BoxFit.cover,
                              )
                            : new Container())),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                  padding: EdgeInsets.all(5.0),
                  child: Align(
                      alignment: Alignment.center,
                      child: new Column(
                        children: <Widget>[
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Text(
                                time,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Text(
                                "                                        ",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    backgroundColor: Colors.black12),
                              )
                            ],
                          )
                        ],
                      ))),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(5.0),
                child: CircleAvatar(
                    backgroundColor: Colors.black12,
                    radius: 40.0,
                    child: ClipOval(
                        child: (logo2 != "")
                            ? Image.network(
                                "" + logo1,
                                width: 65,
                                height: 65,
                                fit: BoxFit.fitHeight,
                              )
                            : new Container())),
              ),
            ),
          ],
        ),
      );
    }

    /*return new Card(
        elevation: 12.0,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20.0)),
        child: new Container(
          height: 126.0,
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
                                  backgroundColor:
                                  HexColor("39B54A"),
                                  radius: 50.0,
                                  child: ClipOval(
                                    child:
                                    (logo!=null)?Image.network(""+logo,width: 92,height: 92,fit: BoxFit.fill,)
                                        :Image.asset(
                                      "assets/logo.png",
                                      width: 92.0,
                                      height: 92.0,
                                    ),
                                  )
                              ),
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
                                  color: Colors.black54,
                                  fontSize: 26.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                              alignment: FractionalOffset.centerLeft,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: FlatButton.icon(
                                  color: Colors.transparent,
                                  onPressed: null,
                                  icon: Icon(Icons.location_on),
                                  label: Text(
                                    city,
                                    style: TextStyle(
                                      color: Colors.black38,
                                      fontSize: 18.0,
                                    ),
                                  ))),
                          new Container(
                            alignment: FractionalOffset.topLeft,
                            child: new Text(
                              about,
                              style: TextStyle(
                                  color: Colors.black26,
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
        ));*/
  }
}
