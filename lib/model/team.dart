import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class Team
{

  String team_name;
  String logo;
  String about;
  String website;
  String city;
  String user_id;
  int players;

  Team(this.team_name,this.logo,this.about,this.city,this.website,this.user_id,this.players);

  Team.fromSnapshot(DataSnapshot snapshot)
      :   team_name = snapshot.value['team_name'],
        logo = snapshot.value['team_logo'],
        about = snapshot.value['about'],
        city = snapshot.value['city'],
        website = snapshot.value['website'],
        user_id = snapshot.value['user_id'],
         players = snapshot.value['Players'];

  toJson()
  {
    return {
      "team_name": team_name,
      "team_logo": logo,
      "about": about,
      "city": city,
      "website": website,
      "user_id": user_id,
      "Players": players
    };
  }


}