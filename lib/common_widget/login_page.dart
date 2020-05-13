
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter_messaging_app/common_widget/buttons/flat_button.dart';
import 'package:flutter_messaging_app/common_widget/buttons/gradient_button.dart';
import 'package:flutter_messaging_app/common_widget/buttons/menu_bar_button.dart';
import 'package:flutter_messaging_app/common_widget/buttons/social_login_button.dart';
import 'package:flutter_messaging_app/common_widget/cards/sign_up_card.dart';
import 'package:flutter_messaging_app/common_widget/decoration_elements/light_effect_line.dart';
import 'package:flutter_messaging_app/style/font.dart';
import 'package:flutter_messaging_app/style/theme_gradient.dart' as Theme;
import 'package:flutter_messaging_app/utils/bubble_indication_painter.dart';

class LoginPage extends StatefulWidget {
  
  
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {



  

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final FocusNode myFocusNodeEmailLogin = FocusNode();
  final FocusNode myFocusNodePasswordLogin = FocusNode();
  final FocusNode myFocusNodePassword = FocusNode();
  final FocusNode myFocusNodeEmail = FocusNode();
  final FocusNode myFocusNodeName = FocusNode();

  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();

 

  TextEditingController signupEmailController = TextEditingController();
  TextEditingController signupNameController = TextEditingController();
  TextEditingController signupPasswordController = TextEditingController();
  TextEditingController signupConfirmPasswordController =
      TextEditingController();

  PageController _pageController;

  Color left = Colors.black;
  Color right = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
        },
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height >= 775.0
                ? MediaQuery.of(context).size.height
                : 775.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Theme.Colors.loginGradientStart,
                    Theme.Colors.loginGradientEnd
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 1.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  //Resim
                  padding: EdgeInsets.only(top: 75.0),
                  child: Image(
                    width: 190.0,
                    height: 190.0,
                    fit: BoxFit.fill,
                    image: AssetImage('assets/img/logo.png'),
                  ),
                ),
                Padding(
                  //Menu Bar
                  padding: EdgeInsets.only(top: 20.0),
                  child: _buildMenuBar(context),
                ),
                Expanded(
                  //Giriş veya Kayıt Ol Ekranları
                  flex: 2,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) {
                      if (i == 0) {
                        setState(() {
                          right = Colors.white;
                          left = Colors.black;
                        });
                      } else if (i == 1) {
                        setState(() {
                          right = Colors.black;
                          left = Colors.white;
                        });
                      }
                    },
                    children: <Widget>[
                      ConstrainedBox(
                        constraints: const BoxConstraints.expand(),
                        child: _buildSignIn(context),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints.expand(),
                        child: _buildSignUp(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    myFocusNodePassword.dispose();
    myFocusNodeEmail.dispose();
    myFocusNodeName.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _pageController = PageController();
  }

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: MyFonts.fontNameMedium),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }

  Widget _buildMenuBar(BuildContext context) {
    //Menu Barı UI Widget'ı
    return Container(
      width: 300.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: MenuBarButton(
            leftOnPressed: _onSignInButtonPress,
            rightOnPressed: _onSignUpButtonPress,
            leftText: 'Hesabım Var',
            rightText: 'Yeni Oluştur',
            leftColor: left,
            rightColor: right),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    //Giriş Yap UI Widget
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              SignUpCard(
                itemNumber: 2,
              ),
              GradientButton(
                buttonText: 'Giriş Yap',
                onPressed: () => showInSnackBar("Giriş Yap a basıldı"),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: MyFlatButtons(
                onPressed: () {}, textFlatButtons: 'Parolamı Unuttum'),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: LineWithLightEffect(
              text: "ya da",
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10.0, right: 40.0),
                child: SocialLoginButton(
                  buttonIcon:
                      Icon(FontAwesomeIcons.facebookF, color: Colors.blue[600]),
                  onTap: () => showInSnackBar("Facebook butonuna basıldı"),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0, right: 40.0),
                child: SocialLoginButton(
                  buttonIcon: Icon(
                    FontAwesomeIcons.google,
                    color: Colors.red[600],
                  ),
                  onTap: () => showInSnackBar("Google butonuna basıldı"),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: SocialLoginButton(
                  buttonIcon: Image(
                    width: 25.0,
                    height: 25.0,
                    // fit: BoxFit.contain,
                    image: AssetImage('assets/img/logo.png'),
                  ),
                  onTap: null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignUp(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              SignUpCard(
                itemNumber: 3,
              ),
              Positioned(
                bottom: -25,
                child: GradientButton(
                  buttonText: 'Kayıt Ol',
                  onPressed: () => showInSnackBar("Kayıt ol butonuna basıldı"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() {
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }
}
