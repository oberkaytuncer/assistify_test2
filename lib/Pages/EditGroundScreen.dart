import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/Map/Maps.dart';
import 'package:flutter_messaging_app/Models/Ground.dart';
import 'package:flutter_messaging_app/Models/User.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:flutter_messaging_app/utils/strings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:country_pickers/country.dart';
import 'package:flutter/services.dart';
import 'package:flutter_messaging_app/fragments/TimeSlotFragment.dart';
import 'package:flutter_messaging_app/Pages/HomeScreen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter_messaging_app/utils/User_Defaults.dart';
import 'package:flutter_messaging_app/Models/User.dart';

class EditGroundScreen extends StatefulWidget {
  @override
  _EditGroundScreenState createState() => _EditGroundScreenState();
}

class _EditGroundScreenState extends State<EditGroundScreen> {
  String selectedSize;
  File _image;
  String selectedImage;
  String ground_name="";
  String location="";
  String address="";
  String about="";

  User_Defualts user_defaults = new User_Defualts();

  String _phone = "";
  String _user_id = "";
  double lat=0.0;
  double long=0.0;
  double lat1=0.0;
  double long1=0.0;

  DatabaseReference grounds_db = FirebaseDatabase.instance.reference().child("grounds");

  Ground ground;
  var aboutController = TextEditingController();
  var groundNameController = TextEditingController();
  var addressController = TextEditingController();

