import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gson/gson.dart';
import 'package:intl/intl.dart';
import 'package:flutter_messaging_app/Map/Maps.dart';
import 'package:flutter_messaging_app/Models/Ground.dart';
import 'package:flutter_messaging_app/Models/User.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:flutter_messaging_app/utils/strings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:country_pickers/country.dart';
import 'package:flutter/services.dart';
import 'package:flutter_messaging_app/fragments/TimeSlotFragment.dart';
import 'package:flutter_messaging_app/Pages/HomeScreen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter_messaging_app/utils/User_Defaults.dart';
import 'package:flutter_messaging_app/Models/User.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert' show JSON;

class AddMonthlySlotScreen extends StatefulWidget {
  String text;

  AddMonthlySlotScreen({Key key, @required this.text}) : super(key: key);

  @override
  _AddMonthlySlotScreenState createState() =>
      _AddMonthlySlotScreenState(this.text);
}

class _AddMonthlySlotScreenState extends State<AddMonthlySlotScreen> {
  //String selectedDate;
  _AddMonthlySlotScreenState(this.date);

  String date = "";
  String selectedDate = "";
  String selectedStartTime = "";
  String selectedEndTime = "";
  String selectedStatus;
  var dateFieldController = TextEditingController();
  var startTimeFieldController = TextEditingController();

  ProgressDialog progressDialog;

  List<String> statuses = <String>['Not Booked', 'Booked'];

  TimeOfDay current_time = new TimeOfDay.now();

  List<int> _slotsCount = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  int selected_slot;
  Map<String, dynamic> map1 = Map<String, dynamic>();
  List totalSlots = List();
  List startTimes = List();
  List endTimes = List();
  TimeOfDay tmpStart = null;

  @override
  // TODO: implement initState
  void initState() {
    selected_slot = _slotsCount.elementAt(5);
    DateTime dateTime = DateTime.parse(date);
    int day = dateTime.day;
    int month = dateTime.month;
    int year = dateTime.year;
    selectedDate = "$day-$month-$year";
    setState(() {
      dateFieldController.text = selectedDate;
    });
    selectedStatus = statuses.first;
    super.initState();
  }

  List datesList = List();

  DatabaseReference ref =
      FirebaseDatabase.instance.reference().child("grounds");

