import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/model/message.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/view_model/user_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final User currentUser;
  final User oppositeUser;

  ChatPage({@required this.currentUser, @required this.oppositeUser});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  var _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    User _currentUser = widget.currentUser;
    User _oppositeUser = widget.oppositeUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Konuşma'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder<List<Message>>(
                  stream: _userModel.getMessages(
                      _currentUser.userID, _oppositeUser.userID),
                  builder: (context, streamMessageList) {
                    if (!streamMessageList.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      List<Message> allMessages = streamMessageList.data;
                      return ListView.builder(
                        reverse: true,
                        controller: _scrollController,
                        itemCount: allMessages.length,
                        itemBuilder: (context, index) {
                          return _createChatBubble(allMessages[index]);
                        },
                      );
                    }
                  }),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 8, left: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      cursorColor: Colors.blueGrey,
                      style: new TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Mesajınızı Yazın",
                        border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    child: FloatingActionButton(
                      elevation: 0,
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.navigation,
                        size: 35,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        if (_messageController.text.trim().length > 0) {
                          Message _willSaveMessage = Message(
                            messageFrom: _currentUser.userID,
                            messageTo: _oppositeUser.userID,
                            isItFromMe: true,
                            messageContent: _messageController.text,
                          );

                          var result =
                              await _userModel.saveMessage(_willSaveMessage);

                          if (result) {
                            _messageController.clear();
                            _scrollController.animateTo(0.0,
                                duration: const Duration(milliseconds: 10),
                                curve: Curves.easeOut);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _createChatBubble(Message currentMessage) {
    Color _receivedMessageColor = Colors.purple;
    Color _sentMessageColor = Theme.of(context).primaryColor;
    String _valueHourMinute = '';

    try {
      _valueHourMinute = _showHourMinute(currentMessage.messageDate ?? Timestamp(1,1));
    } catch (e) {
      print('Hata var ' + e.toString());
    }

    bool _isItMyMessage = currentMessage.isItFromMe;

    if (_isItMyMessage) {
      return Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: _sentMessageColor,
                    ),
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.all(4),
                    child: Text(
                      currentMessage.messageContent,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Text(_valueHourMinute),
              ],
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage:
                      NetworkImage(widget.oppositeUser.profilePhotoURL),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: _receivedMessageColor,
                    ),
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.all(6),
                    child: Text(currentMessage.messageContent),
                  ),
                ),
                Text(_valueHourMinute),
              ],
            ),
          ],
        ),
      );
    }
  }

  String _showHourMinute(Timestamp messageDate) {
    var _formatter = DateFormat.Hm();
    var _formattedTime = _formatter.format(messageDate.toDate());
    return _formattedTime;
  }
}
