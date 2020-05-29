import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_messaging_app/Models/User.dart';
class User_Defualts {

  Future<String> getUserPhoneNumber() async
  {
    final prefs = await SharedPreferences.getInstance();
    final PhoneNumber = prefs.getString("phonenumber");
    return PhoneNumber;
  }

  Future<String> getUserUserID() async
  {
    final prefs = await SharedPreferences.getInstance();
    final user_id = prefs.getString("user_id");
    return user_id;
  }

  Future<String> getUserName() async
  {
    final prefs = await SharedPreferences.getInstance();
    final user_name = prefs.getString("user_name");
    return user_name;
  }


  Future<bool> setPhoneandUserID(String phone,String user_id) async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("phonenumber", phone);
    prefs.setString("user_id", user_id);
    return prefs.commit();
  }

  Future<bool> setTeam_ID(String team_id) async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("team_id", team_id);
    return prefs.commit();
  }
  Future<String> getTeamID() async
  {
    final prefs = await SharedPreferences.getInstance();
    final user_name = prefs.getString("team_id");
    return user_name;
  }


  Future<bool> saveUserData(User user) async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("user_name", user.name);
    prefs.setString("user_phone", user.phone);
    prefs.setString("user_city", user.city);
    prefs.setString("user_picture", user.picture);
    return prefs.commit();
  }

  Future<bool> logout() async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("user_name","");
    prefs.setString("user_phone","");
    prefs.setString("user_city","");
    prefs.setString("user_picture", "");
    prefs.setString("phonenumber", "");
    prefs.setString("user_id", "");
    return prefs.commit();
  }



  Future<bool> saveUserData1(Map<dynamic,dynamic> user) async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("user_name", user['name']);
    prefs.setString("user_phone", user['phone']);
    prefs.setString("user_city", user['city']);
    prefs.setString("user_picture", user['picture']);
    return prefs.commit();
  }



}