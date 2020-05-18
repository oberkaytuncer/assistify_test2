import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_messaging_app/app/error_exception.dart';
import 'package:flutter_messaging_app/common_widget/buttons/flat_button.dart';
import 'package:flutter_messaging_app/common_widget/buttons/gradient_button.dart';
import 'package:flutter_messaging_app/common_widget/cards/my_text_field.dart';
import 'package:flutter_messaging_app/common_widget/platform_sensetive_widget/platform_sensetive_alert_dialog.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/view_model/user_model.dart';
import 'package:provider/provider.dart';

enum FormType { Register, SignIn }

class EmailAndPassSignInPage extends StatefulWidget {
  @override
  _EmailAndPassSignInPageState createState() => _EmailAndPassSignInPageState();
}

class _EmailAndPassSignInPageState extends State<EmailAndPassSignInPage> {
  String _email, _password;
  final _formKey = GlobalKey<FormState>();
  var _formType = FormType.SignIn;
  String _buttonText, _linkText;

  void _formSubmit(BuildContext context) async {
    _formKey.currentState.save();
    debugPrint(
        'İşlem Tamam: email_and_pass_signin_signout -> _formSubmit methodu' +
            'Emailin: $_email Şifren: $_password');

    final _userModel = Provider.of<UserModel>(context, listen: false);

    if (_formType == FormType.SignIn) {
      try {
        User _signedInUser =
            await _userModel.signInWithEmailAndPassword(_email, _password);
        if (_signedInUser != null)
          print(
              'İşlem tamam: email_and_pass_signin_signout -> _signedInUser . Email ve şifre ile oturum açan kullanıcı ID: ' +
                  _signedInUser.userID);
      } on PlatformException catch (e) {
        AlertDialogPlatformSensetive(
          title: 'Kullanıcı Girişi Hata',
          content: Errors.showError(e.code),
          mainActionButtonText: 'Tamam',
        ).show(context);
      }
    } else {
      try {
        User _createdNewUser =
            await _userModel.createUserWithEmailAndPassword(_email, _password);
        if (_createdNewUser != null)
          print('Email ve şifre ile yeni kullanıcı yaratılan ID: ' +
              _createdNewUser.userID);
      } on PlatformException catch (e) {
        AlertDialogPlatformSensetive(
          title: 'Kullanıcı Oluşturma Hata',
          content: Errors.showError(e.code),
          mainActionButtonText: 'Tamam',
        ).show(context);
      }
    }
  }

  void _changeFormType() {
    setState(() {
      _formType =
          _formType == FormType.SignIn ? FormType.Register : FormType.SignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    _buttonText = _formType == FormType.SignIn ? 'Giriş Yap' : 'Kayıt ol';
    _linkText = _formType == FormType.SignIn
        ? 'Hesabınız yok mu? Kayıt olun.'
        : 'Hesabınız var mı? Giriş yapın';

    final _userModel = Provider.of<UserModel>(context);
/*
 //1Bu kısım Busy olduğu zaman dönen indicator


    if (_userModel.state == ViewState.Idle) {
      if (_userModel.user != null) {
        debugPrint('usermodel null döndü');
        return HomePage(
          user: _userModel.user,
        );
      }
    } else if (_userModel.state == ViewState.Busy) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
//1 Bu kısım Busy olduğu zaman dönen indicator
*/

// Bu kısıma batuhanla bakacaksınız. Çünkü bu alttaki if kısmını silince şöyle birşey oluyor.
// Scaffoldun içindeki body'in en başında state var ya o aslında UserModelde state değiştiği zaman tekrar
//uyarılıyor ve bakıyor duruma ben neydim ne oldum diye. Ondan dolayı eğer kullanıcı giriş yapabilmişse
//idle a tekrar düşüyor ve hem ana sayfa çağırılıyor hem de  scaffold un single kısmı çağırılıyor.

    if (_userModel.user != null) {
      Future.delayed(Duration(milliseconds: 1), () {
        Navigator.of(context).popUntil(ModalRoute.withName('/'));
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Email ve Şifre ile kayıt'),
      ),
      body: _userModel.state == ViewState.Idle
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      MyTextFormField(
                          errorText: _userModel.emailErrorMessage != null
                              ? _userModel.emailErrorMessage
                              : null,
                          initialValue: 'berkay@berkay.com',
                          hintText: 'E-mail',
                          labelText: 'Email',
                          onSaved: (String value) => _email = value),
                      MyTextFormField(
                          errorText: _userModel.passwordErrorMessage != null
                              ? _userModel.passwordErrorMessage
                              : null,
                          initialValue: '123456',
                          hintText: 'Şifre',
                          labelText: 'Şifre',
                          obscureText: true,
                          onSaved: (String value) => _password = value),
                      GradientButton(
                        buttonText: _buttonText,
                        onPressed: () => _formSubmit(context),
                      ),
                      SizedBox(height: 12),
                      MyFlatButtons(
                        textFlatButtons: _linkText,
                        onPressed: () => _changeFormType(),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
