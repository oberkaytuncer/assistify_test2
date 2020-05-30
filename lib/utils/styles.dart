import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
Widget MyNoAppbar(){
  return PreferredSize(child: AppBar(elevation: 0,  backgroundColor: HexColor("577DB1"),), preferredSize: Size.fromHeight(0));
}
Widget MyNoAppbarCustomColor(String color){
  return PreferredSize(child: AppBar(elevation: 0,  backgroundColor: HexColor(color),), preferredSize: Size.fromHeight(0));
}
TextStyle FlatTransparentButtonStyle(){
  return TextStyle(color: Colors.blueAccent,fontSize: 16);
}
TextStyle FlatButtonColoredTextStyle(){
  return TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold);
}

TextStyle headingStyle(){
  return TextStyle(color: Colors.white,fontSize: 38,fontWeight: FontWeight.bold);
}