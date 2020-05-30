import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_messaging_app/Models/Player.dart';
import 'package:flutter_messaging_app/Models/Team.dart';
import 'package:flutter_messaging_app/Models/User.dart';
import 'package:flutter_messaging_app/Pages/PlayerProfileScreen.dart';
import 'package:flutter_messaging_app/Pages/TeamProfileHome.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:flutter_messaging_app/utils/firebase_utils.dart';
import 'package:flutter_messaging_app/utils/strings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:country_pickers/country.dart';
import 'package:flutter/services.dart';
import 'package:flutter_messaging_app/fragments/UserProfileFragment.dart';
import 'package:flutter_messaging_app/Pages/HomeScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter_messaging_app/utils/User_Defaults.dart';
import 'package:flutter_messaging_app/Models/User.dart';

class TeamFicturesFragment extends StatefulWidget {

  @override
  _TeamFicturesFragmentState createState() => _TeamFicturesFragmentState();
}

class _TeamFicturesFragmentState extends State<TeamFicturesFragment> {

  String team_id  = "";

  User_Defualts user_defualts = new User_Defualts();


  @override
  void initState() {
   getData();
    super.initState();
  }
  void getData() async {
    team_id = await user_defualts.getTeamID();
    setState(() {
      print("User _id: $team_id");
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = new TextEditingController();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final border = OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(90.0)),
        borderSide: BorderSide(
          color: Colors.transparent,
        ));
    return Scaffold(
        body: Builder(

            builder: (context) => Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                      top: 10.0, left: 10.0, right: 10.0),
                  child:new Text(
                    "Coming Soon Team Fixtures",
                    style: TextStyle(
                        color: HexColor("39B54A"),
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )
                )
              ],
            )));
  }


}
