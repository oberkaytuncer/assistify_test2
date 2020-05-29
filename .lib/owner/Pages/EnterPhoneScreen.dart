import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_messaging_app/Pages/HomeScreen.dart';
import 'package:flutter_messaging_app/main.dart';
import 'package:flutter_messaging_app/utils/HexColor.dart';
import 'package:flutter_messaging_app/utils/logger.dart';
import 'package:flutter_messaging_app/utils/masked_text.dart';
import 'package:flutter_messaging_app/utils/reactive_refresh_indicator.dart';
import 'package:flutter_messaging_app/utils/strings.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:country_pickers/country.dart';
import 'package:flutter/services.dart';
import 'package:flutter_messaging_app/Pages/SignUpScreen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_messaging_app/utils/User_Defaults.dart';
import 'package:firebase_database/firebase_database.dart';

enum AuthStatus { PHONE_AUTH, SMS_AUTH, PROFILE_AUTH }

class EnterPhoneScreen extends StatefulWidget {

  @override
  _EnterPhoneScreenState createState() => _EnterPhoneScreenState();
}

class _EnterPhoneScreenState extends State<EnterPhoneScreen> {

  ProgressDialog progressDialog;
  String phone_no = "0";
  String country_code = "+92";
  String smsCode;
  String verficationID;
  FirebaseDatabase database;
  BuildContext context;

  User_Defualts user_defualts = new User_Defualts();
  DatabaseReference ground_owners_db = FirebaseDatabase.instance.reference().child("ground_owners");

  static const String TAG = "AUTH";
  AuthStatus status = AuthStatus.PHONE_AUTH;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<MaskedTextFieldState> _maskedPhoneKey =
  GlobalKey<MaskedTextFieldState>();

  // Controllers
  TextEditingController smsCodeController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  // Variables
  String _phoneNumber;
  String _errorMessage;
  String _verificationId;
  Timer _codeTimer;

  bool _isRefreshing = false;
  bool _codeTimedOut = false;
  bool _codeVerified = false;
  Duration _timeOut = const Duration(minutes: 1);

  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _firebaseUser;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  // Styling
  final decorationStyle = TextStyle(color: Colors.grey[50], fontSize: 16.0);
  final hintStyle = TextStyle(color: Colors.white24);

