import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class ChallengesRequest
{

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

  ChallengesRequest(this.sender_team_name,this.opponent_team_name,this.sender_team_id,this.opponent_team_id,
      this.date,this.ground_id,this.slot_id,this.slot_time,this.ground_name,this.ground_address,this.sender_team_picture,this.opponent_team_picture);





}