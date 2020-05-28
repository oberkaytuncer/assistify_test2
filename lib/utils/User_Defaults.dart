import 'package:flutter_messaging_app/Models/Ground.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_messaging_app/Models/User.dart';
class User_Defualts {

  Future<String> getUserPhoneNumber() async
  {
    final prefs = await SharedPreferences.getInstance();
    final PhoneNumber = prefs.getString("phonenumber_owner");
    return PhoneNumber;
  }

  Future<String> getUserUserID() async
  {
    final prefs = await SharedPreferences.getInstance();
    final user_id = prefs.getString("user_id_owner");
    return user_id;
  }

  Future<String> getUserName() async
  {
    final prefs = await SharedPreferences.getInstance();
    final user_name = prefs.getString("user_name_owner");
    return user_name;
  }

  Future<String> getGroundName() async
  {
    final prefs = await SharedPreferences.getInstance();
    final ground_name = prefs.getString("ground_name_owner");
    return ground_name;
  }

  Future<double> getGroundLatitude() async
  {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble("latitude");
    return latitude;
  }

  Future<double> getGroundLongitude() async
  {
    final prefs = await SharedPreferences.getInstance();
    final longitude = prefs.getDouble("longitude");
    return longitude;
  }
//buradan sonrakiler sharedPreference ye yazma işlemi..

  Future<bool> setPhoneandUserID(String phone,String user_id) async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("phonenumber_owner", phone);
    prefs.setString("user_id_owner", user_id);
    return prefs.commit();
  }

  Future<bool> saveUserData(User user) async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("user_name_owner", user.name);
    prefs.setString("user_phone_owner", user.phone);
    prefs.setString("user_city_owner", user.city);
    prefs.setString("user_picture_owner", user.picture);
    return prefs.commit();
  }

  Future<bool> saveGroundLocation(double latitude,double longitude) async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble("latitude",latitude);
    prefs.setDouble("longitude",longitude);
    return prefs.commit();
  }

  Future<bool> saveGroundData(Ground ground) async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("ground_name_owner", ground.name);
    prefs.setString("ground_image_owner", ground.picture);
    prefs.setString("ground_location_owner", ground.address);
    return prefs.commit();
  }

  Future<bool> logout() async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("user_name_owner","");
    prefs.setString("user_phone_owner","");
    prefs.setString("ground_name_owner","");
    prefs.setString("ground_image_owner", "");
    prefs.setString("user_city_owner","");
    prefs.setString("user_picture_owner", "");
    prefs.setString("phonenumber_owner", "");
    prefs.setString("user_id_owner", "");
    return prefs.commit();
  }



  Future<bool> saveUserData1(Map<dynamic,dynamic> user) async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("user_name_owner", user['name']);
    prefs.setString("user_phone_owner", user['phone']);
    prefs.setString("user_city_owner", user['city']);
    prefs.setString("user_picture_owner", user['picture']);
    return prefs.commit();
  }



}