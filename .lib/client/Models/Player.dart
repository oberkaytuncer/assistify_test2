import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class Player
{

  String player_name;
  String player_id;
  String player_position;
  String player_age;
  String player_city;
  String player_picture;
  String player_phone;

  Player(this.player_name,this.player_id,this.player_position,this.player_age,this.player_city,this.player_picture,this.player_phone);


}