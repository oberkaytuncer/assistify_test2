import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/app/signin_page/studio_signin_detail_page.dart';
import 'package:flutter_messaging_app/app/splash_screen.dart';
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
        return HomePage(user: _userModel.user);
        
      }
    } else if (_userModel.state == ViewState.Busy) {
      return SplashScreen();
    }
  }
}
