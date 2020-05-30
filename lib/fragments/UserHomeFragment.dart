import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as prefix0;
import 'package:flutter/material.dart';

import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_messaging_app/Models/Slot.dart';

import 'package:flutter_messaging_app/utils/HexColor.dart';

import 'package:http/http.dart';

import 'package:firebase_database/firebase_database.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;

import 'dart:io' show Platform;

import 'package:video_player/video_player.dart';

final String token = 'c2928278d71247c3bcb7c4ccc89cc2c6';

class match {
  String homeTeam;
  String awayTeam;
  String matchDay;
  String matchTime;
  match(this.homeTeam, this.awayTeam, this.matchDay, this.matchTime);
}

class UserHomeFragment extends StatefulWidget {
  @override
  _UserHomeFragmentState createState() => _UserHomeFragmentState();
}

class _UserHomeFragmentState extends State<UserHomeFragment> {
  DatabaseReference grouds =
      FirebaseDatabase.instance.reference().child("grounds");
  String logo1;
  String logo2;
  var _index = 1;
  AsyncSnapshot dataSnap;
  VideoPlayerController _controller;
  List<Slot> slots = null;
  List<match> TmpData;
  @override
  void initState()   {
    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.asset("assets/demo.webm")
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.play();
    _controller.setLooping(true);
    _controller.setVolume(0.0);

     grouds.once().then((DataSnapshot datasnapshot) {
      if (datasnapshot != null && datasnapshot.value != null) {
        var keys = datasnapshot.value.keys;
        var data = datasnapshot.value;
        print("DataSnapppppppsd: ${datasnapshot.value}");
        for (var key in keys) {
          slots = [];
          setState(()  {
             grouds.child(key).child("Slots").once().then((DataSnapshot slotss) {
              if (slotss.value != null) {
                for (var slotsData in slotss.value.keys) {
                  grouds
                      .child(key)
                      .child("Slots")
                      .child(slotsData)
                      .once()
                      .then((DataSnapshot finalData) {
                    if (finalData.value != null) {
                      for (var slotsDatakeys in finalData.value.keys) {
                        var finalDataValues = finalData.value;
                        if (finalDataValues[slotsDatakeys]['status'] ==
                            "Booked") {
                          setState(() {
                            Slot d = new Slot(
                                finalDataValues[slotsDatakeys]['slot_id'],
                                finalDataValues[slotsDatakeys]['time'],
                                finalDataValues[slotsDatakeys]['startTime'],
                                finalDataValues[slotsDatakeys]['endTime'],
                                finalDataValues[slotsDatakeys]['date'],
                                finalDataValues[slotsDatakeys]['status'],
                                finalDataValues[slotsDatakeys]['team1_logo'],
                                finalDataValues[slotsDatakeys]['team1_name'],
                                finalDataValues[slotsDatakeys]['team2_logo'],
                                finalDataValues[slotsDatakeys]['team2_name']);
                            slots.add(d);
                          });
                        }
                      }
                    }
                  });
                }
              }
            });
          });
        }
        setState(() {});
        print("Length of Listff ${slots.length}");
      } else {
        print("Length of Listff ${slots.length}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Opacity(
                opacity: 0.01,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/sherry.jpg'),
                          fit: BoxFit.cover)),
                )),
            new Column(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: new Container(
                    height: 190,
                    child: Stack(
                      children: <Widget>[
                        ClipPath(
                          clipper: DiagonalPathClipperOne(),
                          child: Container(
                            height: 170,
                            color: HexColor("39B54A"),
                          ),
                        ),
                        slots == null
                            ? new Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                child: new CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                ),
                              )
                            : CarouselSlider(
                                options: CarouselOptions(
                                  height: 180,
                                  initialPage: 0,
                                  autoPlayInterval: Duration(seconds: 10),
                                  autoPlayAnimationDuration:
                                      Duration(milliseconds: 1000),
                                  enableInfiniteScroll: true,
                                  enlargeCenterPage: true,
                                  pauseAutoPlayOnTouch:
                                      true, //    Duration(seconds: 7),
                                  reverse: false,
                                  autoPlay: true,
                                ),
                                items: [slots.length].map((i) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return sliderItem(context, "ground", i - 1);
                                    },
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: mathes(),
                )
              ],
            )
          ],
        ));
  }

  sliderItem(BuildContext context, String type, int i) {
    print("Type: $type, Index $i");
    if (type == "ground") {
      return new Container(
          alignment: Alignment.center,
          child: new Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(27.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.all(2.0),
                    child: CircleAvatar(
                        backgroundColor: HexColor("39B54A"),
                        radius: 40.0,
                        child: ClipOval(
                            child: (slots[i].team1_logo != "" ||
                                    slots[i].team1_logo != null)
                                ? Image.network(
                                    slots[i].team1_logo,
                                    width: 72,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  )
                                : new Container())),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                      padding: EdgeInsets.all(5.0),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Text(
                                slots[i].date,
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Text(
                                slots[i].time,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Column(
                                children: <Widget>[
                                  new Text(
                                    slots[i].team1_name,
                                    style: TextStyle(
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  new Text(
                                    " vs ",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  new Text(
                                    slots[i].team2_name,
                                    style: TextStyle(
                                      fontSize: 15.0,
                                    ),
                                  )
                                ],
                              )
                            ],
                          )
                        ],
                      )),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.all(2.0),
                    child: CircleAvatar(
                        backgroundColor: HexColor("39B54A"),
                        radius: 40.0,
                        child: ClipOval(
                            child: (slots[i].team2_logo != "" ||
                                    slots[i].team2_logo != null)
                                ? Image.network(
                                    slots[i].team2_logo,
                                    width: 72,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  )
                                : new Container())),
                  ),
                ),
              ],
            ),
          ));
    } else {
      return new Container(
          child: new Card(
              elevation: 7.0,
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(27.0)),
              child: new Container(
                margin: const EdgeInsets.all(10.0),
                child: VideoPlayer(_controller),
              )));
    }
  }

  mathes() {
    return Container(
        color: Colors.white,
        child: FutureBuilder(
          future: getMatches("PL"),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              if (dataSnap != null) {
                snapshot = dataSnap;
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              dataSnap = snapshot;
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(5),
                  itemBuilder: (context, i) {
                    return new Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(27.0)),
                        elevation: 5.0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5)),
                            child: Row(
                              children: <Widget>[
                                //first part of match details
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    //crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      FittedBox(
                                          child: Text(snapshot.data[i].homeTeam,
                                              style: teamStyle),
                                          fit: BoxFit.fitWidth),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            50, 0, 50, 0),
                                        child: Divider(
                                          color: Colors.red,
                                        ),
                                      ),
                                      FittedBox(
                                          child: Text(snapshot.data[i].awayTeam,
                                              style: teamStyle),
                                          fit: BoxFit.fitWidth)
                                    ],
                                  ),
                                ),

                                //second part of match details
                                Expanded(
                                    child: Column(
                                  children: <Widget>[
                                    FittedBox(
                                        child: timeFormatter(snapshot.data[i]),
                                        fit: BoxFit.fitWidth),
                                    FittedBox(
                                        child: dayFormatter(snapshot.data[i]),
                                        fit: BoxFit.fitWidth),
                                  ],
                                ))
                              ],
                            ),
                          ),
                        ));
                  });
            }
          },
        ));
  }

  Future<List<match>> getMatches(String code) async {
    Response r = await http.get(
        Uri.encodeFull(
            'https://api.football-data.org/v2/competitions/$code/matches?status=SCHEDULED'),
        headers: {"X-Auth-Token": token});
    print("Response: ${r.statusCode} ");

    if (r.statusCode != 200) {
      if (TmpData == null || TmpData.length < 1) {
        print("Retrying");
        getMatches(code);
      } else {
        print("Return Previous Data");
        return TmpData;
      }
    } else {
      Map<String, dynamic> x = jsonDecode(r.body);
      List y = x['matches'];

      List<match> extractedMatches = [];

      print("Dataaaa: ${x.keys}");
      for (var i in y) {
        extractedMatches.add(new match(
            i['homeTeam']['name'],
            i['awayTeam']['name'],
            i['utcDate'].toString().substring(5, 10),
            DateTime.parse(i['utcDate'])
                .toLocal()
                .toIso8601String()
                .substring(11, 16)));
      }
      TmpData = extractedMatches;
      return extractedMatches;
    }
  }

  TextStyle teamStyle =
      TextStyle(color: Colors.black, fontSize: 20, fontStyle: FontStyle.italic);

  timeFormatter(match m) {
    String convertedTime = m.matchTime;
    print(m.matchTime);
    int time = int.parse(m.matchTime.substring(0, 2));
    //print(m.matchTime);
    //print(time);
    if (time > 12) {
      time = time - 12;
      convertedTime = time.toString() + m.matchTime.substring(2) + ' PM';
    }
    print(convertedTime);
    return Text(convertedTime);
  }

  dayFormatter(match m) {
    String d = m.matchDay;
    List splitD = d.split('-');
    if (splitD[0].toString().startsWith('0'))
      splitD[0] = splitD[0].toString().substring(1);

    if (splitD[1].toString().startsWith('0'))
      splitD[1] = splitD[1].toString().substring(1);

    d = splitD[0] + '/' + splitD[1];
    return Text(d);
  }
}

