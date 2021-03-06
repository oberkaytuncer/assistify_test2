import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/locator.dart';
import 'package:flutter_messaging_app/model/conversation.dart';
import 'package:flutter_messaging_app/model/message.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/repository/user_repository.dart';
import 'package:flutter_messaging_app/services/auth_base.dart';

enum ViewState { Idle, Busy }

class UserModel with ChangeNotifier implements AuthBase {
  ViewState _state = ViewState.Idle;
  UserRepository _userRepository = locator<UserRepository>();
  User _user;
  String emailErrorMessage;
  String passwordErrorMessage;

  ViewState get state => _state;

  set state(ViewState newState) {
    _state = newState;
    notifyListeners();
  }

  UserModel() {
    currentUser();
  }

  get user => _user;

  @override
  Future<User> currentUser() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.currentUser();
      if(_user != null)
      return _user;
      else return null;
    } catch (e) {
      debugPrint('Hata: user_model -> currentUser ' + e.toString());
      return null;
    } finally {
      state = ViewState.Idle;
      debugPrint("İşlem tamam: user_model -> currentUser");
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      state = ViewState.Busy;

      bool result = await _userRepository.signOut();
      _user = null;
      return result;
    } catch (e) {
      debugPrint('Hata: user_model -> signOut' + e.toString());
      return false;
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<User> signInAnonymously() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.signInAnonymously();
      return _user;
    } catch (e) {
      debugPrint('Hata: user_model -> signInAnonymously' + e.toString());
      return null;
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.signInWithGoogle();
      if(_user!= null)
      return _user;
      else return null;
    } catch (e) {
      debugPrint('Hata: user_model -> signInWithGoogle' + e.toString());
      return null;
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<User> signInWithFacebook() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.signInWithFacebook();
      if(_user != null)
      return _user;
      else {
        return null;
      }
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<User> createUserWithEmailAndPassword(
      String email, String password) async {
    if (_emailPasswordControl(email, password)) {
      try {
        state = ViewState.Busy;
        _user = await _userRepository.createUserWithEmailAndPassword(
            email, password);
        state = ViewState.Idle;
        return _user;
      } finally {
        state = ViewState.Idle;
      }
    } else {
      //state = ViewState.Idle;
      return null;
    }
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      if (_emailPasswordControl(email, password)) {
        state = ViewState.Busy;
        _user =
            await _userRepository.signInWithEmailAndPassword(email, password);
        return _user;
      } else
        return null;
    } finally {
      state = ViewState.Idle;
    }
  }

  bool _emailPasswordControl(String email, String password) {
    var result = true;
    if (password.length < 6) {
      passwordErrorMessage = 'En az 6 karakter olmalı';
      result = false;
    } else {
      passwordErrorMessage = null;
    }

    if (!email.contains('@')) {
      emailErrorMessage = 'Geçersiz mail adresi';
      result = false;
    } else {
      emailErrorMessage = null;
    }

    return result;
  }

  Future<bool> updateUserName(String userID, String newUserName) async {
    var result = await _userRepository.updateUserName(userID, newUserName);
    if (result) {
      _user.userName = newUserName;
    }

    return result;
  }

  Future<String> uploadFile(
      String userID, String fileType, File willUploadFile) async {
    var url =
        await _userRepository.uploadFile(userID, fileType, willUploadFile);

    return url;
  }

 

  Stream<List<Messages>> getMessages(
      String currentUserID, String oppositeUserID) {
    var result = _userRepository.getMessages(currentUserID, oppositeUserID);
    return result;
  }

 

  Future<List<Conversation>> getAllConversations(userID) async {
    var result = await _userRepository.getAllConversations(userID);
    return result;
  }

  Future<List<User>> getUserWithPagination(
      User lastGottenUser, int amountOfUserToGet) async {
    var result = await _userRepository.getUserWithPagination(
        lastGottenUser, amountOfUserToGet);
    return result;
  }
}
