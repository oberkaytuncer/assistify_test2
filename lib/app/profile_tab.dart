import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/common_widget/platform_sensetive_widget/platform_sensetive_alert_dialog.dart';
import 'package:flutter_messaging_app/view_model/user_model.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserModel _userModel = Provider.of<UserModel>(context);

    print('Profil sayfasındaki user değeleri: ' + _userModel.user.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => _confirmSignOut(context),
            child: Text('Çıkış'),
          ),
        ],
      ),
      body: Center(
        child: Text('Profile Sayfası'),
      ),
    );
  }

  Future<bool> _signOut(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    bool result = await _userModel.signOut();

    return result;
  }

  Future _confirmSignOut(BuildContext context) async {
    final result = await AlertDialogPlatformSensetive(
      title: 'Emin misin?',
      content: 'Çıkış yapmak istediğinizden emin misiniz?',
      mainActionButtonText: 'Evet',
      cancelActionButtonText: 'Vazgeç',
    ).show(context);

    if (result == true) {
      _signOut(context);
    }
  }
}