//Page Data If Needed in Future
//
//PageView(
//controller: PageController(viewportFraction: 0.8),
//scrollDirection: Axis.horizontal,
//pageSnapping: true,
//children: <Widget>[
//new Container(
//child: new Card(
//elevation: 4.0,
//shape: RoundedRectangleBorder(
//borderRadius:
//new BorderRadius.circular(27.0)),
//child: Row(
//children: <Widget>[
//Expanded(
//flex: 1,
//child: Container(
//padding: EdgeInsets.all(5.0),
//child: CircleAvatar(
//backgroundColor:
//Colors.black12,
//radius: 40.0,
//child: ClipOval(
//child: (logo1 != null &&
//logo1 != "")
//? Image.network(
//logo1,
//width: 65,
//height: 65,
//fit: BoxFit.cover,
//)
//: new Container())),
//),
//),
//Expanded(
//flex: 3,
//child: Container(
//padding: EdgeInsets.all(5.0),
//child: Align(
//alignment: Alignment.center,
//child: new Column(
//children: <Widget>[
//new Row(
//mainAxisAlignment:
//MainAxisAlignment
//    .center,
//children: <Widget>[
//new Text(
//"12:00 - 01:30",
//style: TextStyle(
//fontSize:
//20.0,
//fontWeight:
//FontWeight
//    .bold),
//)
//],
//),
//new Row(
//mainAxisAlignment:
//MainAxisAlignment
//    .center,
//children: <Widget>[
//new Text(
//"                                        ",
//style: TextStyle(
//fontSize:
//20.0,
//backgroundColor:
//Colors
//    .black12),
//)
//],
//)
//],
//))),
//),
//Expanded(
//flex: 1,
//child: Container(
//padding: EdgeInsets.all(5.0),
//child: CircleAvatar(
//backgroundColor:
//Colors.black12,
//radius: 40.0,
//child: ClipOval(
//child: (logo2 != null &&
//logo2 != "")
//? Image.network(
//"" + logo1,
//width: 65,
//height: 65,
//fit: BoxFit
//    .fitHeight,
//)
//: new Container())),
//),
//),
//],
//),
//)),new Container(
//child: new Card(
//elevation: 4.0,
//shape: RoundedRectangleBorder(
//borderRadius:
//new BorderRadius.circular(27.0)),
//child: Row(
//children: <Widget>[
//Expanded(
//flex: 1,
//child: Container(
//padding: EdgeInsets.all(5.0),
//child: CircleAvatar(
//backgroundColor:
//Colors.black12,
//radius: 40.0,
//child: ClipOval(
//child: (logo1 != null &&
//logo1 != "")
//? Image.network(
//logo1,
//width: 65,
//height: 65,
//fit: BoxFit.cover,
//)
//: new Container())),
//),
//),
//Expanded(
//flex: 3,
//child: Container(
//padding: EdgeInsets.all(5.0),
//child: Align(
//alignment: Alignment.center,
//child: new Column(
//children: <Widget>[
//new Row(
//mainAxisAlignment:
//MainAxisAlignment
//    .center,
//children: <Widget>[
//new Text(
//"12:00 - 01:30",
//style: TextStyle(
//fontSize:
//20.0,
//fontWeight:
//FontWeight
//    .bold),
//)
//],
//),
//new Row(
//mainAxisAlignment:
//MainAxisAlignment
//    .center,
//children: <Widget>[
//new Text(
//"                                        ",
//style: TextStyle(
//fontSize:
//20.0,
//backgroundColor:
//Colors
//    .black12),
//)
//],
//)
//],
//))),
//),
//Expanded(
//flex: 1,
//child: Container(
//padding: EdgeInsets.all(5.0),
//child: CircleAvatar(
//backgroundColor:
//Colors.black12,
//radius: 40.0,
//child: ClipOval(
//child: (logo2 != null &&
//logo2 != "")
//? Image.network(
//"" + logo1,
//width: 65,
//height: 65,
//fit: BoxFit
//    .fitHeight,
//)
//: new Container())),
//),
//),
//],
//),
//))
//],
//),
