import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/Models/Team.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';

class TeamListFragment extends StatefulWidget {
  @override
  _TeamListFragmentState createState() => _TeamListFragmentState();
}

class _TeamListFragmentState extends State<TeamListFragment> {
  ProgressDialog progressDialog;
  String smsCode;
  String verficationID;
  FirebaseDatabase database;
  DatabaseReference teams_db = FirebaseDatabase.instance.reference().child("teams");
  List<Team> teams = [];
  int players_count = 0;

  @override
  void initState() {
    // TODO: implement initState
    teams_db.once().then((DataSnapshot datasnapshot) {
      var keys = datasnapshot.value.keys;
      var data = datasnapshot.value;
      for (var key in keys) {
        players_count = 0;
        var players = data[key]['Players'].keys;
        for (var keyss in players) {
          players_count = players_count + 1;
        }
        Team d = new Team(
            data[key]['team_name'],
            data[key]['team_logo'],
            data[key]['about'],
            data[key]['city'],
            data[key]['website'],
            data[key]['user_id'],players_count);
        teams.add(d);
      }
      setState(() {
        print("Teams :  ${teams.length}");
      });
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = new TextEditingController();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
        body: Builder(
            builder: (context) => Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0),
                      child:
                      teams.length == 0 ? new Text(
                          "Nom Teams Available",
                          style: TextStyle(color: HexColor("39B54A"),fontSize: 24.0,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,)
                          :new ListView.builder(itemCount: teams.length,
                            itemBuilder: (_,index){
                            return listitem(
                                teams[index].team_name,
                                teams[index].logo,
                                teams[index].city,
                                teams[index].about,teams[index].players);
                      },),
                    ),
                  ],
                )));
  }


  //Team List Item
  listitem(String name, String logo, String city, String about, int players) {
    return new Card(
        elevation: 15.0,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20.0)),
        child: new Container(
          margin: const EdgeInsets.all(5.0),
          child: new Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      flex: 2,
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            new Container(
                              margin: new EdgeInsets.symmetric(vertical: 10.0),
                              alignment: FractionalOffset.centerLeft,
                              child: CircleAvatar(
                                  backgroundColor: HexColor("39B54A"),
                                  radius: 50.0,
                                  child: ClipOval(
                                    child: (logo != null)
                                        ? Image.network(
                                      "" + logo,
                                      width: 92,
                                      height: 92,
                                      fit: BoxFit.fill,
                                    )
                                        : Image.asset(
                                      "assets/logo.png",
                                      width: 92.0,
                                      height: 92.0,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      )),
                  Expanded(
                    flex: 5,
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          new Container(
                            alignment: FractionalOffset.topLeft,
                            child: new Text(
                              name,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 23.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          new Row(
                            children: <Widget>[
                              Container(
                                  alignment: FractionalOffset.topLeft,
                                  child: FlatButton.icon(
                                      color: Colors.transparent,
                                      onPressed: null,
                                      icon: Icon(
                                        Icons.location_on,
                                        size: 19,
                                      ),
                                      label: Text(
                                        city,
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 17.0,
                                        ),
                                      ))),
                              Container(
                                  alignment: FractionalOffset.centerRight,
                                  child: FlatButton.icon(
                                      color: Colors.transparent,
                                      onPressed: null,
                                      icon: Icon(Icons.person_add, size: 19),
                                      label: Text(
                                        players.toString(),
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 17.0,
                                        ),
                                      ))),
                            ],
                          ),
                          new Container(
                            alignment: FractionalOffset.topLeft,
                            child: new Text(
                              about,
                              style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }

}
