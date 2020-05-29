import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/app/edit_slot_screen.dart';
import 'package:flutter_messaging_app/app/add_slot_daily.dart';
import 'package:flutter_messaging_app/app/add_slot_monthly.dart';
import 'package:flutter_messaging_app/model/slot.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_messaging_app/Calender/flutter_calendar.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';


class DashboardTab extends StatefulWidget {
  @override
  _DashboardTabState createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  
  
  String uid;
  String selectDate = new DateTime.now().toString();

  DatabaseReference grounds_db =
      FirebaseDatabase.instance.reference().child("grounds");
  ProgressDialog progressDialog;
  var globalKey = GlobalKey<RefreshIndicatorState>();
  List<Slot> slots = null;

  @override
  void initState() {
 
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

      await FirebaseAuth.instance.currentUser().then((user) {
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
                                  : ListView.builder(
                                      itemCount: slots.length,
                                      itemBuilder: (_, index) {
                                        return Slidable(
                                          actionExtentRatio: 0.25,
                                          actionPane:
                                              SlidableDrawerActionPane(),
                                          secondaryActions: <Widget>[
                                            IconSlideAction(
                                              caption: 'Edit',
                                              color: Colors.green,
                                              icon: Icons.edit,
                                              onTap: () {
                                                Navigator.pushReplacement(
                                                    context, MaterialPageRoute(
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
  void addTimeSlot1(BuildContext context)  {
    Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return AddSlotScreen(
        text: selectDate,
      );
    }));
  }

  //Delete Slot From Firebase RealTime Database *****yarın ilk iş bu delete olayına bak.
  void deleteSlot(Slot slot, BuildContext context, int index) async {
    DateTime dateTime = DateTime.parse(selectDate);
    int day = dateTime.day;
    int month = dateTime.month;
    int year = dateTime.year;
   var _date = "$day-$month-$year";
   


    progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
    progressDialog.show();
   await  FirebaseAuth.instance.currentUser().then((user) {
      grounds_db
          .child(user.uid)
          .child("Slots")
          .child(_date) //??
          .child(slot.slot_id)
          .remove()
          .whenComplete(() {
        slots.removeAt(index);
        progressDialog.hide();
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
  }
}
