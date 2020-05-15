import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/app/my_conversation_tab.dart';
import 'package:flutter_messaging_app/app/my_custom_bottom_navi.dart';
import 'package:flutter_messaging_app/app/profile_tab.dart';
import 'package:flutter_messaging_app/app/tab_items.dart';
import 'package:flutter_messaging_app/app/users_tab.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/view_model/user_model.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final User user;

  HomePage({Key key, @required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TabItem _currentTab = TabItem.Users;

  Map<TabItem, GlobalKey<NavigatorState>> navigatorsKeys = {
    TabItem.Users: GlobalKey<NavigatorState>(),
    TabItem.MyChat: GlobalKey<NavigatorState>(),
    TabItem.Profile: GlobalKey<NavigatorState>(),
  }; //Burasını normalde MyCustomBottomNAvi sınıfında da yabilirdim ama sayfaların keylerini homepage'de tutmak daha mantıklı. 244.ders

  Map<TabItem, Widget> allTabs() {
    return {
      TabItem.Users: UsersTab(),
      TabItem.MyChat: MyConversationTab(),
      TabItem.Profile: ProfileTab(),
    };
  } //Bu Map gerekli yönlendirmeleri yapacak yolları gösteriyor.

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !await navigatorsKeys[_currentTab]
          .currentState
          .maybePop(), //Bu kısmın amacı şu: andorid'de home page içinde stackler oluşturduğumuzu hayal et. Yani homepage içinde başka başka sayfalar açtık. Fakat açtığın en üstteki bu sayfadayken geri gel dediğin zaman direk çıkıyopr normalde. Bu sadece androidde oluyor çünkü donanım olarak geri gitme androiide var ios da yok . Onun içiin androidde geri gel dediğimiz zaman pop olması için yapıyoruz bunu.244. ders8.dakika
      child: MyCustomBottomNavigationBar(
        navigatorsKey: navigatorsKeys,
        pageBuilder: allTabs(),
        currentTab: _currentTab,
        onSelectedTab: (selectedTab) {
          // * ONSELECTEDTAB sayesinde navigasyon bardan gelen veriyi homepagede kullanabiliyorum.

          if (selectedTab == _currentTab) {
            navigatorsKeys[selectedTab].currentState.popUntil((route) => route
                .isFirst); //Bu kısım bir tabdayken tekrar aynı o taba basınca tabın içindeki tüm stackleri kapatıp o tabın ana sayfasına gelmesini sağlıyor.
          } else {
            setState(() {
              _currentTab =
                  selectedTab; //** selected tab'ı ilk başta users olarak belirlemiştik fakat artık bir tab seçildiğinde homepagede bunu da belirtmemiz gerek.
            });
          }

          debugPrint('Seçilen Tab Item: ' + selectedTab.toString());
        },
      ),
    );
  }

  Future<bool> _signOut(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    bool result = await _userModel.signOut();

    return result;
  }
}
