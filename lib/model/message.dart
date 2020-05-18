import 'package:cloud_firestore/cloud_firestore.dart';

class Messages {
  final String messageFrom;
  final String messageTo;
  final bool isItFromMe;
  final String messageContent;
  final Timestamp messageDate;

  Messages({
    this.messageFrom,
    this.messageTo,
    this.isItFromMe,
    this.messageContent,
    this.messageDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageFrom': messageFrom,
      'messageTo': messageTo,
      'isItFromMe': isItFromMe,
      'messageContent': messageContent,
      'messageDate': messageDate ?? FieldValue.serverTimestamp(),
    };
  }

  Messages.fromMap(Map<String, dynamic> map)
      : messageFrom = map['messageFrom'],
        messageTo = map['messageTo'],
        isItFromMe = map['isItFromMe'],
        messageContent = map['messageContent'],
        messageDate = map['messageDate'];

  @override
  String toString() {
    return 'Message{messageFrom: $messageFrom, messageTo: $messageTo, isItFromMe: $isItFromMe, messageContent: $messageContent, messageDate: $messageDate } ';
  }
}