  @override
  void initState() {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings,onSelectNotification: onSelectNotification);
  }

  // Implementation of Phone Verification Failed
  verificationFailed(AuthException authException) {
    _showErrorSnackbar("We couldn't verify your code for now, please try again!");
    progressDialog.hide();
    Fluttertoast.showToast(
        msg: "${authException.message}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1
    );
    Logger.log(TAG, message: 'onVerificationFailed, code: ${authException.code}, message: ${authException.message}');
  }

  //Implementation of Phone Code AutoRetrieval Timeout
  codeAutoRetrievalTimeout(String verificationId) {
    Logger.log(TAG, message: "onCodeTimeout");
    _updateRefreshing(false);
    setState(() {
      this._verificationId = verificationId;
      this._codeTimedOut = true;
    });
  }

  //Implementation of Phone Code Sent
  codeSent(String verificationId, [int forceResendingToken]) async {
    progressDialog.hide();
    Fluttertoast.showToast(
        msg: "Code sent on:- $phoneNumber",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1
    );
    Logger.log(TAG, message: "Verification code sent to number ${phoneNumberController.text}");
    _codeTimer = Timer(_timeOut, () {
      setState(() {
        _codeTimedOut = true;
      });
    });
    _updateRefreshing(false);
    setState(() {
      this._verificationId = verificationId;
      this.status = AuthStatus.SMS_AUTH;
      Logger.log(TAG, message: "Changed status to $status");
    });
  }

  @override
  void dispose() {
    _codeTimer?.cancel();
    super.dispose();
  }

  // async

  Future<Null> _updateRefreshing(bool isRefreshing) async {
    Logger.log(TAG,
        message: "Setting _isRefreshing ($_isRefreshing) to $isRefreshing");
    if (_isRefreshing) {
      setState(() {
        this._isRefreshing = false;
      });
    }
    setState(() {
      this._isRefreshing = isRefreshing;
    });
  }

  _showErrorSnackbar(String message) {
    _updateRefreshing(false);
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<Null> _submitPhoneNumber(BuildContext context) async {
    final error = _phoneInputValidator();
    if (error != null) {
      _updateRefreshing(false);
      setState(() {
        _errorMessage = error;
      });
      return null;
    } else {
      _updateRefreshing(false);
      setState(() {
        _errorMessage = null;
      });
      final result = await _verifyPhoneNumber(context);
      Logger.log(TAG, message: "Returning $result from _submitPhoneNumber");
      return result;
    }
  }

  String get phoneNumber {
    try {
      String unmaskedText = _maskedPhoneKey.currentState?.unmaskedText;
      if (unmaskedText != null)
        _phoneNumber = "${country_code}$unmaskedText".trim();
    } catch (error) {
      Logger.log(TAG,
          message: "Couldn't access state from _maskedPhoneKey: $error");
    }
    return _phoneNumber;
  }

  Future<Null> _verifyPhoneNumber(BuildContext context) async {
    final PhoneVerificationCompleted verificationSuccess =
        (AuthCredential user) {
      Timer.periodic(const Duration(seconds: 7), (timer) {
        timer.cancel();
        //progressDialog.hide();
        Fluttertoast.showToast(
            msg: "Issue with This Number./n Try Again with Another number or signIn Anonmously",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3);
      });
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: this.phoneNumber,
        timeout: _timeOut,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        verificationCompleted: verificationSuccess,
        verificationFailed: verificationFailed);
    Logger.log(TAG, message: "Returning null from _verifyPhoneNumber");
    return null;
  }

  Future<Null> _submitSmsCode(BuildContext context) async {
    final error = _smsInputValidator();
    if (error != null) {
      _updateRefreshing(false);
      _showErrorSnackbar(error);
      return null;
    } else {
      if (this._codeVerified) {
        await _finishSignIn(await _auth.currentUser(), context);
      } else {
        Logger.log(TAG, message: "_linkWithPhoneNumber called");
        await _linkWithPhoneNumber(
            context);
      }
      return null;
    }
  }

  Future<void> _linkWithPhoneNumber(BuildContext context) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
      smsCode: smsCodeController.text,
    );
    FirebaseAuth.instance.signInWithCredential(credential).then((firebase) {
      _firebaseUser = firebase.user;
      Fluttertoast.showToast(
          msg: "Successfully Verfied",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.red,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1
      );
      _finishSignIn(_firebaseUser, context);
    }).catchError((e) {
      print(e);
      progressDialog.hide();
      _showErrorSnackbar("Invalid Code");
    });

  }

  Future<bool> _onCodeVerified(FirebaseUser user) async {
    final isUserValid = (user != null);
    if (isUserValid) {
      setState(() {
        // Here we change the status once more to guarantee that the SMS's
        // text input isn't available while you do any other request
        // with the gathered data
        this.status = AuthStatus.PROFILE_AUTH;
        Logger.log(TAG, message: "Changed status to $status");
      });
    } else {
      //_showErrorSnackbar("We couldn't verify your code, please try again!");
    }
    return isUserValid;
  }

  _finishSignIn(FirebaseUser user, BuildContext context) async {
    await _onCodeVerified(user).then((result) {
      if (result) {
        signIn_User(context, user);
      } else {
        setState(() {
          this.status = AuthStatus.SMS_AUTH;
        });
        _showErrorSnackbar(
            "We couldn't create your profile for now, please try again later");
      }
    });
  }

  Widget _buildResendSmsWidget(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (_codeTimedOut) {
          progressDialog.show();
          await _verifyPhoneNumber(context);
        } else {
          _showErrorSnackbar("You can't retry yet!");
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(color: Colors.black),
            text: "If your code does not arrive in 1 minute, touch",
            children: <TextSpan>[
              TextSpan(
                text: " here",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoBackWidget(BuildContext context) {
    return InkWell(
      onTap: () async {
        this.status = AuthStatus.PHONE_AUTH;
        _updateRefreshing(false);
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(color: Colors.black),
            text: "Edit You Phone Number ${_phoneNumber}",
            children: <TextSpan>[
              TextSpan(
                text: "Click here",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _phoneInputValidator() {
    if (phoneNumberController.text.isEmpty) {
      return "Your phone number can't be empty!";
    } else if (phoneNumberController.text.length < 10) {
      return "This phone number is invalid!";
    }
    return null;
  }

  String _smsInputValidator() {
    if (smsCodeController.text.isEmpty) {
      return "Your verification code can't be empty!";
    } else if (smsCodeController.text.length < 6) {
      return "This verification code is invalid!";
    }
    return null;
  }

  Widget _buildBody(BuildContext context) {
    this.context = context;
    Widget body;
    switch (this.status) {
      case AuthStatus.PHONE_AUTH:
        body = _phoneNumberScreen(context);
        break;
      case AuthStatus.SMS_AUTH:
      case AuthStatus.PROFILE_AUTH:
        body = _phoneCodeScreen(context);
        break;
    }
    return body;
  }

  Future<Null> _onRefresh() async {
    switch (this.status) {
      case AuthStatus.PHONE_AUTH:
        return await _submitPhoneNumber(this.context);
        break;
      case AuthStatus.SMS_AUTH:
        return await _submitSmsCode(this.context);
        break;
      case AuthStatus.PROFILE_AUTH:
        break;
    }
  }

  void _verifyPhoneBtnPress(BuildContext context) {
    progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
    progressDialog.style(message: "Loading Please Wait..........");
    _phoneNumber = phoneNumber;
    if (_phoneNumber.length < 10) {
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("Phone Number is Too Short"),
        backgroundColor: Colors.red,
      ));
    } else {
      _phoneNumber = phoneNumber;
      //Phone Number Authentication Using Firebase.
      progressDialog.show();
      sginInAnonymously();
    }
  }

  void sginInAnonymously() {
    FirebaseAuth.instance.signInAnonymously().then((firebase) {
      progressDialog.hide();
      print(firebase.user.uid);
      ground_owners_db.child(firebase.user.uid).once().then((DataSnapshot datasnapshot) {
        if (datasnapshot == null || datasnapshot.value == null) {
          user_defualts
              .setPhoneandUserID(phoneNumber, firebase.user.uid)
              .then((bool committed) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => SignUpScreen()),
                    (Route<dynamic> route) => false);
          });
          Fluttertoast.showToast(
              msg: "Phone Number Verified.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1);
        } else {
          Map<dynamic, dynamic> user = datasnapshot.value;
          if (user != null) {
            user_defualts.saveUserData1(user);
            user_defualts
                .setPhoneandUserID(phoneNumber, firebase.user.uid)
                .then((bool committed) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                      (Route<dynamic> route) => false);
            });
            Fluttertoast.showToast(
                msg: "Phone Number Verified.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1);
          } else {
            user_defualts
                .setPhoneandUserID(phoneNumber, firebase.user.uid)
                .then((bool committed) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                      (Route<dynamic> route) => false);
            });
            Fluttertoast.showToast(
                msg: "Phone Number Verified..",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1);
          }
        }
      });
    }).catchError((e) {
      print(e);
      progressDialog.hide();
      Fluttertoast.showToast(
          msg: "Invalid Phone Code",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.red,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1);
    });
  }

  void _verifyPhoneBtnPress1(BuildContext context) {
    progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
    _phoneNumber = phoneNumber;
    print("$_phoneNumber");
    print("$phoneNumber");

    if (_phoneNumber == null || _phoneNumber.length < 10) {
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("Phone Number is Too Short"),
        backgroundColor: Colors.red,
      ));
    } else {
      _phoneNumber = phoneNumber;
      this.status == AuthStatus.PROFILE_AUTH;
      _updateRefreshing(true);
      progressDialog.show();
    }
  }

  //Implementation of Update User Token
  void updateFirebaseToken(BuildContext context) {
    String _token;
    DatabaseReference users_token_db = FirebaseDatabase.instance.reference().child("users_tokens");
    _firebaseMessaging.getToken().then((token) {
      _token = token;
      var data =
      {"token": _token};
      FirebaseAuth.instance.currentUser().then((user) {
        users_token_db.child(user.uid).set(data).whenComplete(() {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
              HomeScreen()), (Route<dynamic> route) => false);
        }).catchError((e) {
          print(e);
        });
      });
    });
  }

  //Implementation of User's SignIn
  signIn_User(BuildContext context, FirebaseUser userr) {
  //  progressDialog.hide();
    ground_owners_db.child(userr.uid).once().then((DataSnapshot datasnapshot) {
      if (datasnapshot == null || datasnapshot.value == null) {
        user_defualts
            .setPhoneandUserID(_phoneNumber, userr.uid)
            .then((bool committed) {
          Navigator.pushReplacement(context,
              new MaterialPageRoute(builder: (context) {
                return SignUpScreen();
              }));
        });
        Fluttertoast.showToast(
            msg: "Phone Number Verified.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1);
      } else {
        Map<dynamic, dynamic> user = datasnapshot.value;
        if (user != null) {
          user_defualts.saveUserData1(user);
          user_defualts
              .setPhoneandUserID(_phoneNumber, userr.uid)
              .then((bool committed) {
            checkUsersPendingNotifications(userr.uid);
            updateFirebaseToken(context);
          });

          Fluttertoast.showToast(
              msg: "Phone Number Verified",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1);
        } else {
          user_defualts
              .setPhoneandUserID(_phoneNumber, userr.uid)
              .then((bool committed) {
            Navigator.pushReplacement(context,
                new MaterialPageRoute(builder: (context) {
                  return SignUpScreen();
                }));
          });
          Fluttertoast.showToast(
              msg: "Phone Number Verified",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1);
        }
      }
    });
  }

  Widget _buildDropdownItem(Country country) =>
      Container(
        child: Row(
          children: <Widget>[
            CountryPickerUtils.getDefaultFlagImage(country),
            SizedBox(
              width: 8.0,
            ),
            Text("+${country.phoneCode}(${country.isoCode})"),
          ],
        ),
      );

  verifyCode(BuildContext context) {
    if (smsCodeController.text.length < 6) {
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("Invalid Code"),
        backgroundColor: Colors.green,
      ));
    }
    else {
      progressDialog.show();
      this.status == AuthStatus.PROFILE_AUTH;
      _updateRefreshing(true);
    }
  }

  Future onSelectNotification(String payload)
  {
    Navigator.pushReplacement(context,
        new MaterialPageRoute(builder: (context) {
          return SplashScreen();
        }));
  }

  showNotification(String title,String body) async
  {
    var android = new AndroidNotificationDetails('channel Id', 'channel Name', 'channel Description');
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(0, title, body, platform);
  }

  //Implementation of Check User's Pending Notifications
  void checkUsersPendingNotifications(String id) {
    print("Hello Check Notifications");
    DatabaseReference ref1 = FirebaseDatabase.instance.reference().child("pending_notifications");
    setState(() {
      ref1.child(id).once().then((DataSnapshot datasnapshot){
        var keys = datasnapshot.value.keys;
        var data = datasnapshot.value;
        for(var key in keys)
        {
          setState(() {
            showNotification(data[key]['title'], data[key]['body']);
          });
        }
      });
    });
    ref1.child(id).remove();

  }

  _phoneCodeScreen(BuildContext context) {
    final enabled = this.status == AuthStatus.SMS_AUTH;
    return Builder(
        builder: (context) =>
            Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Container(
                    margin: const EdgeInsets.only(
                        top: 10.0, left: 15.0, right: 15.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    TextField(
                                      keyboardType: TextInputType.number,
                                      enabled: enabled,
                                      textAlign: TextAlign.center,
                                      controller: smsCodeController,
                                      maxLength: 6,
                                      onSubmitted: (text) =>
                                          _updateRefreshing(true),
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .subhead
                                          .copyWith(
                                        fontSize: 18.0,
                                        color: enabled
                                            ? Colors.black
                                            : Theme
                                            .of(context)
                                            .buttonColor,
                                      ),
                                      decoration: new InputDecoration(
                                        hintText: "------",
                                        labelText: "SMS Code",
                                        hintStyle:
                                        TextStyle(color: Colors.black38),
                                        errorText: _errorMessage,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(top: 15.0)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                                flex: 5,
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      new SizedBox(
                                        width: double.infinity,
                                        height: 40.0,
                                        child: new RaisedButton(
                                          child: Text("Verify Code",
                                              style: TextStyle(
                                                  color: HexColor("FFFFFF"),
                                                  fontSize: 14.0)),
                                          onPressed: () => verifyCode(context),
                                          color: HexColor("39B54A"),
                                        ),
                                      )
                                    ],
                                  ),
                                ))
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(top: 15.0)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[_buildResendSmsWidget(
                                        context)
                                    ],
                                  ),
                                ))
                          ],
                        ),
                      ],
                    )),

              ],
            ));
  }

  _phoneNumberScreen(BuildContext context) {
    return Builder(
        builder: (context) =>
            Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Container(
                    margin: const EdgeInsets.only(
                        top: 10.0, left: 15.0, right: 15.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      CountryPickerDropdown(
                                        initialValue: 'pk',
                                        itemBuilder: _buildDropdownItem,
                                        onValuePicked: (Country country) {
                                          print("${country.name}");
                                          country_code = country.phoneCode;
                                        },
                                      ),
                                    ],
                                  ),
                                )),
                            Expanded(
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    MaskedTextField(
                                      key: _maskedPhoneKey,
                                      mask: "3xxxxxxxxx",
                                      keyboardType: TextInputType.number,
                                      maskedTextFieldController:
                                      phoneNumberController,
                                      maxLength: 10,
                                      onSubmitted: (text) =>
                                          _updateRefreshing(true),
                                      inputDecoration: new InputDecoration(
                                          hintText: "Phone Number",
                                          labelText: "Phone Number",
                                          hintStyle:
                                          TextStyle(color: Colors.black38)),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(top: 15.0)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                                flex: 5,
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      new SizedBox(
                                        width: double.infinity,
                                        height: 40.0,
                                        child: new RaisedButton(
                                          child: Text(VERIFY_PHONE,
                                              style: TextStyle(
                                                  color: HexColor("FFFFFF"),
                                                  fontSize: 14.0)),
                                          onPressed: () =>
                                              _verifyPhoneBtnPress1(context),
                                          color: HexColor("39B54A"),
                                        ),
                                      )
                                    ],
                                  ),
                                ))
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(top: 15.0)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                                flex: 5,
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      new SizedBox(
                                        width: double.infinity,
                                        height: 40.0,
                                        child: new RaisedButton(
                                          child: Text("Sign In As Guest",
                                              style: TextStyle(
                                                  color: HexColor("FFFFFF"),
                                                  fontSize: 14.0)),
                                          onPressed: () =>
                                              _verifyPhoneBtnPress(context),
                                          color: HexColor("39B54A"),
                                        ),
                                      )
                                    ],
                                  ),
                                ))
                          ],
                        )
                      ],
                    )),
              ],
            ));
  }


  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = new TextEditingController();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text("Phone Number Verification",
            style: TextStyle(color: Colors.black, fontSize: 22.0)),
        backgroundColor: HexColor("FFFFFF"),
      ),
      body: Container(
        child: ReactiveRefreshIndicator(
          onRefresh: _onRefresh,
          isRefreshing: _isRefreshing,
          child: Container(child: _buildBody(context)),
        ),
      ),
    );
  }


}