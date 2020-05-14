import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/model/message.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/view_model/user_model.dart';
import 'package:provider/provider.dart';

class Chat extends StatefulWidget {
  final User currentUser;
  final User oppositeUser;

  Chat({@required this.currentUser, @required this.oppositeUser});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  var _messageController = TextEditingController();

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
                        itemCount: allMessages.length,
                        itemBuilder: (context, index) {
                          return Text(allMessages[index].messageContent);
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
}
