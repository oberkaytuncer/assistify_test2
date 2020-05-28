import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_messaging_app/model/slot.dart';

class RealtimeFirebaseDBService {
  Future<bool> addSlotDataDailyRealtimeDB(
      String studioID, String userID, Slot slot) async {
    var grounds_db = await FirebaseDatabase.instance.reference().child("grounds");
    var _willSaveSlotMap = slot.toMap();
    await grounds_db
        .child(userID)
        .child("Slots")
        .child(slot.date)
        .child(slot.slot_id)
        .set(_willSaveSlotMap);

    return true;
  }
}
