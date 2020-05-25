import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
class Ground{

  String name;
  String size;
  double lat;
  double long;
  String address;
  String about;
  String picture;

  Ground(this.name,this.size,this.lat,this.long,this.address,this.about,this.picture);

  Ground.fromSnapshot(DataSnapshot snapshot)
    :   name = snapshot.value['name'],
        size = snapshot.value['size'],
        lat = snapshot.value['lat'],
        long = snapshot.value['long'],
        address = snapshot.value['address'],
        about = snapshot.value['about'],
        picture = snapshot.value['picture'];


  toJson()
  {
    return {
      "name": name,
      "size": size,
      "lat": lat,
      "long": long,
      "address": address,
      "about": about,
      "picture": picture
    };
  }

  void set _name(String name)
  {
    this.name = name;
  }
  String get _name => name;


  void set _lat(double lat)
  {
    this.lat = lat;
  }
  double get _lat => lat;

  void set _long(double long)
  {
    this.long = long;
  }
  double get _long => long;

  void set _address(String address)
  {
    this.address = address;
  }
  String get _address => address;

  void set _about(String about)
  {
    this.about = about;
  }
  String get _about => about;




}