import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/app/dashboard_tab.dart';
import 'package:flutter_messaging_app/common_widget/platform_sensetive_widget/platform_sensetive_alert_dialog.dart';
import 'package:flutter_messaging_app/model/slot.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:flutter_messaging_app/view_model/user_model.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddSlotScreenDaily extends StatefulWidget {
  String text;
  AddSlotScreenDaily({Key key, @required this.text}) : super(key: key);
  @override
  _AddSlotScreenDailyState createState() => _AddSlotScreenDailyState(this.text);
}

class _AddSlotScreenDailyState extends State<AddSlotScreenDaily> {
  _AddSlotScreenDailyState(this.date);
  String date = "";
  String selectedDate = "";
  String selectedEndTime = "";
  String selectedStartTime = "";
  String selectedStatus;
  var dateFieldController = TextEditingController();
  var startTimeFieldController = TextEditingController();
  var endTimeFieldController = TextEditingController();
  ProgressDialog progressDialog;
  List<String> statuses = <String>['Not Booked', 'Booked'];
  TimeOfDay current_time = new TimeOfDay.now();

  @override
  void initState() {
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

  Future<Null> selectTime(BuildContext context) async {
    final TimeOfDay timeOfDay =
        await showTimePicker(context: context, initialTime: current_time);

    if (timeOfDay != null) {
      setState(() {
        print(timeOfDay.hour);
        print(timeOfDay.minute);
        if (timeOfDay.hour > 21 && timeOfDay.minute > 29) {
          Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Text("You Cannot Choose Time greater then 10:29 PM"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3)));
        } else {
          TimeOfDay t = timeOfDay.replacing(hour: timeOfDay.hourOfPeriod);
          int hourstart = t.hour;
          int minutesstart = t.minute;
          String starttimePeriod;
          if (timeOfDay.hour > 12) {
            starttimePeriod = "PM";
          } else {
            starttimePeriod = "AM";
          }

          DateTime now = DateTime.parse(date);
          DateTime dateTime = new DateTime(
              now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
          DateTime end = dateTime.add(Duration(minutes: 90));
          TimeOfDay endTime = TimeOfDay.fromDateTime(end);
          String endtimePeriod;
          if (endTime.hour > 12) {
            endtimePeriod = "PM";
          } else {
            endtimePeriod = "AM";
          }
          endTime = endTime.replacing(hour: endTime.hourOfPeriod);

          int hourend = endTime.hour;
          int minutesend = endTime.minute;
          selectedStartTime = "$hourstart:$minutesstart $starttimePeriod";
          selectedEndTime = "$hourend:$minutesend $endtimePeriod";
          startTimeFieldController.text =
              "$hourstart:$minutesstart $starttimePeriod";
          endTimeFieldController.text = "$hourend:$minutesend $endtimePeriod";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  margin:
                      const EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    new SizedBox(
                                        width: double.infinity,
                                        height: 40.0,
                                        child: new FlatButton(
                                          onPressed: () {
                                            selectTime(context);
                                          },
                                          child: FlatButton.icon(
                                              color: HexColor("39B54A"),
                                              onPressed: null,
                                              icon: Icon(
                                                Icons.access_time,
                                                color: HexColor("35B54A"),
                                                size: 35.0,
                                              ),
                                              label: Text(
                                                "Select Start Time",
                                                style: TextStyle(
                                                    color: HexColor("39B54A"),
                                                    fontWeight: FontWeight.bold,
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    new SizedBox(
                                      width: double.infinity,
                                      height: 50.0,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          border: Border.all(
                                              color: Colors.black38,
                                              style: BorderStyle.solid,
                                              width: 0.80),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                            child: DropdownButton(
                                          items: statuses
                                              .map((value) => DropdownMenuItem(
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    new SizedBox(
                                      width: double.infinity,
                                      height: 50.0,
                                      child: new TextField(
                                        enableInteractiveSelection: false,
                                        enabled: false,
                                        controller: dateFieldController,
                                        decoration: new InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.all(20.0),
                                            border: new OutlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: HexColor("39B54A")),
                                            ),
                                            hintText: 'Date',
                                            labelText: 'Date',
                                            suffixStyle: const TextStyle(
                                                color: Colors.green)),
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
                              flex: 2,
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    new SizedBox(
                                      width: double.infinity,
                                      height: 50.0,
                                      child: new TextField(
                                        enableInteractiveSelection: false,
                                        enabled: false,
                                        controller: startTimeFieldController,
                                        decoration: new InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.all(20.0),
                                            border: new OutlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: HexColor("39B54A")),
                                            ),
                                            hintText: 'Start Time',
                                            labelText: 'Start Time',
                                            suffixStyle: const TextStyle(
                                                color: Colors.green)),
                                      ),
                                    )
                                  ],
                                ),
                              )),
                          Expanded(
                            flex: 1,
                            child: Container(
                                padding: EdgeInsets.all(5.0),
                                child: Align(
                                    alignment: Alignment.center,
                                    child: new Column(
                                      children: <Widget>[
                                        new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            new Text(
                                              "-",
                                              style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                      ],
                                    ))),
                          ),
                          Expanded(
                              flex: 2,
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    new SizedBox(
                                      width: double.infinity,
                                      height: 50.0,
                                      child: new TextField(
                                        enableInteractiveSelection: false,
                                        enabled: false,
                                        controller: endTimeFieldController,
                                        decoration: new InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.all(20.0),
                                            border: new OutlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: HexColor("39B54A")),
                                            ),
                                            hintText: 'End Time',
                                            labelText: 'End Time',
                                            suffixStyle: const TextStyle(
                                                color: Colors.green)),
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    new SizedBox(
                                      width: double.infinity,
                                      height: 40.0,
                                      child: new RaisedButton(
                                        child: Text("SUBMIT",
                                            style: TextStyle(
                                                color: HexColor("FFFFFF"),
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
        ),
      ),
    );
  }

  void submitSlotData(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);

    if (selectedDate != null && selectedDate != "") {
      if (selectedStartTime != null &&
          selectedStartTime != "" &&
          selectedEndTime != null &&
          selectedEndTime != "") {
        var uuid = new Uuid();
        progressDialog =
            ProgressDialog(context, type: ProgressDialogType.Normal);
        progressDialog.show();
        String random_id = uuid.v1().toString();
        
        var result = await _userModel.addSlotDataDaily(
          _userModel.user.userID,
          Slot(
            slot_id: random_id,
            time: "$selectedStartTime - $selectedEndTime",
            startTime: selectedStartTime,
            endTime: selectedEndTime,
            status: selectedStatus,
            date: selectedDate,
          ),
        );

        if (result) {
          progressDialog.hide();

          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => DashboardTab()),
              (Route<dynamic> route) => false);
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text('Slot Add Successfully')));
        } else {
          print('günlük slot eklerken hata çıktı.');
          Scaffold.of(context).showSnackBar(SnackBar(
              content:
                  Text('There is Some Error, Try Again with Valid Info.')));
        }

      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text("Lütfen bir zaman aralığı seçin"),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("Date no Selected"),
        backgroundColor: Colors.red,
      ));
    }
  }
}
