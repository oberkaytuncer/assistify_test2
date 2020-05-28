import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/Calender/flutter_calendar.dart';
import 'package:flutter_messaging_app/app/add_slot_daily.dart';
import 'package:flutter_messaging_app/app/add_slot_monthly.dart';
import 'package:flutter_messaging_app/model/slot.dart';
import 'package:flutter_messaging_app/view_model/user_model.dart';
import 'package:provider/provider.dart';

class DashboardTab extends StatelessWidget {
  var globalKey = GlobalKey<RefreshIndicatorState>();
  String selectDate = new DateTime.now().toString();
  List<Slot> slots = null;

  Future<Null> getData() async {
    globalKey.currentState?.show();
    await Future.delayed(Duration(seconds: 2));
    slots = [];
    slots.clear();

    String date = "";
    DateTime dateTime = DateTime.parse(selectDate);
    int day = dateTime.day;
    int month = dateTime.month;
    int year = dateTime.year;
    date = "$day-$month-$year";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Calendar(
            onDateSelected: (value) {
              selectDate = value.toString();
            },
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: new RaisedButton(
                  color: Colors.pink,
                  child: Text(
                    "Add One Slot",
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0),
                  ),
                  onPressed: () {
                    addTimeSlotDaily(context);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 2.5, left: 2.5),
              ),
              Expanded(
                flex: 1,
                child: new RaisedButton(
                  color: Colors.red,
                  onPressed: () {
                    addTimeSlotMonthly(context);
                  },
                  child: Text(
                    "Add Monthly Slots",
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void addTimeSlotDaily(BuildContext context) {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) {
          return AddSlotScreenDaily(
            text: selectDate,
          );
        },
      ),
    );
  }

  void addTimeSlotMonthly(BuildContext context) {
    
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) {
          return AddSlotScreenMonthly(
            text: selectDate,
          );
        },
      ),
    );
  }
}
