import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/common_widget/buttons/social_login_button.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/view_model/user_model.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'email_and_pass_signin_signup.dart';

class SignInPage extends StatelessWidget {
  void _demoUserSignIn(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    User _user = await _userModel.signInAnonymously();
    if (_user != null) print('Sign in ile oturum açan ID: ' + _user.userID);
  }

  void _googleSignIn(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    User _user = await _userModel.signInWithGoogle();
   if (_user != null) print('Google ile oturum açan ID: ' + _user.userID);
  }

  void _facebookSignIn(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    User _user = await _userModel.signInWithFacebook();
   if (_user != null) print('facebook ile oturum açan ID: ' + _user.userID);
  }

  void _emailAndPassSignIn(BuildContext context) {
    Navigator.of(context).push(CupertinoPageRoute(
        fullscreenDialog: false,
        builder: (context) => EmailAndPassSignInPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey[400],
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height >= 775.0
            ? MediaQuery.of(context).size.height
            : 775.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                Colors.grey[50], //Theme.Colors.loginGradientStart,
                Colors.grey[500] //Theme.Colors.loginGradientEnd
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 1.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10.0, right: 40.0),
              child: SocialLoginButton(
                buttonIcon:
                    Icon(FontAwesomeIcons.facebookF, color: Colors.blue[600]),
                onTap: () => _facebookSignIn(context),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, right: 40.0),
              child: SocialLoginButton(
                buttonIcon: Icon(
                  FontAwesomeIcons.google,
                  color: Colors.red[600],
                ),
                onTap: () => _googleSignIn(context),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, right: 40),
              child: SocialLoginButton(
                buttonIcon: Image(
                  width: 25.0,
                  height: 25.0,
                  // fit: BoxFit.contain,
                  image: AssetImage('assets/img/logo.png'),
                ),
                onTap: () => _demoUserSignIn(context),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: SocialLoginButton(
                buttonIcon:
                    Icon(FontAwesomeIcons.signInAlt, color: Colors.grey[600]),
                onTap: () => _emailAndPassSignIn(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
