import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/view_model/user_model.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: <Widget>[
          FlatButton(onPressed: ()=>_signOut(context), child: Text('Çıkış'),),
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
 
 
}

