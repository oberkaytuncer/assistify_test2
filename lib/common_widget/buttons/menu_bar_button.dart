import 'package:flutter/material.dart';

import 'flat_button.dart';

class MenuBarButton extends StatefulWidget {
  final Color splashColor;
  final Color highlightColor;
  final String leftText;
  final String rightText;
  final Color leftColor;
  final Color rightColor;
  final VoidCallback leftOnPressed;
  final VoidCallback rightOnPressed;

  final PageController pageController;

  const MenuBarButton(
      {Key key,
      this.splashColor: Colors.transparent,
      this.highlightColor: Colors.transparent,
      @required this.leftText,
      this.leftOnPressed,
      this.rightOnPressed,
      @required this.rightText,
      @required this.leftColor,
      @required this.rightColor,
      this.pageController})
      : super(key: key);

  @override
  _MenuBarButtonState createState() => _MenuBarButtonState();
}

class _MenuBarButtonState extends State<MenuBarButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: MyFlatButtons(
            textDecoration: null,
            highlightColor: widget.highlightColor,
            textFlatButtons: widget.leftText,
            textColor: widget.leftColor,
            splashColor: widget.splashColor,
            onPressed: widget.leftOnPressed,
          ),
        ),
        Expanded(
          child: MyFlatButtons(
            textDecoration: null,
            highlightColor: widget.highlightColor,
            textFlatButtons: widget.rightText,
            textColor: widget.rightColor,
            splashColor: widget.splashColor,
            onPressed: widget.rightOnPressed,
          ),
        )
      ],
    );
  }

 
}