  Future<Null> configureSlotsWithTime(BuildContext context) async {
    TimeOfDay timeOfDay;
    startTimes.clear();
    endTimes.clear();
    setState(() {});
    if (tmpStart == null) {
      timeOfDay =
          await showTimePicker(context: context, initialTime: current_time);
    } else {
      timeOfDay = tmpStart;
    }
    startTimeFieldController.text = "${timeOfDay.hour} : ${timeOfDay.minute}";
    if (timeOfDay != null) {
      setState(() {
        TimeOfDay tmpStartTime = timeOfDay;
        tmpStart = timeOfDay;
        for (int i = 0; i < selected_slot; i++) {
          print("Select Slots: $selected_slot");

          if ((tmpStartTime.hour > 21 && tmpStartTime.minute > 30) ||
              tmpStartTime.hour == 0 ||
              tmpStartTime.hour == 23) {
          } else {
            int hourstart = tmpStartTime.hour;
            int minutesstart = tmpStartTime.minute;

            DateTime now = DateTime.parse(date);
            DateTime dateTime = new DateTime(now.year, now.month, now.day,
                tmpStartTime.hour, tmpStartTime.minute);
            print("Time $tmpStartTime");
            DateTime end = dateTime.add(Duration(minutes: 90));
            TimeOfDay endTime = TimeOfDay.fromDateTime(end);
            tmpStartTime = endTime;
            String endtimePeriod;
            //endTime = endTime.replacing(hour: endTime.hourOfPeriod);

            int hourend = endTime.hour;
            int minutesend = endTime.minute;
            //String endTimePeriod = current_time.period.toString();
            selectedStartTime = "$hourstart:$minutesstart";
            selectedEndTime = "$hourend:$minutesend";
            startTimes.add(selectedStartTime);
            endTimes.add(selectedEndTime);
            print(
                "Start Time: $selectedStartTime and End Time: $selectedEndTime");

            //  endTimeFieldController.text = "$hourend:$minutesend $endtimePeriod";
          }
        }
        if (startTimes.length != selected_slot) {
          Fluttertoast.showToast(
              msg:
                  "Total Number of Slots: ${startTimes.length} because time greater then 11:59 PM",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1);
        } else {
          Fluttertoast.showToast(
              msg: "Total Number of Slots: ${startTimes.length}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Add Time Slot",
              style: TextStyle(color: HexColor("39B54A"), fontSize: 22.0)),
          backgroundColor: HexColor("FFFFFF"),
        ),
        body: Builder(
            builder: (context) => Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    new SingleChildScrollView(
                      child: Container(
                          margin: const EdgeInsets.only(
                              top: 10.0, left: 15.0, right: 15.0),
                          child: Column(
                            children: <Widget>[
                              Padding(padding: EdgeInsets.only(top: 20.0)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            new SizedBox(
                                                width: double.infinity,
                                                height: 40.0,
                                                child: new FlatButton(
                                                  onPressed: () {
                                                    configureSlotsWithTime(
                                                        context);

//
                                                  },
                                                  child: FlatButton.icon(
                                                      color: HexColor("39B54A"),
                                                      onPressed: null,
                                                      icon: Icon(
                                                        Icons.access_time,
                                                        color:
                                                            HexColor("35B54A"),
                                                        size: 35.0,
                                                      ),
                                                      label: Text(
                                                        "Select Start Time",
                                                        style: TextStyle(
                                                            color: HexColor(
                                                                "39B54A"),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16.0),
                                                      )),
                                                ))
                                          ],
                                        ),
                                      ))
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(top: 17.0)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            new SizedBox(
                                              width: double.infinity,
                                              height: 50.0,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  border: Border.all(
                                                      color: Colors.black38,
                                                      style: BorderStyle.solid,
                                                      width: 0.80),
                                                ),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                        child: DropdownButton(
                                                  items: statuses
                                                      .map((value) =>
                                                          DropdownMenuItem(
                                                            child: Text(value),
                                                            value: value,
                                                          ))
                                                      .toList(),
                                                  onChanged: (String value) {
                                                    setState(() {
                                                      selectedStatus = value;
                                                    });
                                                  },
                                                  isExpanded: true,
                                                  value: selectedStatus,
                                                )),
                                              ),
                                            )
                                          ],
                                        ),
                                      ))
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(top: 17.0)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            new SizedBox(
                                              width: double.infinity,
                                              height: 50.0,
                                              child: new TextField(
                                                enableInteractiveSelection:
                                                    false,
                                                enabled: false,
                                                controller: dateFieldController,
                                                decoration: new InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            20.0),
                                                    border:
                                                        new OutlineInputBorder(
                                                      borderSide:
                                                          new BorderSide(
                                                              color: HexColor(
                                                                  "39B54A")),
                                                    ),
                                                    hintText: 'Date',
                                                    labelText: 'Date',
                                                    suffixStyle:
                                                        const TextStyle(
                                                            color:
                                                                Colors.green)),
                                              ),
                                            )
                                          ],
                                        ),
                                      ))
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(top: 17.0)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            new SizedBox(
                                              width: double.infinity,
                                              height: 50.0,
                                              child: new TextField(
                                                enableInteractiveSelection:
                                                    false,
                                                enabled: false,
                                                controller:
                                                    startTimeFieldController,
                                                decoration: new InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            20.0),
                                                    border:
                                                        new OutlineInputBorder(
                                                      borderSide:
                                                          new BorderSide(
                                                              color: HexColor(
                                                                  "39B54A")),
                                                    ),
                                                    hintText: 'Start Time',
                                                    labelText: 'Start Time',
                                                    suffixStyle:
                                                        const TextStyle(
                                                            color:
                                                                Colors.green)),
                                              ),
                                            )
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(top: 25.0)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            new SizedBox(
                                              width: double.infinity,
                                              height: 50.0,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  border: Border.all(
                                                      color: Colors.black38,
                                                      style: BorderStyle.solid,
                                                      width: 0.80),
                                                ),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                        child: DropdownButton(
                                                  items: _slotsCount
                                                      .map((value) =>
                                                          DropdownMenuItem(
                                                            child:
                                                                Text("$value"),
                                                            value: value,
                                                          ))
                                                      .toList(),
                                                  onChanged: (int value) {
                                                    setState(() {
                                                      selected_slot = value;
                                                      configureSlotsWithTime(
                                                          context);
                                                    });
                                                  },
                                                  isExpanded: true,
                                                  value: selected_slot,
                                                )),
                                              ),
                                            )
                                          ],
                                        ),
                                      ))
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(top: 25.0)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            new SizedBox(
                                              width: double.infinity,
                                              height: 40.0,
                                              child: new RaisedButton(
                                                child: Text("SUBMIT",
                                                    style: TextStyle(
                                                        color:
                                                            HexColor("FFFFFF"),
                                                        fontSize: 14.0)),
                                                onPressed: () {
                                                  submitSlotData(context);
                                                },
                                                color: HexColor("39B54A"),
                                              ),
                                            )
                                          ],
                                        ),
                                      ))
                                ],
                              ),
                            ],
                          )),
                    )
                  ],
                )));
  }


  void submitSlotData(BuildContext context) {
    if (tmpStart == null || startTimeFieldController.text == "") {
      Fluttertoast.showToast(msg: "Please Select Start Time",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2);
    } else if (startTimes.length < 1) {
      Fluttertoast.showToast(msg: "Empty List of Slots.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2);
    } else if (selected_slot < startTimes.length) {
      Fluttertoast.showToast(msg: "Please choose Number of Slots and Time Again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2);
    } else {
      ProgressDialog progressDialog = ProgressDialog(context,type: ProgressDialogType.Normal);
      FirebaseAuth.instance.currentUser().then((User) {
        //Check if Date Data not Exists
        setState(() {
          checkDateDatainFirebase(progressDialog,context,User.uid);
        });

      });
    }
  }

  void checkDateDatainFirebase(ProgressDialog progressDialog,BuildContext context,String id) {
    progressDialog.show();
    DateTime datee = DateTime.parse(date);
    int count=0;
    datesList.clear();
    for (int i = 0; i < 30; i++) {
      print("Date Item : ${i+1}");
      String dateStr = "${datee.day}-${datee.month}-${datee.year}";
      //check date Data in Slots
      ref
          .child(id)
          .child("Slots")
          .child(dateStr)
          .once()
          .then((DataSnapshot dataSnapshot) {
        var keys = dataSnapshot.value;
        count = count+1;
        setState(() {
          if (keys == null) {
            datesList.add(dateStr);
            print("Date: - ${datesList}");
          }
        });
        if(count==30)
          {
            print("Uploading Data");
            //Upload Data
            uploadSlotsData(progressDialog,context,id);

          }
      });
      datee = datee.add(Duration(days: 1));
    }
  }

  void uploadSlotsData(ProgressDialog progressDialog,BuildContext context,String id) {
    Fluttertoast.showToast(
        msg: "Total ${datesList.length} days.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2);

    if (datesList.length < 1) {
      Fluttertoast.showToast(
          msg: "All Dates Slots Already Present",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2);
     // progressDialog.dismiss();
    } else {
      print("Uploading Data1");
      //Insert 30 Days Data
      int count = 0;
      for (int i = 0; i < datesList.length; i++) {
        var uuid = new Uuid();
        if (i == 0) {
          for (int j = 0; j < startTimes.length; j++) {
            String random_id = uuid.v1().toString();
            String startTime = startTimes.elementAt(j);
            String endTime = endTimes.elementAt(j);
            var data = {
              "slot_id": random_id,
              "time": "$startTime - $endTime",
              "startTime": startTime,
              "endTime": endTime,
              "status": selectedStatus,
              "team1_logo": "",
              "team1_name": "",
              "team2_logo": "",
              "team2_name": "",
              "date": datesList.elementAt(i)
            };
            map1[random_id] = data;
          }
        }
        ref
            .child(id)
            .child("Slots")
            .child(datesList.elementAt(i))
            .update(map1)
          ..whenComplete(() {
            count = count + 1;
            print("Count : $count and Length: ${datesList.length} ");
            if (count == datesList.length) {
              Fluttertoast.showToast(
                  msg:
                  "Total ${datesList.length} days per ${startTimes.length} slots added Successfully.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 2);
             // progressDialog.dismiss();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                      (Route<dynamic> route) => false);
            }
          }).catchError((e) {
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(
                    'There is Some Error, Try Again with Valid Info.')));
            print(e);
          });
      }
    }
  }
}
