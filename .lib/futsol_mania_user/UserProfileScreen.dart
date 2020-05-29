import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/Database/Firebase.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:flutter_messaging_app/utils/styles.dart';
import 'package:country_pickers/country.dart';
import 'package:flutter/services.dart';
import 'package:flutter_messaging_app/Pages/SignUpScreen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_messaging_app/utils/User_Defaults.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_messaging_app/Models/User.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  String drawer_picture=null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "User Profile",
      debugShowCheckedModeBanner: false,
      home: UserProfilePage(),
    );
  }
}

class UserProfilePage extends StatelessWidget {
   String _fullName = "M. Suleman";
   String _location = "Islamabad";
   String _bio =
      "\"Hi, I am a Freelance developer working for hourly basis. If you wants to contact me to build your product leave a message.\"";
   String _followers = "173";
   String _posts = "24";
   String _scores = "450";

   String _gender = "Male";
   String _age = "24";
   String _role = "quest";

   String _position = "Not Available";
   String _team_name = "Not Joined";
  User_Defualts user_defualts= new User_Defualts();
  String drawer_picture;
  String uid;
  DatabaseReference ref = FirebaseDatabase.instance.reference().child("users");
  ProgressDialog progressDialog;
  Future<void> getUserData(BuildContext context) async
  {
    await FirebaseAuth.instance.currentUser().then((userr) {
      uid = userr.uid;
      print("USer id "+ uid);
      ref.child(uid).once().then((DataSnapshot datasnapshot) {
        Map<dynamic,dynamic> user =datasnapshot.value;
        if (datasnapshot != null) {

          _fullName = user['name'];
          _location = user['city'];
          drawer_picture = user['picture'];
          _followers = user['followerscount'].toString();
          _posts = user['postcount'].toString();
          _scores = user['followingcount'].toString();
          _role = user['role'];
          _age = user['age'].toString();
          _gender = user['gender'];
          _position = user['position'];
          _team_name = user['team'];
        }
      });


  });


  }

  Widget _buildCoverImage(Size screenSize) {
    return Container(
      height: screenSize.height / 2.6,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/cover.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      child: CircleAvatar(
          backgroundColor:
          HexColor("39B54A"),
          radius: 65.0,
          child: ClipOval(
            child:
            (drawer_picture!=null)?Image.network(""+drawer_picture,width: 120,height: 120,fit: BoxFit.fill,)
                :Image.asset(
              "assets/logo.png",
              width: 120.0,
              height: 120.0,
            ),
          )
      ),

      );

  }


  Widget _buildFullName() {
    TextStyle _nameTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.black,
      fontSize: 28.0,
      fontWeight: FontWeight.w700,
    );

