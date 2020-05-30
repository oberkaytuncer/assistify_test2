import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/Models/User.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';

import 'package:flutter_messaging_app/Models/User.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:flutter_messaging_app/utils/strings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:country_pickers/country.dart';
import 'package:flutter/services.dart';
import 'package:flutter_messaging_app/Pages/HomeScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter_messaging_app/utils/User_Defaults.dart';
import 'package:flutter_messaging_app/Models/User.dart';

import 'HomeScreen.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String selectedCity;
  String selectedGender;
  File _image;
  String full_name="";
  String selected_Image;
  String age="";
  String email="";
  var emailController = TextEditingController();
  var fullnameController = TextEditingController();
  var ageController = TextEditingController();
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      print('Image Path $_image');
    });
  }
  User userdata=null;
  User_Defualts user_defaults = new User_Defualts();
  String _phone = "";
  String _user_id = "";
  DatabaseReference ref = FirebaseDatabase.instance.reference().child("users");


  void getData() async
  {
    _phone = await user_defaults.getUserPhoneNumber();
    _user_id = await user_defaults.getUserUserID();

      FirebaseAuth.instance.currentUser().then((user) {
        ref.child(user.uid)
            .once()
            .then((DataSnapshot datasnapshot) {

          if (datasnapshot != null && datasnapshot.value != null) {
            var keys = datasnapshot.value.keys;
            var data = datasnapshot.value;
            //print("DataSnap: ${datasnapshot.value}");
                userdata = new User(
                    data['name'],
                    data['phone'],
                    data['email'],
                    data['city'],
                    data['role'],
                    data['age'],
                    data['gender'],
                    data['team'],
                    data['position'],
                    data['postcount'],
                    data['followerscount'],
                    data['followingcount'],
                    data['picture']);
              selectedCity = userdata.city;
              selected_Image = userdata.picture;
              selectedGender = userdata.gender;
              age = userdata.age;
              email = userdata.email;
              full_name  = userdata.name;
              emailController.text = userdata.email;
              ageController.text = userdata.age;
              fullnameController.text = userdata.name;
              setState(() {


              });


          } else {
          }

        });
      });



  }
  Future registerUser(BuildContext context) async{
    User user;
    progressDialog = ProgressDialog(context,type: ProgressDialogType.Normal);
    if(age.length>0)
    {
      if(full_name.length>0)
      {
        if(email.length>0)
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
              String profile_pic_path = await taskSnapshot.ref.getDownloadURL();
              setState(() {
                print("Profile Picture uploaded");
                Fluttertoast.showToast(
                    msg: "Profile Picture uploaded",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1
                );
              });
              progressDialog.update(message: "Data Uploading Please Wait.");
              progressDialog.show;
              user = new User(full_name,email, _phone, selectedCity, "GroundOwner", age, selectedGender, "", "None", 0, 0, 0,profile_pic_path);

              var data ={
                "name": full_name,
                "email": email,
                "phone": _phone,
                "city": selectedCity,
                "role": userdata.role,
                "interest": "No Interest",
                "age": age,
                "gender": selectedGender,
                "position": "None",
                "postcount": 0,
                "followerscount": 0,
                "followingcount": 0,
                "picture": profile_pic_path
              };
               ref.child(_user_id).update(data).whenComplete((){
                user_defaults.saveUserData(user);
                progressDialog.hide();

                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                    HomeScreen(text: "Home",)), (Route<dynamic> route) => false);

                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('User Profile Update  Successfully')));

              }).catchError((e)
              {
                print("hello error a gya");
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('There is Some Error, Try Again with Valid Info.')));
                print(e);
              });


            }
          }
          else {

            user = new User(full_name,email, _phone, selectedCity, "GroundOwner", age, selectedGender, "", "None", 0, 0, 0,selected_Image);

            var data ={
              "name": full_name,
              "email": email,
              "phone": _phone,
              "city": selectedCity,
              "role": userdata.role,
              "interest": "No Interest",
              "age": age,
              "gender": selectedGender,
              "position": "None",
              "postcount": 0,
              "followerscount": 0,
              "followingcount": 0,
              "picture": selected_Image
            };
            ref.child(_user_id).update(data).whenComplete((){
              user_defaults.saveUserData(user);
              progressDialog.hide();

              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                  HomeScreen(text:"Home")), (Route<dynamic> route) => false);

              Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text('User Profile Update  Successfully')));

            }).catchError((e)
            {
              print("hello error a gya");
              Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text('There is Some Error, Try Again with Valid Info.')));
              print(e);
            });

          }

        }
        else
        {
          Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text("Please Enter Email"),
            backgroundColor: Colors.red,
          ));
        }
      }
      else
      {
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text("Please Enter Full_name"),
          backgroundColor: Colors.red,
        ));
      }
    }
    else
    {
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("Please Enter Age"),
        backgroundColor: Colors.red,
      ));
    }




  }


  ProgressDialog progressDialog;

  List<String> _cities = <String>['Select City', 'Islamabad'];
  List<String> _genders = <String>['Male', 'Female'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  void _signUpBtnPress(BuildContext context) {
    // Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("Pressing Login Button"),));
    //Move to Phone Verification Page

    Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return HomeScreen();
    }));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
        appBar: AppBar(
          title: Text("Edit Profile",
              style: TextStyle(color: Colors.black, fontSize: 22.0)),
          backgroundColor: HexColor("FFFFFF"),
        ),
        body: Builder(
            builder: (context) => Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    new SingleChildScrollView(
                      child:
                      userdata==null?
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
                                                  :(selected_Image!=null)?Image.network(selected_Image,width: 80,height: 80,fit:BoxFit.cover)
                                                      :Image.asset(
                                                    "assets/person.jpg",
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
                                                                "Upload Image",
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
                                                controller: fullnameController,
                                                onChanged: (value) {
                                                  full_name = value;
                                                },
                                                decoration: new InputDecoration(
                                                    contentPadding: const EdgeInsets.only(top: 30.0,right:20,bottom:20.0,left:10.0),
                                                    border:
                                                        new OutlineInputBorder(
                                                      borderSide:
                                                          new BorderSide(
                                                              color: HexColor(
                                                                  "39B54A")),
                                                    ),
                                                    hintText: 'Full Name',
                                                    labelText: 'Full Name',
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
                                                controller: emailController,
                                                onChanged: (value) {
                                                  email = value;
                                                },
                                                  keyboardType:
                                                  TextInputType.emailAddress,
                                                decoration: new InputDecoration(
                                                    contentPadding: const EdgeInsets.only(top: 30.0,right:20,bottom:20.0,left:10.0),
                                                    border:
                                                        new OutlineInputBorder(
                                                      borderSide:
                                                          new BorderSide(
                                                              color: HexColor(
                                                                  "39B54A")),
                                                    ),
                                                    hintText: 'Email',
                                                    labelText: 'Email',
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
                                                controller: ageController,
                                                onChanged: (value) {
                                                  age = value;
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
                                                    hintText: 'Age',
                                                    labelText: 'Age',
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
                                                  items: _genders
                                                      .map((value) =>
                                                          DropdownMenuItem(
                                                            child: Text(value),
                                                            value: value,
                                                          ))
                                                      .toList(),
                                                  onChanged: (String value) {
                                                    setState(() {
                                                      selectedGender = value;
                                                    });
                                                  },
                                                  isExpanded: true,
                                                  value: selectedGender,
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
                                                child: Text("Update Profile",
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
}
