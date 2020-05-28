import 'package:flutter/material.dart';


class SocialLoginButton extends StatelessWidget {
  final text;
  final GestureTapCallback onTap;
  final EdgeInsetsGeometry edgeInsetsGeometry;
  final BoxShape boxShape;
  final Color boxColor;
  final Widget buttonIcon;
  final Color iconColor;

  const SocialLoginButton({
    Key key,
    this.text: '',
    @required this.onTap,
    this.edgeInsetsGeometry: const EdgeInsets.all(15.0),
    this.boxShape: BoxShape.circle,
    this.boxColor: Colors.white,
    @required this.buttonIcon,
    this.iconColor: const Color(0xFF0084ff),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: edgeInsetsGeometry,
            decoration: new BoxDecoration(
              shape: boxShape,
              color: boxColor,
            ),
            child: buttonIcon,
          ),
        ),
        Text(text),
      ],
    );
  }
}