  ProgressDialog progressDialog;
  List<String> _ground_size = <String>['5x5', '6x6','7x7'];
  var locationField = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user_defaults.saveGroundLocation(0.0, 0.0);
    getData();
    selectedSize = _ground_size.first;
  }

  //Get Data of Ground
  void getData() async
  {
    _phone = await user_defaults.getUserPhoneNumber();
    _user_id = await user_defaults.getUserUserID();
    lat = await user_defaults.getGroundLatitude();
    long = await user_defaults.getGroundLongitude();
    FirebaseAuth.instance.currentUser().then((user) {
        grounds_db.child(user.uid).once().then((DataSnapshot datasnapshot) {
          if (datasnapshot != null && datasnapshot.value != null) {
            var data = datasnapshot.value;
            ground = new Ground(
                data['ground_name'],
                data['ground_size'],
                data['lat'],
                data['long'],
                data['address'],
                data['about'],
                data['ground_picture']);

            selectedSize = ground.size;
            selectedImage = ground.picture;
            ground_name = ground.name;
            about = ground.about;
            address = ground.address;
            lat1 = ground.lat;
            long1 = ground.long;

            groundNameController.text =  ground.name;
            aboutController.text = ground.about;
            addressController.text = ground.address;
            locationField.text = "$lat1 - $long1";
            setState(() {


            });


          } else {
          }

        });
      });
  }

  //Implementation of Getting Image from Gallery
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      print('Image Path $_image');
    });
  }

  //Implementation of Register User
  Future registerUser(BuildContext context) async{
    Ground groundd;
    progressDialog = ProgressDialog(context,type: ProgressDialogType.Normal);
    if(ground_name.length>0)
    {
      if(address.length>0)
      {
        if(lat1!=0.0 && long1!=0.0)
        {
          if (_image!=null) {
            progressDialog.style(message: "Image Uploading Please Wait.");
            progressDialog.show();
            String fileName = basename(_image.path);
            StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
            StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
            StorageTaskSnapshot taskSnapshot=await uploadTask.onComplete;
            if(taskSnapshot.ref.getDownloadURL() != null)
            {
              String ground_pic_path = await taskSnapshot.ref.getDownloadURL();
              setState(() {
                print("Ground Picture uploaded");
                Fluttertoast.showToast(
                    msg: "Ground Picture uploaded",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1
                );
              });
              progressDialog.update(message: "Data Uploading Please Wait.");
              groundd = new Ground(ground_name,selectedSize, lat1,long1,address,about,ground_pic_path);

              var data ={
                "ground_name": ground_name,
                "ground_size": selectedSize,
                "lat": lat1,
                "long": lat1,
                "role": "Guest",
                "address": address,
                "about": about,
                "ground_picture": ground_pic_path
              };
               grounds_db.child(_user_id).update(data).whenComplete((){
                user_defaults.saveGroundData(groundd);
                progressDialog.hide();
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('Ground Update Successfully')));

                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                    HomeScreen()), (Route<dynamic> route) => false);


               }).catchError((e)
              {
                progressDialog.hide();
                Scaffold.of(context).showSnackBar(new SnackBar(
                  content: new Text("There is some Error."),
                  backgroundColor: Colors.red,
                ));
                print(e);
              });


            }
          }
          else {

            progressDialog.update(message: "Data Uploading Please Wait.");
            progressDialog.show();
            groundd = new Ground(ground_name,selectedSize, lat1,long1,address,about,selectedImage);

            var data ={
              "ground_name": ground_name,
              "ground_size": selectedSize,
              "lat": lat1,
              "long": lat1,
              "role": "Guest",
              "address": address,
              "about": about,
              "ground_picture": selectedImage
            };
            grounds_db.child(_user_id).update(data).whenComplete((){
              user_defaults.saveGroundData(groundd);
              progressDialog.hide();
              Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text('Ground Update Successfully')));

              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                  HomeScreen()), (Route<dynamic> route) => false);


            }).catchError((e)
            {
              progressDialog.hide();
              Scaffold.of(context).showSnackBar(new SnackBar(
                content: new Text("There is some Error."),
                backgroundColor: Colors.red,
              ));
              print(e);
            });
          }

        }
        else
        {
          Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text("Please Choose Location from Map."),
            backgroundColor: Colors.red,
          ));
        }
      }
      else
      {
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text("Please Enter Address"),
          backgroundColor: Colors.red,
        ));
      }
    }
    else
    {
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("Please Enter Ground Name"),
        backgroundColor: Colors.red,
      ));
    }




  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
        appBar: AppBar(automaticallyImplyLeading: false,
          title: Text("Complete your Ground Information",
              style: TextStyle(color: HexColor("39B54A"), fontSize: 22.0)),
          backgroundColor: HexColor("FFFFFF"),
        ),
        body: Builder(
            builder: (context) => Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    new SingleChildScrollView(
                      child:
                      ground==null?
                      new Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        child: new CircularProgressIndicator(),
                      )
                :Container(
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
                                                  child:
                                                  (_image!=null)?Image.file(_image,width: 80,height: 80,fit:BoxFit.cover)
                                                      :(selectedImage!=null)?Image.network(selectedImage,width: 80,height: 80,fit:BoxFit.cover)
                                                      :Image.asset(
                                                    "assets/ground.png",
                                                    width: 80.0,
                                                    height: 80.0,
                                                  ),
                                                )
                                            ),
                                            new Container(
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Container(
                                                      child: Column(
                                                        children: <Widget>[
                                                          new FlatButton(onPressed: ()=>getImage(), child: FlatButton.icon(


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
                                                controller: groundNameController,
                                                onChanged: (value) {
                                                  ground_name = value;
                                                },
                                                decoration: new InputDecoration(
                                                    contentPadding: const EdgeInsets.all(20.0),
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
                                                      items: _ground_size
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
                                                controller: addressController,
                                                onChanged: (value) {
                                                  address = value;
                                                },
                                                decoration: new InputDecoration(
                                                    contentPadding: const EdgeInsets.all(20.0),
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
                                                controller: aboutController,
                                                onChanged: (value) {
                                                  about = value;
                                                },
                                                decoration: new InputDecoration(
                                                    contentPadding: const EdgeInsets.all(20.0),
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
                                                enableInteractiveSelection: false,
                                                enabled: false,
                                                controller: locationField,
                                                decoration: new InputDecoration(
                                                    contentPadding: const EdgeInsets.all(20.0),
                                                    border:
                                                    new OutlineInputBorder(
                                                      borderSide:
                                                      new BorderSide(
                                                          color: HexColor(
                                                              "39B54A")),
                                                    ),
                                                    hintText: 'Location Coordinates',
                                                    labelText: 'Location Coordinates',
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
                                              child: new FlatButton(
                                                onPressed:()
                                                  {_ChooseLocation(context);},
                                                child: FlatButton.icon(
                                                  color: HexColor(
                                                      "39B54A"),
                                                  onPressed: null,
                                                  icon: Icon(
                                                    Icons.location_on,
                                                    color: HexColor("35B54A"),
                                                    size: 35.0,
                                                  ),
                                                  label: Text(
                                                    "Select Ground Location",
                                                    style: TextStyle(
                                                        color: HexColor(
                                                            "39B54A"),
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        fontSize:
                                                        16.0),
                                                  )),
                                            ))
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


  _ChooseLocation (BuildContext context) async {

   final reuslt =  await Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return MapsDemo();
    }));

   print(reuslt);
    if(reuslt!=null) {
      List<String> result = reuslt.split(",");
      lat1 = double.parse(result[0]);
      long1 = double.parse(result[1]);
      user_defaults.saveGroundLocation(lat1, long1);
      locationField.text = "" + lat1.toString() + " - " + long1.toString();
    }

  }
}
