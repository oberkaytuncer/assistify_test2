import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_messaging_app/app/chat_page.dart';
import 'package:flutter_messaging_app/model/conversation.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/view_model/chat_view_model.dart';
import 'package:flutter_messaging_app/view_model/user_model.dart';
import 'package:provider/provider.dart';

class MyConversationTab extends StatefulWidget {
  @override
  _MyConversationTabState createState() => _MyConversationTabState();
}

class _MyConversationTabState extends State<MyConversationTab> {
  @override
  Widget build(BuildContext context) {
    UserModel _userModel = Provider.of<UserModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Konuşmalarım'),
      ),
      body: FutureBuilder<List<Conversation>>(
        future: _userModel.getAllConversations(_userModel.user.userID),
        builder: (context, conversationList) {
          if (!conversationList.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            var allConversation = conversationList.data;

            if (allConversation.length > 0) {
              return RefreshIndicator(
                onRefresh: _refreshConversationList,
                child: ListView.builder(
                    itemCount: allConversation.length,
                    itemBuilder: (context, index) {
                      var currentConversation = allConversation[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChangeNotifierProvider<ChatViewModel>(
                                create: (context) => ChatViewModel(
                                  currentUser: _userModel.user,
                                  oppositeUser: User.idAndProfilePhotoURL(
                                      userID: currentConversation.chat_guest,
                                      profilePhotoURL: currentConversation
                                          .guestUserProfilePhotoURL),
                                ),
                                child: ChatPage(),
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          title: Text(currentConversation.last_sent_message),
                          subtitle: Text(currentConversation.guestUserName +
                              '    ' +
                              currentConversation.timeDifference),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                currentConversation.guestUserProfilePhotoURL),
                          ),
                        ),
                      );
                    }),
              );
            } else {
              return RefreshIndicator(
                onRefresh: _refreshConversationList,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.message,
                            color: Theme.of(context).primaryColor,
                            size: 60,
                          ),
                          Text(
                            'Henüz Konuşma yapılmamış',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24),
                          ),
                        ],
                      ),
                    ),
                    height: MediaQuery.of(context).size.height - 150,
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _getMyChat() async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    var myAllChat = await Firestore.instance
        .collection('chats')
        .where('chat_owner', isEqualTo: _userModel.user.userID)
        .orderBy('created_date_message', descending: true)
        .getDocuments();

    for (var chat in myAllChat.documents) {
      debugPrint('Konuşmalarım: ' + chat.data.toString());
    }
  }

  Future<Null> _refreshConversationList() async {
    setState(() {});
    await Future.delayed(Duration(milliseconds: 500));
    return null;
  }
}