    return Text(
      _fullName,
      style: _nameTextStyle,
    );
  }

  Widget _buildStatus(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: FlatButton.icon(color: Colors.transparent,onPressed: null, icon: Icon(Icons.location_on), label: Text(
        _location,
        style: TextStyle(
          fontFamily: 'Spectral',
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.w300,
        ),
      ))

    );
  }

  Widget _buildStatItem(String label, String count) {
    TextStyle _statLabelTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.black,
      fontSize: 16.0,
      fontWeight: FontWeight.w200,
    );

    TextStyle _statCountTextStyle = TextStyle(
      color: Colors.black,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count,
          style: _statCountTextStyle,
        ),
        Text(
          label,
          style: _statLabelTextStyle,
        ),
      ],
    );
  }

  Widget _buildStatContainer() {
    return Container(
      height: 60.0,
      margin: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFFEFF4F7),
          borderRadius: new BorderRadius.all(new Radius.circular(32.0))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildStatItem("Followers", _followers),
          _buildStatItem("Posts", _posts),
          _buildStatItem("Scores", _scores),
        ],
      ),
    );
  }

  Widget _buildStatContainer2() {
    return Container(
      height: 60.0,
      margin: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildStatItem("Position", _position),
          _buildStatItem("Team Name", _team_name),
        ],
      ),
    );
  }

  Widget _buildStatContainer1() {
    return Container(
      height: 60.0,
      margin: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildStatItem("Gender", _gender),
          _buildStatItem("Age", _age),
          _buildStatItem("Role", _role),
        ],
      ),
    );
  }

  Widget _buildBio(BuildContext context) {
    TextStyle bioTextStyle = TextStyle(
      fontFamily: 'Spectral',
      fontWeight: FontWeight.w400,//try changing weight to w500 if not thin
      fontStyle: FontStyle.italic,
      color: Color(0xFF799497),
      fontSize: 16.0,
    );

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.all(8.0),
      child: Text(
        _bio,
        textAlign: TextAlign.center,
        style: bioTextStyle,
      ),
    );
  }

  Widget _buildSeparator(Size screenSize) {
    return Container(
      width: screenSize.width / 1.6,
      height: 2.0,
      color: Colors.black54,
      margin: EdgeInsets.only(top: 4.0),
    );
  }

  Widget _buildGetInTouch(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(top: 8.0),
      child: Text(
        "Get in Touch with ${_fullName.split(" ")[0]},",
        style: TextStyle(fontFamily: 'Roboto', fontSize: 16.0),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () => print("followed"),
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: Color(0xFF404A5C),
                ),
                child: Center(
                  child: Text(
                    "FOLLOW",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: InkWell(
              onTap: () => print("Message"),
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "MESSAGE",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
        body: Builder(builder: (context) => Stack(
          fit: StackFit.expand,

          children: <Widget>[
            Opacity(opacity: 0.01,child: Container(
              decoration: BoxDecoration
                (image: DecorationImage(image: AssetImage('assets/sherry.jpg'),fit: BoxFit.cover)
              ),
            )),
            new Container(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Image.asset('assets/curve.png',fit: BoxFit.fitWidth,),

                ],
              )
            ),
            new Container(
            margin: const EdgeInsets.only(
            top: 30.0, left: 15.0),
      child: Column(
        children: <Widget>[
          new Text("Player Profile",style: headingStyle())
        ],
      )
        ),
            new Container(
              decoration: new BoxDecoration(
                color: Colors.transparent,
              ),
                margin: const EdgeInsets.only(
                    top: 100.0, left: 15.0, right: 15.0),
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Card(
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      child:
                      new Container(
                        child: new Column(
                        children: <Widget>[
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                flex: 3,
                                child: new Container(
                                  child: new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      _buildFullName(),
                                      _buildStatus(context),
                                    ],
                                  ),
                                ),

                              ),
                              Expanded(
                                flex: 2,
                                child: new Container(
                                  margin: const EdgeInsets.all(5.0),
                                  child: new Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      _buildProfileImage(),
                                    ],
                                  ),
                                ),

                              )
                            ],
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                flex: 5,
                                child: new Container(
                                  child: new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      _buildStatContainer1(),
                                    ],
                                  ),
                                ),

                              )
                            ],
                          ),

                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                flex: 5,
                                child: new Container(
                                  child: new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      _buildStatContainer2(),
                                    ],
                                  ),
                                ),

                              )
                            ],
                          ),

                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                flex: 5,
                                child: new Container(
                                  child: new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      _buildStatContainer(),
                                    ],
                                  ),
                                ),

                              )
                            ],
                          ),


                        ],
                      ),)
                    )
                  ],
                )
            )





          ],
        ))
    );
  }
}

/*children: <Widget>[
          _buildCoverImage(screenSize),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: screenSize.height / 6.4),
                  _buildProfileImage(),
                  _buildFullName(),
                  _buildStatus(context),
                  _buildStatContainer(),
                  _buildBio(context),
                  _buildSeparator(screenSize),
                  SizedBox(height: 10.0),
                  _buildGetInTouch(context),
                  SizedBox(height: 8.0),
                  _buildButtons(),
                ],
              ),
            ),
          ),
        ],*/