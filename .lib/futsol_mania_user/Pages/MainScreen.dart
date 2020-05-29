import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:flutter_messaging_app/utils/strings.dart';
import 'package:flutter_messaging_app/Pages/EnterPhoneScreen.dart';
import 'package:flutter/services.dart';

import 'auth.dart';

var MainActivityRoute = <String,WidgetBuilder>
{
  '/EnterPhoneScreen': (BuildContext contaxt) => EnterPhoneScreen()
};


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  void _loginBtnPress(BuildContext context)
    {
      // Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("Pressing Login Button"),));
      //Move to Phone Verification Page

      Navigator.push(context, new MaterialPageRoute(builder: (context){
        return EnterPhoneScreen();
      }));

  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      body: Builder(builder: (context) => Stack(
        fit: StackFit.expand,

        children: <Widget>[
          Opacity(opacity: 0.12,child: Container(
            decoration: BoxDecoration
              (image: DecorationImage(image: AssetImage('assets/sherry.jpg'),fit: BoxFit.cover)
            ),
          )),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.only(top: 60.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Image.asset('assets/logo.png',width: 360,height: 200)
                      ],
                    ),
                  )),
              Expanded(
                  flex: 1,
                  child:
                  Container(
                    margin: const EdgeInsets.only(bottom: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(DONT_WAIT,style: TextStyle(color: HexColor("39B54A"),fontSize: 18.0,fontWeight: FontWeight.bold)),
                        Padding(padding: EdgeInsets.only(top:4.0)),
                        Text(LOG_IN_NOW,style: TextStyle(color: HexColor("39B54A"),fontSize: 14.0)),
                        Padding(padding: EdgeInsets.only(top:12.0)),
                        new SizedBox(
                            width: double.infinity,
                            height: 50.0,
                            child:  Container(
                                margin: const EdgeInsets.only(left: 20.0,right: 20.0),
                                child: new RaisedButton(
                                    child: Text(LOG_IN,style: TextStyle(color: HexColor("FFFFFF"),fontSize: 14.0)),
                                    onPressed: () =>_loginBtnPress(context),
                                    color: HexColor("39B54A"),
                                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))


                                )
                            ))


                      ],
                    ),
                  )
              )
            ],
          )

        ],
      ))
    );
  }
}
