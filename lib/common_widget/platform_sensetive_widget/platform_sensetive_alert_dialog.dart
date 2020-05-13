import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_messaging_app/common_widget/platform_sensetive_widget/platform_sensitive_widget.dart';

class PlatformSensetiveAlertDialog extends PlatformSensetiveWidget {
  final String title;
  final String content;
  final String mainActionButtonText;
  final String cancelActionButtonText;

  PlatformSensetiveAlertDialog(
      {@required this.title,
      @required this.content,
      @required this.mainActionButtonText,
      this.cancelActionButtonText});

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _setUpDialogButton(context),
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _setUpDialogButton(context),
    );
  }

  List<Widget> _setUpDialogButton(BuildContext context) {
    final allButtons = <Widget>[];

    if (Platform.isIOS) {
      if (mainActionButtonText != null) {
        allButtons.add(
          CupertinoDialogAction(
            child: Text(cancelActionButtonText),
            onPressed: () {},
          ),
        );
      }
      allButtons.add(
        CupertinoDialogAction(
          child: Text(mainActionButtonText),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
    } else {
      if (mainActionButtonText != null) {
        allButtons.add(
          FlatButton(
            child: Text(cancelActionButtonText),
            onPressed: () {},
          ),
        );
      }
      allButtons.add(
        FlatButton(
          child: Text(mainActionButtonText),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
    }
    return allButtons;
  }
}
