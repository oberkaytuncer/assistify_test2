import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  final String userID;
  String email;
  String userName;
  String profilePhotoURL;
  DateTime createdAt;
  DateTime updatedAt;
  int level;
  int activeClient;
  int totalLesson;
  String gsmNumber;
  int tall;
  int weight;
  String website;
  String cv;
  String languagePreference;
  String membershipPackage;

  @override
  String toString() {
    return 'User{userID: $userID, email: $email, userName: $userName, profilePhotoURL: $profilePhotoURL, createdAt: $createdAt, updatedAt: $updatedAt, level: $level, activeClient: $activeClient, totalLesson: $totalLesson, gsmNumber: $gsmNumber, tall: $tall, weight: $weight, website: $website, cv: $cv, languagePreference: $languagePreference, membershipPackage: $membershipPackage } ';
  }

  User({@required this.userID, @required this.email});

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'email': email,
      'userName': userName ??
          email.substring(0, email.indexOf('@')) + generateRandomNumber(),
      'profilePhotoURL':
          profilePhotoURL ?? 'https://www.assistify.co/resimler/assLogo.png',
      'createdAt': createdAt ??
          FieldValue
              .serverTimestamp(), //burada firestorun kendi server'a yazılma saatini alıyoruz burada.
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
      'level': level ?? 1,
      'activeClient': activeClient ?? 16,
      'totalLesson': totalLesson ?? 104,
      'gsmNumber': gsmNumber ?? '0555 555 55 55',
      'tall': tall ?? 185,
      'weight': weight ?? 90,
      'website': website ?? 'www.assistify.co/homepage',
      'cv': cv ?? '',
      'languagePreference': languagePreference ?? 'Türkçe',
      'membershipPackage': membershipPackage ?? 'Aylık',
    };
  }

  User.fromMap(Map<String, dynamic> map)
      : userID = map['userID'],
        email = map['email'],
        userName = map['userName'],
        profilePhotoURL = map['profilePhotoURL'],
        createdAt = (map['createdAt'] as Timestamp).toDate(),
        updatedAt = (map['updatedAt'] as Timestamp).toDate(),
        level = map['level'],
        activeClient = map['activeClient'],
        totalLesson = map['totalLesson'],
        gsmNumber = map['gsmNumber'],
        tall = map['tall'],
        weight = map['weight'],
        website = map['website'],
        cv = map['cv'],
        languagePreference = map['languagePreference'],
        membershipPackage = map['membershipPackage']
        ;

  String generateRandomNumber() {
    int randomNumber = Random().nextInt(9999999);
    return randomNumber.toString();
  }
}
