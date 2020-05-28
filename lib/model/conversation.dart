import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String chat_guest;
  final String chat_owner;
  final Timestamp created_date_message;
  final String last_sent_message;
  final bool seen_message;
  final Timestamp seen_date_message;
  String guestUserName;
  String guestUserProfilePhotoURL;
  DateTime lastReadTime;
  String timeDifference;

  Conversation({
    this.chat_guest,
    this.chat_owner,
    this.created_date_message,
    this.last_sent_message,
    this.seen_message,
    this.seen_date_message,
  });

  Map<String, dynamic> toMap() {
    return {
      'chat_guest': chat_guest,
      'chat_owner': chat_owner,
      'created_date_message':
          created_date_message ?? FieldValue.serverTimestamp(),
      'last_sent_message': last_sent_message,
      'seen_message': seen_message,
      'seen_date_message': seen_date_message ?? FieldValue.serverTimestamp(),
    };
  }

  Conversation.fromMap(Map<String, dynamic> map)
      : chat_guest = map['chat_guest'],
        chat_owner = map['chat_owner'],
        created_date_message = map['created_date_message'],
        last_sent_message = map['last_sent_message'],
        seen_message = map['seen_message'],
        seen_date_message = map['seen_date_message'];

  @override
  String toString() {
    return 'Chat{chat_guest: $chat_guest, chat_owner: $chat_owner, created_date_message: $created_date_message, last_sent_message: $last_sent_message, seen_message: $seen_message, seen_date_message: $seen_date_message } ';
  }
}
