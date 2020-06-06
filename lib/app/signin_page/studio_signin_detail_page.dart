import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/app/appointment_list_fragment_tab.dart';
import 'package:flutter_messaging_app/model/studio.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:flutter_messaging_app/view_model/user_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class StudioDetailSignInPage extends StatefulWidget {
  @override
  _StudioDetailSignInPageState createState() => _StudioDetailSignInPageState();
}

class _StudioDetailSignInPageState extends State<StudioDetailSignInPage> {
  String selectedSize;
  String _email;
  File _image;
  String studio_name = '';
  String location = '';
  String address = '';
  String about = '';
  String _phone = '';
  String _userID = '';
  double lat = 0.0;
  double long = 0.0;
  double lat1 = 0.0;
  double long1 = 0.0;

  DatabaseReference studios_db =
      FirebaseDatabase.instance.reference().child('studios');
  DatabaseReference users_tokens_db =
      FirebaseDatabase.instance.reference().child('users_tokens');
  DatabaseReference ground_owner_db =
      FirebaseDatabase.instance.reference().child('studio_owners');

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  ProgressDialog progressDialog;
  List<String> _studio_size = <String>['5x5', '6x6', '7x7'];
  var locationField = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    selectedSize = _studio_size.first;
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      print('Image Path $_image');
    });
  }

  Future registerUser(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);

    User _user = await _userModel.user;

    Studio studio;
    if (studio_name.length > 0) {
      if (address.length > 0) {
        if (lat1 == 0.0 && long1 == 0.0) {
          if (_image != null) {
            progressDialog =
                ProgressDialog(context, type: ProgressDialogType.Normal);
            progressDialog.style(message: "Image yükleniyor lütfen bekleyin.");
            progressDialog.show();
            String fileName = basename(_image.path);
            StorageReference firebaseStorageRef =
                FirebaseStorage.instance.ref().child(fileName);
            StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
            StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
            if (taskSnapshot.ref.getDownloadURL() != null) {
              String studio_pic_path = await taskSnapshot.ref.getDownloadURL();
              setState(() {
                Fluttertoast.showToast(
                    msg: "Studyo Resmi yüklendi",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1);
              });



              
              progressDialog.update(message: "Data Uploading Please Wait.");
              studio = Studio(studio_name, selectedSize, lat1, long1, address,
                  about, studio_pic_path);

              

              var data = {
                "ground_name": studio_name,
                "ground_size": selectedSize,
                "lat": lat1,
                "long": long1,
                "role": "Guest",
                "address": address,
                "about": about,
                "ground_picture": studio_pic_path
              };
              studios_db.child(_user.userID).set(data).whenComplete(() {
                progressDialog.hide();
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('Ground Register Successfully')));

                updateFirebaseToken(context);
              }).catchError((e) {
                progressDialog.hide();
                Scaffold.of(context).showSnackBar(new SnackBar(
                  content: new Text("There is some Error."),
                  backgroundColor: Colors.red,
                ));
                print(e);
              });
            }
          } else {
            Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Text("Please Upload Ground Picture"),
              backgroundColor: Colors.red,
            ));
          }
        } else {
          Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text("Please Choose Location from Map."),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text("Please Enter Address"),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("Please Enter Ground Name"),
        backgroundColor: Colors.red,
      ));
    }
  }

  void updateFirebaseToken(BuildContext context) {
    String _token;
    _firebaseMessaging.getToken().then(
      (token) {
        _token = token;
        var data = {'token': token};
        FirebaseAuth.instance.currentUser().then(
          (user) {
            users_tokens_db.child(user.uid).set(data).whenComplete(() {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => AppointmentListFragment(),
                  ),
                  (route) => false);
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Complete your Ground Information",
              style: TextStyle(color: HexColor("39B54A"), fontSize: 22.0)),
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
                                                  child: (_image != null)
                                                      ? Image.file(_image,
                                                          width: 80,
                                                          height: 80,
                                                          fit: BoxFit.cover)
                                                      : Image.asset(
                                                          "assets/ground.png",
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
                                                          FlatButton(
                                                            onPressed: () =>
                                                                getImage(),
                                                            child:
                                                                FlatButton.icon(
                                                              color: HexColor(
                                                                  "39B54A"),
                                                              onPressed: null,
                                                              icon: ImageIcon(
                                                                new AssetImage(
                                                                    "assets/camera.png"),
                                                                color: HexColor(
                                                                    "39B54A"),
                                                              ),
                                                              label: Text(
                                                                "Upload Ground Image",
                                                                style: TextStyle(
                                                                    color: HexColor(
                                                                        "39B54A"),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        16.0),
                                                              ),
                                                            ),
                                                          ),
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
                                                  studio_name = value;
                                                },
                                                decoration: new InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            20.0),
                                                    border:
                                                        new OutlineInputBorder(
                                                      borderSide:
                                                          new BorderSide(
                                                              color: HexColor(
                                                                  "39B54A")),
                                                    ),
                                                    hintText: 'Ground Name',
                                                    labelText: 'Ground Name',
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
                                                  items: _studio_size
                                                      .map((value) =>
                                                          DropdownMenuItem(
                                                            child: Text(value),
                                                            value: value,
                                                          ))
                                                      .toList(),
                                                  onChanged: (String value) {
                                                    setState(() {
                                                      selectedSize = value;
                                                    });
                                                  },
                                                  isExpanded: true,
                                                  value: selectedSize,
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
                                                  address = value;
                                                },
                                                decoration: new InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            20.0),
                                                    border:
                                                        new OutlineInputBorder(
                                                      borderSide:
                                                          new BorderSide(
                                                              color: HexColor(
                                                                  "39B54A")),
                                                    ),
                                                    hintText: 'Address',
                                                    labelText: 'Address',
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
                                                  about = value;
                                                },
                                                decoration: new InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            20.0),
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
                                                enableInteractiveSelection:
                                                    false,
                                                enabled: false,
                                                controller: locationField,
                                                decoration: new InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            20.0),
                                                    border:
                                                        new OutlineInputBorder(
                                                      borderSide:
                                                          new BorderSide(
                                                              color: HexColor(
                                                                  "39B54A")),
                                                    ),
                                                    hintText:
                                                        'Location Coordinates',
                                                    labelText:
                                                        'Location Coordinates',
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
                                  /*Expanded(
                                      flex: 5,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            new SizedBox(
                                                width: double.infinity,
                                                height: 40.0,
                                                child: new FlatButton(
                                                  onPressed: () {
                                                    _ChooseLocation(context);
                                                  },
                                                  child: FlatButton.icon(
                                                      color: HexColor("39B54A"),
                                                      onPressed: null,
                                                      icon: Icon(
                                                        Icons.location_on,
                                                        color:
                                                            HexColor("35B54A"),
                                                        size: 35.0,
                                                      ),
                                                      label: Text(
                                                        "Select Ground Location",
                                                        style: TextStyle(
                                                            color: HexColor(
                                                                "39B54A"),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16.0),
                                                      )),
                                                ))
                                          ],
                                        ),
                                      ))*/
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
                                                child: Text("SUBMIT",
                                                    style: TextStyle(
                                                        color:
                                                            HexColor("FFFFFF"),
                                                        fontSize: 14.0)),
                                                onPressed: () =>
                                                    registerUser(context),
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
}
