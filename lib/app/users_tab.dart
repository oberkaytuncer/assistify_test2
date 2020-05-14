import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/app/chat.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/view_model/user_model.dart';
import 'package:provider/provider.dart';

class UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserModel _userModel = Provider.of<UserModel>(context);
    _userModel.getAllUsers();
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: FutureBuilder<List<User>>(
          future: _userModel.getAllUsers(),
          builder: (context, result) {
            if (result.hasData) {
              var allUsers = result.data;
              if (allUsers.length - 1 > 0) {
                return ListView.builder(
                  itemCount: allUsers.length,
                  itemBuilder: (context, index) {
                    var nextUser = result.data[index];

                    if (nextUser.userID != _userModel.user.userID) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) => Chat(
                                currentUser: _userModel.user,
                                oppositeUser: nextUser,
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          title: Text(nextUser.userName),
                          subtitle: Text(nextUser.email),
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(nextUser.profilePhotoURL),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                );
              } else {
                Center(
                  child: Text('Kayıtlı bir kullanıcı yok'),
                );
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
