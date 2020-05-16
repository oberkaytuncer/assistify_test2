import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/locator.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/repository/user_repository.dart';

enum AllUserViewState { Idle, Loaded, Busy }

class AllUsersViewModel with ChangeNotifier {
  AllUserViewState _state = AllUserViewState.Idle;
  List<User> _allUsers;
  User _lastGottenUser;
  static final postsPerPage = 10;
  bool _hasMore = true;
  bool get hasMoreLoading => _hasMore;

  UserRepository _userRepository = locator<UserRepository>();

  List<User> get usersList => _allUsers;

  AllUserViewState get state => _state;
  set state(AllUserViewState newState) {
    _state = newState;
    notifyListeners();
  }

  AllUsersViewModel() {
    _allUsers = [];
    _lastGottenUser = null;
    getUserWithPagination(_lastGottenUser, false);
  }


  //Refresh ve sayfalama için
  //newPostsIsGetting => true yapılır.
  //ilk açılış için newPostsIsGetting => false değer verilir.
  getUserWithPagination(User lastGottenUser, bool newPostsIsGetting) async {

    
    if (_allUsers.length > 0) {
      _lastGottenUser = _allUsers.last;
      print('en son getirilen username: ' + _lastGottenUser.userName);
    }

    if (newPostsIsGetting) {
    } else {
      state = AllUserViewState.Busy;
    }

    var newList = await _userRepository.getUserWithPagination(
        _lastGottenUser, postsPerPage);

    if (newList.length < postsPerPage) {
      _hasMore = false;
    }

    newList
        .forEach((element) => print('Getirilen UserName: ' + element.userName));

    _allUsers.addAll(newList);
    state = AllUserViewState.Loaded;
  }

  Future<void> getMoreUser() async {
    print('View Model içinde getMoreUser methodu tetkilendi. ');
    if (_hasMore)
      getUserWithPagination(_lastGottenUser, true);
    else
      print('Daha fazla eleman yok. O yüzden çağırılmayacak.');
    await Future.delayed(Duration(seconds: 1));
  }

  Future<Null> refresh() async {
    _hasMore = true;
    _lastGottenUser =null;
    _allUsers = [];
    getUserWithPagination(_lastGottenUser, true);
  }
}
