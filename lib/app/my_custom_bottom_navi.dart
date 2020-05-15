import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/app/tab_items.dart';

class MyCustomBottomNavigationBar extends StatelessWidget {
  const MyCustomBottomNavigationBar({
    Key key,
    @required this.currentTab,
    @required this.onSelectedTab,  
    @required this.pageBuilder,
    @required this.navigatorsKey,

  }) : super(key: key);

  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectedTab;  //bu value yani onSelectedTab seçilen sayfanın verisin bir callback ile homepage'e veriyor.
  final Map<TabItem, Widget> pageBuilder;
  final Map<TabItem, GlobalKey<NavigatorState>> navigatorsKey;


  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
          items: [
            _createNavigationItem(TabItem.Users),
            _createNavigationItem(TabItem.MyChat),
            _createNavigationItem(TabItem.Profile),
          ],
          onTap: (index) => onSelectedTab(TabItem.values[
              index]) //** bu kısımda taba basılınca hangi elemanın döndüğünü söylüyor. Burası baya önemli.
          ),
        tabBuilder: (context, index) {

          final willShowItem = TabItem.values[index];
        return CupertinoTabView(
          navigatorKey: navigatorsKey[willShowItem],
          builder: (context) {
            return pageBuilder[willShowItem];
          }
        );
      },
    );
  }

  BottomNavigationBarItem _createNavigationItem(TabItem tabItem) {
    final willCreateTab = TabItemData.allTabs[tabItem];
    return BottomNavigationBarItem(
      icon: Icon(willCreateTab.icon),
      title: Text(willCreateTab.title),
    );
  }
}
