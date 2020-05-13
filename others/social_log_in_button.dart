import 'package:flutter/material.dart';

import 'button_style.dart';




class FacebookLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SocialLoginButton(
      buttonIcon: Image.asset('images/facebook.png'),
      buttonText: 'Facebook ile Giriş Yap',
      onPressed: () {},
      buttonColor: Color(0xFF334D92),
    );
  }
}

class EmailAndPasswordLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SocialLoginButton(
      buttonIcon: Icon(
        Icons.email,
        size: 40,
      ),
      buttonText: 'Email ile Giriş Yap',
      onPressed: () {},
      // buttonColor: Color(0xFF334D92),
    );
  }
}

class GmailLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SocialLoginButton(
      buttonIcon: Image.asset('images/google.png'),
      buttonText: 'Gmail ile Giriş Yap',
      textColor: Colors.black87,
      onPressed: () {},
      buttonColor: Colors.white,
    );
  }
}
