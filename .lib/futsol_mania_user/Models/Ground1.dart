import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
class Ground1{

  String name;
  String ground_id;


  Ground1(this.ground_id,this.name);

  Ground1.fromSnapshot(DataSnapshot snapshot)
    :   ground_id = snapshot.value['ground_id'],
        name = snapshot.value['name'];

  toJson()
  {
    return {
      "ground_id": ground_id,
      "name": name
    };
  }

}