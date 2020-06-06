import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
class User{

  String name;
  String phone;
  String email;
  String city;
  String role;
  String age;
  String gender;
  String team;
  String position;
  int postcount;
  int  followerscount;
  int followingcount;
  String picture;

  User(this.name,this.phone,this.email,this.city,this.role,this.age,this.gender,this.team,this.position,this.postcount,this.followerscount,this.followingcount,this.picture);

  User.fromSnapshot(DataSnapshot snapshot)
    :   name = snapshot.value['name'],
        email = snapshot.value['email'],
        phone = snapshot.value['phone'],
        city = snapshot.value['city'],
        role = snapshot.value['role'],
        age = snapshot.value['age'],
        gender = snapshot.value['gender'],
        team = snapshot.value['team'],
        position = snapshot.value['position'],
        postcount = snapshot.value['postcount'],
        followerscount = snapshot.value['followerscount'],
        picture = snapshot.value['picture'],
        followingcount = snapshot.value['followingcount'];

  toJson()
  {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "city": city,
      "role": role,
      "age": age,
      "gender": gender,
      "team": team,
      "position": position,
      "postcount": postcount,
      "followerscount": followerscount,
      "followingcount": followingcount,
      "picture": picture
    };
  }

  void set _name(String name)
  {
    this.name = name;
  }
  String get _name => name;

  void set _phone(String phone)
  {
    this.phone = phone;
  }
  String get _phone => phone;

  void set _city(String city)
  {
    this.city = city;
  }
  String get _city => city;

  void set _role(String role)
  {
    this.role = role;
  }
  String get _role => role;

  void set _team(String team)
  {
    this.team = team;
  }
  String get _team => team;

  void set _age(String age)
  {
    this.age = age;
  }
  String get _age => age;

  void set _gender(String gender)
  {
    this.gender = gender;
  }
  String get _gender => gender;

  void set _position(String position)
  {
    this.position = position;
  }
  String get _position => position;

  void set _postcount(int postcount)
  {
    this.postcount = postcount;
  }
  int get _postcount => postcount;

  void set _followerscount(int followerscount)
  {
    this.followerscount = followerscount;
  }
  int get _followerscount => followerscount;

  void set _followingcount(int followingcount)
  {
    this.followingcount = followingcount;
  }
  int get _followingcount => followingcount;


}