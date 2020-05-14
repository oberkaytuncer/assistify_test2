import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageFrom;
  final String messageTo;
  final bool isItFromMe;
  final String messageContent;
  final DateTime messageDate;

  Message({
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

  Message.fromMap(Map<String, dynamic> map)
      : messageFrom = map['messageFrom'],
        messageTo = map['messageTo'],
        isItFromMe = map['isItFromMe'],
        messageContent = map['messageContent'],
        messageDate = (map['messageDate'] as Timestamp).toDate();

  @override
  String toString() {
    return 'Message{messageFrom: $messageFrom, messageTo: $messageTo, isItFromMe: $isItFromMe, messageContent: $messageContent, messageDate: $messageDate } ';
  }
}
