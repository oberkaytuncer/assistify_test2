import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/services/user_defaults.dart';
import 'package:flutter_messaging_app/view_model/user_model.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'signin_page/signin_page.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _userModel = Provider.of<UserModel>(context);

    if (_userModel.state == ViewState.Idle) {
      if (_userModel.user == null) {
        return SignInPage();
      } else {
        if (_userModel.user.phoneNumber == '0555 555 55 55') {
          print('telefon numarasını değiştirmen gerek');
          return HomePage(user: _userModel.user);
        } else {
          print('telefon numaranı değiştirmene gerek yok.');
          return HomePage(user: _userModel.user);
        }
      }
    } else if (_userModel.state == ViewState.Busy) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
