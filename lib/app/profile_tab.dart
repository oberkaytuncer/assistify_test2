import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/common_widget/buttons/gradient_button.dart';
import 'package:flutter_messaging_app/common_widget/platform_sensetive_widget/platform_sensetive_alert_dialog.dart';
import 'package:flutter_messaging_app/view_model/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  TextEditingController _controllerUserName;
  File _profilePhoto;

  @override
  void initState() {
    super.initState();
    _controllerUserName = TextEditingController();
  }

  @override
  void dispose() {
    _controllerUserName.dispose();
    super.dispose();
  }

  void _takeAPhoto() async {
    var newProfilePhoto =
        await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _profilePhoto = newProfilePhoto;
      Navigator.of(context).pop();
    });
  }

  void _chooseFromLibrary() async {
    var newProfilePhoto =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _profilePhoto = newProfilePhoto;
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    UserModel _userModel = Provider.of<UserModel>(context);
    _controllerUserName.text = _userModel.user.userName;

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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text('Profil'),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.camera),
                                  title: Text('Kameradan Çek'),
                                  onTap: () {
                                    _takeAPhoto();
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.image),
                                  title: Text('Galeriden Seç'),
                                  onTap: () {
                                    _chooseFromLibrary();
                                  },
                                ),
                                ListTile(),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        height: 150,
                        width: 100,
                        child: _profilePhoto == null
                            ? Image(
                                image: NetworkImage(
                                    _userModel.user.profilePhotoURL),
                              )
                            : Image.file(_profilePhoto),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: _userModel.user.email,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Emailiniz:',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _controllerUserName,
                  readOnly: false,
                  decoration: InputDecoration(
                    labelText: 'Kullanıcı Adınız:',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              GradientButton(
                buttonText: 'Değişiklikleri kaydet',
                onPressed: () {
                  _updateUserName(context);
                  _updateProfilePhoto(context);
                },
              ),
            ],
          ),
        ),
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

  void _updateUserName(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    if (_userModel.user.userName != _controllerUserName.text) {
      bool updateResult = await _userModel.updateUserName(
          _userModel.user.userID,
          _controllerUserName
              .text); //**burası aşırı önemli. 252. dersin sonlarında 12. dakikada. Aldığım bir değeri nasıl UserModele atıyorum onu anlatıyor.

      if (updateResult == true) {
        AlertDialogPlatformSensetive(
                title: 'Başarılı',
                content: 'UserName değiştirildi.',
                mainActionButtonText: 'Tamam')
            .show(context);
      } else {
        _controllerUserName.text = _userModel.user.userName;
        AlertDialogPlatformSensetive(
                title: 'İşlem Başarısız',
                content:
                    'Bu kullanıcı adı bir başkası tarafından kullanılıyor. Lütfen başka bir kullanıcı adı deneyiniz. ',
                mainActionButtonText: 'Tamam')
            .show(context);
      }
    }
  }

  void _updateProfilePhoto(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    if (_profilePhoto != null) {
      var url = await _userModel.uploadFile(
          _userModel.user.userID, 'user_profile_photo', _profilePhoto);
      print('Gelen URL: ' + url);

      if (url != null) {
        AlertDialogPlatformSensetive(
                title: 'Başarılı',
                content: 'İşlem Başarılı bir şekilde gerçekleşti ',
                mainActionButtonText: 'Tamam')
            .show(context);
      }
    }
  }
}
