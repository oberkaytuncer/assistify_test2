import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/style/font.dart';
import 'package:flutter_messaging_app/style/theme_gradient.dart' as Theme;

class GradientButton extends StatelessWidget {
  final String buttonText;
  final Color buttonColorGradientStart;
  final Color buttonColorGradientEnd;
  final Color textColor;
  final double textSize;
  final double radius;
  final double height;
  final double width;
  final Widget buttonIcon;
  final VoidCallback onPressed;
  final String fontFamily;
  final double offsetDX;
  final double offsetDY;
  final double blurRadius;

  const GradientButton(
      {Key key,
      @required this.buttonText,
      this.buttonColorGradientStart: Theme.Colors.loginGradientStart,
      this.buttonColorGradientEnd: Theme.Colors.loginGradientEnd,
      this.textColor: Colors.white,
      this.radius: 5,
      this.textSize: 20,
      this.height: 40,
      this.width,
      this.buttonIcon,
      this.fontFamily: MyFonts.fontNameMedium,
      this.onPressed,
      this.offsetDX : 0.0,
      this.offsetDY : 0.0,
      this.blurRadius : 2.0,

      })
      : assert(buttonText != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 50.0),
      decoration: new BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: buttonColorGradientStart,
            offset: Offset(offsetDX, offsetDY),
            blurRadius: blurRadius,
          ),
          BoxShadow(
            color: buttonColorGradientEnd,
            offset: Offset(offsetDX, offsetDY),
            blurRadius: blurRadius,
          ),
        ],
        gradient: new LinearGradient(
            colors: [Color(0xFF0047cc), buttonColorGradientStart],
            begin: const FractionalOffset(0.2, 0.2),
            end: const FractionalOffset(1.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      child: MaterialButton(
        highlightColor: Colors.transparent,
        splashColor: buttonColorGradientEnd,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
          child: Text(
            buttonText,
            style: TextStyle(
              color: textColor,
              fontSize: textSize,
              fontFamily: fontFamily,
            ),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
