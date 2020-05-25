import 'package:flutter_messaging_app/model/studio.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User_Defaults {

  
  Future<User> getUserDataFromUserDefault() async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString("phonenumber_owner");
    final userID = prefs.getString("user_id_owner");
    final email = prefs.getString("user_email_owner");

    User createdUser = User.forDefaultData(
        email: email, userID: userID, phoneNumber: phoneNumber);
        return createdUser;
  }

  Future<String> getUserPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString("phonenumber_owner");
    return phoneNumber;
  }

  Future<String> getUserUserID() async {
    final prefs = await SharedPreferences.getInstance();
    final user_id = prefs.getString("user_id_owner");
    return user_id;
  }

  Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final user_email = prefs.getString("user_email_owner");
    return user_email;
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final user_name = prefs.getString("user_name_owner");
    return user_name;
  }

  Future<String> getStudioName() async {
    final prefs = await SharedPreferences.getInstance();
    final studio_name = prefs.getString("studio_name_owner");
    return studio_name;
  }

  Future<double> getStudioLatitude() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble("latitude");
    return latitude;
  }

  Future<double> getStudioLongitude() async {
    final prefs = await SharedPreferences.getInstance();
    final longitude = prefs.getDouble("longitude");
    return longitude;
  }
//buradan sonrakiler sharedPreference ye yazma işlemi..

  Future<bool> setPhoneandUserID(String phoneNumber, String userID) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("phonenumber_owner", phoneNumber);
    prefs.setString("user_id_owner", userID);
    return prefs.commit();
  }

  Future<bool> saveUserDataToUserDefault(User user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("user_id_owner", user.userID);
    prefs.setString("user_email_owner", user.email);
    prefs.setString("user_name_owner", user.userName);
    prefs.setString("user_phone_owner", user.phoneNumber);
    prefs.setString("user_city_owner", user.city);
    prefs.setString("user_picture_owner", user.profilePhotoURL);

    print(
        'user defaults a yazılan bilgiler: ${user.email} ${user.userName}, ${user.phoneNumber} , ${user.city} , ${user.profilePhotoURL}  ');
    return prefs.commit();
  }

  Future<bool> saveUserDataAlternative(Map<dynamic, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("user_name_owner", user['userName']);
    prefs.setString("user_phone_owner", user['phoneNumber']);
    prefs.setString("user_city_owner", user['city']);
    prefs.setString("user_picture_owner", user['profilePhotoURL']);
    return prefs.commit();
  }

  Future<bool> saveStudioLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble("latitude", latitude);
    prefs.setDouble("longitude", longitude);
    return prefs.commit();
  }

  Future<bool> saveStudioData(Studio studio) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("studio_name_owner", studio.name);
    prefs.setString("studio_image_owner", studio.picture);
    prefs.setString("studio_location_owner", studio.address);
    return prefs.commit();
  }

  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("user_name_owner", "");
    prefs.setString("user_phone_owner", "");
    prefs.setString("studio_name_owner", "");
    prefs.setString("studio_image_owner", "");
    prefs.setString("user_city_owner", "");
    prefs.setString("user_picture_owner", "");
    prefs.setString("phonenumber_owner", "");
    prefs.setString("user_id_owner", "");
    return prefs.commit();
  }
}
