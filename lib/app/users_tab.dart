import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/app/chat_page.dart';
import 'package:flutter_messaging_app/view_model/all_users_view_model.dart';
import 'package:flutter_messaging_app/view_model/user_model.dart';
import 'package:provider/provider.dart';

class UsersTab extends StatefulWidget {
  @override
  _UsersTabState createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  bool _isLoading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

//minscrollextend listenin en sonuna geldiğimizde oluşur.
//maxscrollextend listenin en başına geldiğimizde oluşur.

    _scrollController.addListener(_listScrollListener);
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('asfdsf'),
      ),
      body: Consumer<AllUsersViewModel>(
        builder: (context, model, child) {
          if (model.state == AllUserViewState.Busy) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (model.state == AllUserViewState.Loaded) {
            return RefreshIndicator(
              onRefresh: model.refresh,
                          child: ListView.builder(
                controller: _scrollController,
                itemCount: model.hasMoreLoading
                    ? model.usersList.length + 1
                    : model.usersList.length,
                itemBuilder: (context, index) {

                  if(model.usersList.length ==1 ){
                    return _noUserUI();
                  }
                  if (model.hasMoreLoading && index == model.usersList.length) {
                    return _newUsersisLoadingIndicator();
                  } else {
                    return _createUserListChild(index);
                  }
                },
              ),
            );
          } else {}
        },
      ),
    );
  }


Widget _noUserUI(){
   final _allUserViewModel = Provider.of<AllUsersViewModel>(context, listen: false);
          return RefreshIndicator(
            onRefresh: _allUserViewModel.refresh,
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
                        size: 120,
                      ),
                      Text(
                        'Henüz bir kullanıcı yok',
                        style: TextStyle(fontSize: 36),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
}
    
  Widget _createUserListChild(int index) {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    final _allUserViewModel =
        Provider.of<AllUsersViewModel>(context, listen: false);
    var _currentUser = _allUserViewModel.usersList[index];
    if (_currentUser.userID == _userModel.user.userID) {
      return Container();
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (BuildContext context) => ChatPage(
                currentUser: _userModel.user, oppositeUser: _currentUser),
          ),
        );
      },
      child: Card(
        child: ListTile(
          title: Text(_currentUser.userName),
          subtitle: Text(_currentUser.email),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(_currentUser.profilePhotoURL),
          ),
        ),
      ),
    );
  }

  _newUsersisLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void getMoreUser() async {
    if (!_isLoading) {
      _isLoading = true;
      final _allUserViewModel =
          Provider.of<AllUsersViewModel>(context, listen: false);
      await _allUserViewModel.getMoreUser();
      _isLoading = false;
    }
  }

  void _listScrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
          print('Listenin en altındayız.');
      getMoreUser();
    }

  }
}
