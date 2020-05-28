import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Studio {
  String ownerID;
  String studioID;
  String name;
  String size;
  double lat;
  double long;
  String address;
  String about;
  String picture;

  Studio({
    this.ownerID,
    this.studioID,
    this.name,
    this.size,
    this.lat,
    this.long,
    this.address,
    this.about,
    this.picture,
  });

  Studio.withStudioID(this.studioID, this.ownerID);

  @override
  String toString() {
    return 'Studio{ ownerID: ownerID ,studioID: $studioID ,name: $name, size: $size, lat: $lat, long: $long, address: $address,  about: $about,  picture: $picture} ';
  }

  Studio.fromMap(Map<String, dynamic> map)
      : ownerID = map['ownerID'],
        studioID = map['studioID'],
        name = map['name'],
        size = map['size'],
        lat = map['lat'],
        long = map['long'],
        address = map['address'],
        about = map['about'],
        picture = map['picture'];

  toMap() {
    return {
      "ownerID": ownerID,
      "studioID": studioID,
      "name": name ?? 'MacFIT',
      "size": size ?? '5*5',
      "lat": lat ?? 0.0,
      "long": long ?? 0.0,
      "address": address ?? '',
      "about": about ?? '',
      "picture": picture ?? 'https://www.assistify.co/resimler/assLogo.png'
    };
  }
}
