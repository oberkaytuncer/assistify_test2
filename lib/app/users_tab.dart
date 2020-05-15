import 'package:flutter/material.dart';

import 'package:flutter_messaging_app/app/chat_page.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/view_model/user_model.dart';
import 'package:provider/provider.dart';

class UsersTab extends StatefulWidget {
  @override
  _UsersTabState createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
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
                return RefreshIndicator(
                  onRefresh: _refreshUserList,
                  child: ListView.builder(
                    itemCount: allUsers.length,
                    itemBuilder: (context, index) {
                      var nextUser = result.data[index];

                      if (nextUser.userID != _userModel.user.userID) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
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
                  ),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: _refreshUserList,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Container(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.supervised_user_circle,
                              color: Theme.of(context).primaryColor,
                              size: 60,
                            ),
                            Text(
                              'Henüz Kullanıcı yok',
                              style: TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                      ),
                      height: MediaQuery.of(context).size.height-150,
                    ),
                  ),
                );
              }
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Future<Null> _refreshUserList() async {
    setState(() {});
    await Future.delayed(Duration(milliseconds: 500));
    return null;
  }
}
