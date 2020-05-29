import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/Models/User.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:flutter_messaging_app/utils/strings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:country_pickers/country.dart';
import 'package:flutter/services.dart';
import 'package:flutter_messaging_app/fragments/UserProfileFragment.dart';
import 'package:flutter_messaging_app/Pages/HomeScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter_messaging_app/utils/User_Defaults.dart';
import 'package:flutter_messaging_app/Models/User.dart';

class RegisterTeamScreen extends StatefulWidget {
  @override
  _RegisterTeamScreenState createState() => _RegisterTeamScreenState();
}

class _RegisterTeamScreenState extends State<RegisterTeamScreen> {
  String selectedCity;
  File _logo;
  String team_name = "";
  String about = "";
  String webite = "";

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _logo = image;
      print('Image Path $_logo');
    });
  }

  User_Defualts user_defaults = new User_Defualts();
  String _phone = "";
  String _user_id = "";
  DatabaseReference ref = FirebaseDatabase.instance.reference().child("users");
  DatabaseReference ref1 =
      FirebaseDatabase.instance.reference().child("team_request");
  DatabaseReference ref2 = FirebaseDatabase.instance.reference().child("teams");

  ProgressDialog progressDialog;

  List<String> _cities = <String>['Select City', 'Islamabad'];
  List<String> _teams = <String>['Select Team', 'No Fan Team'];

  List<String> _genders = <String>['Male', 'Female'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    selectedCity = _cities.first;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Request for A Team.",
              style: TextStyle(color: Colors.black, fontSize: 22.0)),
          backgroundColor: HexColor("FFFFFF"),
        ),
        body: Builder(
            builder: (context) => Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    new SingleChildScrollView(
                      child: Container(
                          margin: const EdgeInsets.only(
                              top: 10.0, left: 15.0, right: 15.0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            CircleAvatar(
                                                backgroundColor:
                                                    HexColor("39B54A"),
                                                radius: 50.0,
                                                child: ClipOval(
                                                  child: (_logo != null)
                                                      ? Image.file(_logo,
                                                          width: 80,
                                                          height: 80,
                                                          fit: BoxFit.cover)
                                                      : Image.asset(
                                                          "assets/football_team.png",
                                                          width: 80.0,
                                                          height: 80.0,
                                                        ),
                                                )),
                                            new Container(
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Container(
                                                      child: Column(
                                                        children: <Widget>[
                                                          new FlatButton(
                                                              onPressed: () =>
                                                                  getImage(),
                                                              child: FlatButton
                                                                  .icon(
                                                                      color: HexColor(
                                                                          "39B54A"),
                                                                      onPressed:
                                                                          null,
                                                                      icon:
                                                                          ImageIcon(
                                                                        new AssetImage(
                                                                            "assets/camera.png"),
                                                                        color: HexColor(
                                                                            "39B54A"),
                                                                      ),
                                                                      label:
                                                                          Text(
                                                                        "Upload Image",
                                                                        style: TextStyle(
                                                                            color:
                                                                                HexColor("39B54A"),
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 16.0),
                                                                      )))
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(top: 20.0)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            new SizedBox(
                                              width: double.infinity,
                                              height: 50.0,
                                              child: new TextField(
                                                onChanged: (value) {
                                                  team_name = value;
                                                },
                                                decoration: new InputDecoration(
                                                    border:
                                                        new OutlineInputBorder(
                                                      borderSide:
                                                          new BorderSide(
                                                              color: HexColor(
                                                                  "39B54A")),
                                                    ),
                                                    hintText: 'Team Name',
                                                    labelText: 'Team Name',
                                                    suffixStyle:
                                                        const TextStyle(
                                                            color:
                                                                Colors.green)),
                                              ),
                                            )
                                          ],
                                        ),
                                      ))
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(top: 17.0)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            new SizedBox(
                                              width: double.infinity,
                                              height: 50.0,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  border: Border.all(
                                                      color: Colors.black38,
                                                      style: BorderStyle.solid,
                                                      width: 0.80),
                                                ),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                        child: DropdownButton(
                                                  items: _cities
                                                      .map((value) =>
                                                          DropdownMenuItem(
                                                            child: Text(value),
                                                            value: value,
                                                          ))
                                                      .toList(),
                                                  onChanged: (String value) {
                                                    setState(() {
                                                      selectedCity = value;
                                                    });
                                                  },
                                                  isExpanded: true,
                                                  value: selectedCity,
                                                )),
                                              ),
                                            )
                                          ],
                                        ),
                                      ))
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(top: 17.0)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            new SizedBox(
                                              width: double.infinity,
                                              height: 50.0,
                                              child: new TextField(
                                                onChanged: (value) {
                                                  about = value;
                                                },
                                                decoration: new InputDecoration(
                                                    border:
                                                        new OutlineInputBorder(
                                                      borderSide:
                                                          new BorderSide(
                                                              color: HexColor(
                                                                  "39B54A")),
                                                    ),
                                                    hintText: 'About',
                                                    labelText: 'About',
                                                    suffixStyle:
                                                        const TextStyle(
                                                            color:
                                                                Colors.green)),
                                              ),
                                            )
                                          ],
                                        ),
                                      ))
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(top: 17.0)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            new SizedBox(
                                              width: double.infinity,
                                              height: 50.0,
                                              child: new TextField(
                                                onChanged: (value) {
                                                  webite = value;
                                                },
                                                keyboardType:
                                                    TextInputType.phone,
                                                decoration: new InputDecoration(
                                                    border:
                                                        new OutlineInputBorder(
                                                      borderSide:
                                                          new BorderSide(
                                                              color: HexColor(
                                                                  "39B54A")),
                                                    ),
                                                    hintText:
                                                        'Website (If Any)',
                                                    labelText:
                                                        'Website (If Any)',
                                                    suffixStyle:
                                                        const TextStyle(
                                                            color:
                                                                Colors.green)),
                                              ),
                                            )
                                          ],
                                        ),
                                      ))
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(top: 25.0)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                      flex: 5,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            new SizedBox(
                                              width: double.infinity,
                                              height: 40.0,
                                              child: new RaisedButton(
                                                child: Text("Request",
                                                    style: TextStyle(
                                                        color:
                                                            HexColor("FFFFFF"),
                                                        fontSize: 14.0)),
                                                onPressed: () =>
                                                    registerTeam(context),
                                                color: HexColor("39B54A"),
                                              ),
                                            )
                                          ],
                                        ),
                                      ))
                                ],
                              ),
                            ],
                          )),
                    )
                  ],
                )));
  }

  Widget _buildDropdownItem(Country country) => Container(
        child: Row(
          children: <Widget>[
            CountryPickerUtils.getDefaultFlagImage(country),
            SizedBox(
              width: 8.0,
            ),
            Text("+${country.phoneCode}(${country.isoCode})"),
          ],
        ),
      );

  Future registerTeam(BuildContext context) async {
    if (team_name != "" && team_name != null) {
      if (selectedCity != "Select City") {
        if(_logo!=null && _logo!="") {
          var uuid = new Uuid();
          String team_id = uuid.v1();
          progressDialog =
              ProgressDialog(context, type: ProgressDialogType.Normal);
          progressDialog.show();

          String fileName = basename(_logo.path);
          StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(fileName);
          StorageUploadTask uploadTask = firebaseStorageRef.putFile(_logo);
          StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
          if (taskSnapshot.ref.getDownloadURL() != null) {
            String logo_pic_path = await taskSnapshot.ref.getDownloadURL();
            setState(() {
              FirebaseAuth.instance.currentUser().then((user) {
                var data = {"team_id": team_id, "user_id": user.uid};
                ref1.child(user.uid).push().set(data).whenComplete(() {
                  var data1 = {
                    "team_name": team_name,
                    "user_id": user.uid,
                    "city": selectedCity,
                    "about": about,
                    "website": webite,
                    "team_logo": logo_pic_path
                  };

                  var data3 = {"role": "Captain", "player_id": user.uid};

                  ref2.child(user.uid).update(data1).whenComplete(() {
                    ref2.child(user.uid).child("Players").child(user.uid).update(data3).whenComplete(() {
                      var data2 = {"role": "Captain", "team": team_name};
                      ref.child(user.uid).update(data2).whenComplete(() {
                        Fluttertoast.showToast(
                            msg: "Team Registered.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1);
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()),
                                (Route<dynamic> route) => false);
                      });
                    }).catchError((e) {
                      print(e);
                    });
                  });
                }).catchError((e) {
                  print(e);
                });
              });
            });
          }
        }else
          {
            Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Text("Please Choose Logo"),
              backgroundColor: Colors.red,
            ));
          }
      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text("Please Select City"),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("Please Enter Valid Team Name"),
        backgroundColor: Colors.red,
      ));
    }
  }
}
