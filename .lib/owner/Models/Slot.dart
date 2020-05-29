import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class Slot {

  String slot_id;
  String time;
  String startTime;
  String endTime;
  String date;
  String status;
  String team1_logo;
  String team2_logo;
  String team1_name;
  String team2_name;

  Slot(this.slot_id,this.time, this.startTime, this.endTime, this.date, this.status, this.team1_logo, this.team1_name,
      this.team2_logo, this.team2_name);


  Slot.fromSnapshot(DataSnapshot snapshot)
      : slot_id = snapshot.value['slot_id'],
        time = snapshot.value['time'],
        startTime = snapshot.value['startTime'],
        endTime = snapshot.value['endTime'],
        date = snapshot.value['date'],
        status = snapshot.value['status'],
        team1_logo = snapshot.value['team1_logo'],
        team1_name = snapshot.value['team1_name'],
        team2_logo = snapshot.value['team2_logo'],
        team2_name = snapshot.value['team2_name'];

  toJson() {
    return {
      "slot_id": slot_id,
      "time": time,
      "startTime": startTime,
      "endTime": endTime,
      "date": date,
      "status": status,
      "team1_logo": team1_logo,
      "team1_name": team1_name,
      "team2_logo": team2_logo,
      "team2_name": team2_name
    };
  }
}
