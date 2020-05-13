import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/style/font.dart';

class MyFlatButtons extends StatelessWidget {
  final VoidCallback onPressed;
  final String textFlatButtons;
  final TextDecoration textDecoration;
  final Color textColor;
  final double fontSize;
  final String fontFamily;
  final Color splashColor;
  final Color highlightColor;

  const MyFlatButtons(
      {Key key,
      this.onPressed,
      @required this.textFlatButtons,
      this.textDecoration : TextDecoration.underline,
      this.textColor : Colors.black,
      this.fontSize :18.0 ,
      this.fontFamily :MyFonts.fontNameMedium,
      this.splashColor :null,
      this.highlightColor :null,
      })
      :
       super(key: key);

  @override
  Widget build(BuildContext context) {
   return FlatButton(
     splashColor: splashColor,
     highlightColor : highlightColor,
      onPressed: onPressed,
      child: Text(
        textFlatButtons,
        style: TextStyle(
            decoration: textDecoration,
            color: textColor,
            fontSize: fontSize,
            fontFamily: fontFamily),
      ),
    );
  }
}
