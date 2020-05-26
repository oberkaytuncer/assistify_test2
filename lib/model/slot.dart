import 'package:flutter/material.dart';

class Slot {
  String slotOwnerID;
  String slotOwnerStudioID;
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

  Slot.withOwnerIDandSlotID({@required this.slotOwnerID, @required this.slotOwnerStudioID });


  Slot.fromMap(Map<String, dynamic> map)
      : 
        slotOwnerID = map['slotOwnerID'],
        slotOwnerStudioID = map['slotOwnerStudioID'],
        slot_id = map['slot_id'],
        time = map['time'],
        startTime = map['startTime'],
        endTime = map['endTime'],
        date = map['date'],
        status = map['status'],
        team1_logo = map['team1_logo'],
        team1_name = map['team1_name'],
        team2_logo = map['team2_logo'],
        team2_name = map['team2_name'];

  toMap() {
    return {

      "slotOwnerID": slotOwnerID,
      "slotOwnerStudioID": slotOwnerStudioID,
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





