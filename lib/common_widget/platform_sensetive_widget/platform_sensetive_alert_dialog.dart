import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_messaging_app/common_widget/platform_sensetive_widget/platform_sensitive_widget.dart';

class AlertDialogPlatformSensetive extends PlatformSensetiveWidget {
  final String title;
  final String content;
  final String mainActionButtonText;
  final String cancelActionButtonText;

  AlertDialogPlatformSensetive(
      {@required this.title,
      @required this.content,
      @required this.mainActionButtonText,
      this.cancelActionButtonText});

  Future<bool> show(BuildContext context) async {
    return Platform.isIOS
        ? await showCupertinoDialog<bool>(
            context: context, builder: (context) => this)
        : await showDialog<bool>(
            context: context,
            builder: (context) => this,
            barrierDismissible: false);
  }

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _setUpDialogButton(context),
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _setUpDialogButton(context),
    );
  }

  List<Widget> _setUpDialogButton(BuildContext context) {
    final allButtons = <Widget>[];

    if (Platform.isIOS) {
      if (cancelActionButtonText != null) {
        allButtons.add(
          CupertinoDialogAction(
            child: Text(cancelActionButtonText),
            onPressed: () {
              Navigator.of(context).pop(
                  false); //bu kısımlar aşırı önemli çünkü geriye false bir değer burada döndürüyor. İsterse burda başka bir değer yazrak başka işlemler de yapabiliriz.
            },
          ),
        );
      }
      allButtons.add(
        CupertinoDialogAction(
          child: Text(mainActionButtonText),
          onPressed: () {
            Navigator.of(context).pop(
                true); //bu kısımlar aşırı önemli çünkü geriye false bir değer burada döndürüyor. İsterse burda başka bir değer yazrak başka işlemler de yapabiliriz.
          },
        ),
      );
    } else {
      if (cancelActionButtonText != null) {
        allButtons.add(
          FlatButton(
            child: Text(cancelActionButtonText),
            onPressed: () {
              Navigator.of(context).pop(
                  false); //bu kısımlar aşırı önemli çünkü geriye false bir değer burada döndürüyor. İsterse burda başka bir değer yazrak başka işlemler de yapabiliriz.
            },
          ),
        );
      }
      allButtons.add(
        FlatButton(
          child: Text(mainActionButtonText),
          onPressed: () {
            Navigator.of(context).pop(
                true); //bu kısımlar aşırı önemli çünkü geriye false bir değer burada döndürüyor. İsterse burda başka bir değer yazrak başka işlemler de yapabiliriz.
          },
        ),
      );
    }
    return allButtons;
  }
}
