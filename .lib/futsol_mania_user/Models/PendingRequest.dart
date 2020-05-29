import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class PendingRequest
{

  String team_name;
  String player_name;
  String team_id;
  String player_id;
  String phone_no;
  String city;
  String age;
  String position;
  String player_picture;

  PendingRequest(this.team_name,this.player_name,this.team_id,this.player_id,this.phone_no,this.city,this.age,this.position,this.player_picture);


  toJson()
  {
    return {
      "team_name": team_name,
      "player_name": player_name,
      "team_id": team_id,
      "player_id": player_id,
      "city": city,
      "phone_no": phone_no,
      "city": city,
      "age": age,
      "position": position,
      "player_picture": player_picture
    };
  }


}