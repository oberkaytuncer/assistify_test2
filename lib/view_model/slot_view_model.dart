import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/locator.dart';
import 'package:flutter_messaging_app/model/slot.dart';
import 'package:flutter_messaging_app/model/studio.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/repository/user_repository.dart';
import 'package:flutter_messaging_app/view_model/user_model.dart';
import 'package:provider/provider.dart';

enum SlotViewState { Idle, Loaded, Busy }

class SlotViewModel with ChangeNotifier {
  List<Slot> _allSlots;
  SlotViewState _state = SlotViewState.Idle;
  static final postsPerPage = 10;
  final Studio currentStudio;
  Slot _lastGottenSlot;
  Slot _firstAddedSlotInList;
  UserRepository _userRepository = locator<UserRepository>();
  bool _hasMore = true;
  bool _newSlotRealTimeListener = false;
  bool get hasMoreLoading => _hasMore;
  StreamSubscription _streamSubscription;
  List<Slot> get messagesList => _allSlots;

  SlotViewState get state => _state;
  set state(SlotViewState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  dispose() {
    // print('ChatViewModel Dispose edildi.');
    _streamSubscription.cancel();
    super.dispose();
  }

  SlotViewModel({this.currentStudio}) {
    _allSlots = [];
    //getSlotWithPagination(false);
  }

  Future<bool> saveSlot(Slot willSaveSlot, Studio studio) async {
    willSaveSlot = Slot.withOwnerIDandSlotID(
      slotOwnerID: studio.ownerID,
      slotOwnerStudioID: studio.studioID,
    );

    var willSaveResult = await _userRepository.saveSlot(willSaveSlot);
    return willSaveResult;
  }
/*
  void getSlotWithPagination(bool newSlotIsGetting) async {
    if (_allSlots.length > 0) {
      _lastGottenSlot = _allSlots.last;
    }

    if (!newSlotIsGetting) {
      state = SlotViewState.Busy;
    }

    var loadedSlots = await _userRepository.getSlotWithPagination(
        currentUser.userID, oppositeUser.userID, _lastGottenSlot, postsPerPage);

    if (loadedSlots.length < postsPerPage) {
      _hasMore = false;
    }

    /*
        loadedMessages.forEach((element) {
      print('getirilen mesajlar: ' + element.messageContent);
    }
    );

    */

    _allSlots.addAll(loadedSlots);

    if (_allSlots.length > 0) {
      _firstAddedSlotInList = _allSlots.first;
      //print('Listeye eklenen ilk mesaj: ' + _firstAddedMessageInList.toString());
    }

    state = SlotViewState.Loaded;

    if (_newSlotRealTimeListener == false) {
      _newSlotRealTimeListener = true;
      //print('Listener yok o yüzden atanacak.( Bu yazının sadece bir kere çağırılması gerek birden falza çağırılmaması gerek.)');
      assignNewSlotListener();
    }
  }

  Future<void> getMoreSlot() async {
    // print('Chat View Model içinde getMoreMessage methodu tetkilendi. ');
    if (_hasMore)
      getSlotWithPagination(true);
    else
      //print('Daha fazla eleman yok. O yüzden çağırılmayacak.');
      await Future.delayed(Duration(seconds: 1));
  }

  void assignNewSlotListener() {
    // print('Yeni mesajlar için listener atandı.');
    _streamSubscription = _userRepository
        .getSlots(currentUser.userID, oppositeUser.userID)
        .listen((event) {
      if (event.isNotEmpty) {
        // print('Listener tetiklendi ve son getirilen veri' + event[0].toString());

        if (event[0].messageDate != null) {
          if (_firstAddedSlotInList == null) {
            _allSlots.insert(0, event[0]);
          } else if (_firstAddedSlotInList.slotDate.millisecondsSinceEpoch !=
              event[0].messageDate.millisecondsSinceEpoch)
            _allSlots.insert(0, event[0]);
        }

        state = SlotViewState.Loaded;
      }
    });
  }*/
}
