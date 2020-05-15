import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum TabItem { Users, MyChat, Profile }

class TabItemData {
  final String title;
  final IconData icon;

  TabItemData(this.title, this.icon);

  static Map<TabItem, TabItemData> allTabs = {
    TabItem.Users: TabItemData('Kullanıcılar', Icons.supervised_user_circle),
    TabItem.MyChat: TabItemData('Konuşmalarım', Icons.chat_bubble),
    TabItem.Profile: TabItemData('Profil', Icons.person),
  };
}
