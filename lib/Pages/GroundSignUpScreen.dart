import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

//Eğer SignUpScreen'den gelen ekrandaki bilgiler doğruysa 
//yani firebase db ve User_Defaults'a başarılı bir şekilde kayıt gerçekleşmişse
//bu ekrana yönlendirilip buradan devam ettirilir.
//Bu ekranın başlangıcında SignUpScreen in ilk kısımları tamamlanmış oluğ eğer geriye kalan kısımlar da
//doldurulursa HomeScreen'e yönlendirme yapılacaktır.

//*********Bu ekran çağırıldıpında mevcut durum **********
/* ********User sınıfındaki alanların tamamı dolu******************
                   name != null
                   phone != null
                   email != null
                   city != null
                   role != null
                   age != null
                   gender != null
                   team != null
                   position != null
                   postcount != null
                   followerscount != null
                   followingcount != null
                   picture != null


//*****Fakat Ground alanının doldurulması gerekiyor */
                   name == null
                   size == null
                   lat == null
                   long == null
                   address == null
                   about == null
                   picture  == null
 * 
 */



//Bu sayfada tamamlandığında hem User bilgileri doldurulmul oalcak hem de Ground bilgileri doldurulumuş olacak.


class GroundSignUpScreen extends StatefulWidget {
  @override
  _GroundSignUpScreenState createState() => _GroundSignUpScreenState();
}

class _GroundSignUpScreenState extends State<GroundSignUpScreen> {

  String selectedSize;
  File   _image;
  String ground_name="";
  String location="";
  String address="";
  String about="";
  String _phone="";
  String _user_id = "";
  double lat=0.0;
  double long=0.0;
  double lat1=0.0;
  double long1=0.0;

  User_Defualts user_defaults = new User_Defualts();
  DatabaseReference grounds_db = FirebaseDatabase.instance.reference().child("grounds");
  DatabaseReference users_tokens_db = FirebaseDatabase.instance.reference().child("users_tokens");
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();


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

  //Get Data from Cache Session
  Future<void> getData() async
  {
    _phone = await user_defaults.getUserPhoneNumber();
    _user_id = await user_defaults.getUserUserID();
    lat = await user_defaults.getGroundLatitude();
    long = await user_defaults.getGroundLongitude();
    setState(() {
      lat1 = lat;
      long1= long;
      locationField.text = ""+lat1.toString()+" - "+long1.toString();
    });
  }

  //Get Image from Gallery
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      print('Image Path $_image');
    });
  }

  //Implementation of Register Team
  Future registerUser(BuildContext context) async{
    Ground ground;
    if(ground_name.length>0)
    {
      if(address.length>0)
      {
        if(lat1!=0.0 && long1!=0.0)
        {
          if (_image!=null)
          {
            progressDialog = ProgressDialog(context,type: ProgressDialogType.Normal);
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
                Fluttertoast.showToast(
                    msg: "Ground Picture uploaded",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1
                );
              });
              progressDialog.update(message: "Data Uploading Please Wait.");
              ground = new Ground(ground_name,selectedSize, lat1,long1,address,about,ground_pic_path);

              var data ={
                "ground_name": ground_name,
                "ground_size": selectedSize,
                "lat": lat1,
                "long": long1,
                "role": "Guest",
                "address": address,
                "about": about,
                "ground_picture": ground_pic_path
              };
               grounds_db.child(_user_id).set(data).whenComplete((){
                user_defaults.saveGroundData(ground);
                progressDialog.hide();
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('Ground Register Successfully')));

                updateFirebaseToken(context);

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
            Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Text("Please Upload Ground Picture"),
              backgroundColor: Colors.red,
            ));
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

  //Update Firebase Token
  void updateFirebaseToken(BuildContext context) {
    String _token;
    _firebaseMessaging.getToken().then((token) {
      _token = token;
      var data =
      {
        "token": _token
      };
      FirebaseAuth.instance.currentUser().then((user) {
        users_tokens_db.child(user.uid).set(data).whenComplete(() {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                      HomeScreen()), (Route<dynamic> route) => false);
        }).catchError((e) {
          print(e);
        });
      });
    });
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
                                                  child:
                                                  (_image!=null)?Image.file(_image,width: 80,height: 80,fit:BoxFit.cover)
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

  //This is Method get Get Location from Location Screen and Get Back
  void _ChooseLocation (BuildContext context) async {

   final reuslt =  await Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return MapsDemo();
    }));

    if(reuslt!=null) {
      List<String> result = reuslt.split(",");
      lat1 = double.parse(result[0]);
      long1 = double.parse(result[1]);
      user_defaults.saveGroundLocation(lat1, long1);
      locationField.text = "" + lat1.toString() + " - " + long1.toString();
    }

  }
}
