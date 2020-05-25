import 'package:firebase_database/firebase_database.dart';

class Studio{
  String studioID;
  String name;
  String size;
  double lat;
  double long;
  String address;
  String about;
  String picture;

  Studio(this.name,this.size,this.lat,this.long,this.address,this.about,this.picture);

  Studio.fromMap(DataSnapshot snapshot)
    :   studioID = snapshot.value['studioID'],
        name = snapshot.value['name'],
        size = snapshot.value['size'],
        lat = snapshot.value['lat'],
        long = snapshot.value['long'],
        address = snapshot.value['address'],
        about = snapshot.value['about'],
        picture = snapshot.value['picture'];


  toMap()
  {
    return {
      "studioID": studioID,
      "name": name,
      "size": size,
      "lat": lat,
      "long": long,
      "address": address,
      "about": about,
      "picture": picture
    };
  }

 




}