import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  String fullName;
  String city;
  String role;
  String age;
  String gender;
  String team;
  String position;
  int postcount;
  int followerscount;
  int followingcount;
  final String userID;
  String email;
  String userName;
  String profilePhotoURL;
  DateTime createdAt;
  DateTime updatedAt;
  int level;
  int activeClient;
  int totalLesson;
  String phoneNumber;
  int tall;
  int weight;
  String website;
  String cv;
  String languagePreference;
  String membershipPackage;
  bool active;

  @override
  String toString() {
    return 'User{ fullName: $fullName ,city: $city, role: $role, age: $age, gender: $gender, team: $team,  position: $position,  postcount: $postcount,  followerscount: $followerscount,  followingcount: $followingcount, userID: $userID, email: $email, userName: $userName, profilePhotoURL: $profilePhotoURL, createdAt: $createdAt, updatedAt: $updatedAt, level: $level, activeClient: $activeClient, totalLesson: $totalLesson, phoneNumber: $phoneNumber, tall: $tall, weight: $weight, website: $website, cv: $cv, languagePreference: $languagePreference, membershipPackage: $membershipPackage, active: $active } ';
  }

  User({@required this.userID, @required this.email});

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName ?? '',
      'city': city ?? 'İstanbul',
      'role': role ?? 'Personal Coach',
      'age': age ?? '25',
      'gender': gender ?? 'Kadın',
      'team': team ?? 'Bireysel',
      'position': position ?? 'Freelance',
      'postcount': postcount ?? 0,
      'followerscount': followerscount ?? 0,
      'followingcount': followingcount ?? 0,
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
      'phoneNumber': phoneNumber ?? '0555 555 55 55',
      'tall': tall ?? 185,
      'weight': weight ?? 90,
      'website': website ?? 'www.assistify.co/homepage',
      'cv': cv ?? '',
      'languagePreference': languagePreference ?? 'Türkçe',
      'membershipPackage': membershipPackage ?? 'Free',
      'active': active ?? true,
    };
  }

  User.idAndProfilePhotoURL(
      {@required this.userID, @required this.profilePhotoURL});

  User.forDefaultData(
      {@required this.email,
      @required this.userID,
      @required this.phoneNumber,
      });

  User.fromMap(Map<String, dynamic> map)
      : fullName = map['fullName'],
        city = map['city'],
        role = map['role'],
        age = map['age'],
        gender = map['gender'],
        team = map['team'],
        position = map['position'],
        postcount = map['postcount'],
        followerscount = map['followerscount'],
        followingcount = map['followingcount'],
        userID = map['userID'],
        email = map['email'],
        userName = map['userName'],
        profilePhotoURL = map['profilePhotoURL'],
        createdAt = (map['createdAt'] as Timestamp).toDate(),
        updatedAt = (map['updatedAt'] as Timestamp).toDate(),
        level = map['level'],
        activeClient = map['activeClient'],
        totalLesson = map['totalLesson'],
        phoneNumber = map['phoneNumber'],
        tall = map['tall'],
        weight = map['weight'],
        website = map['website'],
        cv = map['cv'],
        languagePreference = map['languagePreference'],
        membershipPackage = map['membershipPackage'],
        active = map['active'];

  String generateRandomNumber() {
    int randomNumber = Random().nextInt(9999999);
    return randomNumber.toString();
  }
}
