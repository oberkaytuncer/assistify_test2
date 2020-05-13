import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String buttonText;
  final Color buttonColor;
  final Color textColor;
  final double textSize;
  final double radius;
  final double height;
  final double width;
  final Widget buttonIcon;
  final VoidCallback onPressed;
  final double edgeInset;

  const SocialLoginButton(
      {Key key,
      @required this.buttonText,
      this.buttonColor : Colors.cyan,
      this.textColor : Colors.white,
      this.radius : 16,
      this.textSize :16,
      this.height :40,
      this.width,
      this.buttonIcon,
      this.edgeInset,
      this.onPressed})
      : assert(buttonText != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom:12),
      child: SizedBox(
        height: height ,
            child: RaisedButton(
          //   padding: EdgeInsets.all(edgeInset),
          onPressed: onPressed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(radius),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: <Widget>[
              Container(
                height: height,
                child: buttonIcon),
              Text(
                buttonText,
                style: TextStyle(color: textColor, fontSize: textSize),
              ),
              Opacity(opacity: 0, child: buttonIcon)
            ],
          ),
          color: buttonColor,
        ),
      ),
    );
  }
}
