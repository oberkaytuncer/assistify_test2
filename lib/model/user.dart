import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  final String userID;
  String email;
  String userName;
  String profileURL;
  DateTime createdAt;
  DateTime updatedAt;
  int level;
  @override
  String toString() {
    return 
    'User{userID: $userID, email: $email, userName: $userName, profileURL: $profileURL, createdAt: $createdAt, updatedAt: $updatedAt, level: $level} ';
  }

  User({@required this.userID, @required this.email});

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'email': email,
      'userName': userName ?? email.substring(0 ,email.indexOf('@')) +  generateRandomNumber(),
      'profileURL':
          profileURL ?? 'https://www.assistify.co/resimler/assLogo.png',
      'createdAt': createdAt ??
          FieldValue
              .serverTimestamp(), //burada firestorun kendi server'a yazılma saatini alıyoruz burada.
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
      'level': level ?? 1,
    };
  }

  User.fromMap(Map<String, dynamic> map)
      : userID = map['userID'],
        email = map['email'],
        userName = map['userName'],
        profileURL = map['profileURL'],
        createdAt = (map['createdAt'] as Timestamp).toDate(),
        updatedAt = (map['updatedAt'] as Timestamp).toDate(),
        level = map['level'];

  String       generateRandomNumber(){
    int randomNumber = Random().nextInt(9999999);
    return randomNumber.toString();
  }
}
