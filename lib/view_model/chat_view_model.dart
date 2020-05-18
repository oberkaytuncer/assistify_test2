import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/locator.dart';
import 'package:flutter_messaging_app/model/message.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/repository/user_repository.dart';

enum ChatViewState { Idle, Loaded, Busy }

class ChatViewModel with ChangeNotifier {
  List<Messages> _allMessages;
  ChatViewState _state = ChatViewState.Idle;
  static final postsPerPage = 10;
  final User currentUser;
  final User oppositeUser;
  Messages _lastGottenMessage;
  Messages _firstAddedMessageInList;
  UserRepository _userRepository = locator<UserRepository>();
  bool _hasMore = true;
  bool _newMessageRealTimeListener = false;
  bool get hasMoreLoading => _hasMore;
  StreamSubscription _streamSubscription;

  List<Messages> get messagesList => _allMessages;

  ChatViewState get state => _state;

  set state(ChatViewState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  dispose() {
    // print('ChatViewModel Dispose edildi.');
    _streamSubscription.cancel();
    super.dispose();
  }

  ChatViewModel({this.currentUser, this.oppositeUser}) {
    _allMessages = [];
    getMessageWithPagination(false);
  }

  Future<bool> saveMessage(Messages willSaveMessage, User currentUser) async {
    var willSaveResult = await _userRepository.saveMessage(willSaveMessage, currentUser);
    return willSaveResult;
  }

  void getMessageWithPagination(bool newMessagesIsGetting) async {
    if (_allMessages.length > 0) {
      _lastGottenMessage = _allMessages.last;
    }

    if (!newMessagesIsGetting) {
      state = ChatViewState.Busy;
    }

    var loadedMessages = await _userRepository.getMessageWithPagination(
        currentUser.userID,
        oppositeUser.userID,
        _lastGottenMessage,
        postsPerPage);

    if (loadedMessages.length < postsPerPage) {
      _hasMore = false;
    }

    /*
        loadedMessages.forEach((element) {
      print('getirilen mesajlar: ' + element.messageContent);
    }
    );

    */

    _allMessages.addAll(loadedMessages);

    if (_allMessages.length > 0) {
      _firstAddedMessageInList = _allMessages.first;
      //print('Listeye eklenen ilk mesaj: ' + _firstAddedMessageInList.toString());
    }

    state = ChatViewState.Loaded;

    if (_newMessageRealTimeListener == false) {
      _newMessageRealTimeListener = true;
      //print('Listener yok o yüzden atanacak.( Bu yazının sadece bir kere çağırılması gerek birden falza çağırılmaması gerek.)');
      assignNewMessageListener();
    }
  }

  Future<void> getMoreMessage() async {
    // print('Chat View Model içinde getMoreMessage methodu tetkilendi. ');
    if (_hasMore)
      getMessageWithPagination(true);
    else
      //print('Daha fazla eleman yok. O yüzden çağırılmayacak.');
      await Future.delayed(Duration(seconds: 1));
  }

  void assignNewMessageListener() {
    // print('Yeni mesajlar için listener atandı.');
    _streamSubscription = _userRepository
        .getMessages(currentUser.userID, oppositeUser.userID)
        .listen((event) {
      if (event.isNotEmpty) {
        // print('Listener tetiklendi ve son getirilen veri' + event[0].toString());

        if (event[0].messageDate != null) {
          if (_firstAddedMessageInList == null) {
            _allMessages.insert(0, event[0]);
          } else if (_firstAddedMessageInList
                  .messageDate.millisecondsSinceEpoch !=
              event[0].messageDate.millisecondsSinceEpoch)
            _allMessages.insert(0, event[0]);
        }

        state = ChatViewState.Loaded;
      }
    });
  }
}
