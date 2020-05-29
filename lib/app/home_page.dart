import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_messaging_app/app/appointment_list_fragment_tab.dart';
import 'package:flutter_messaging_app/app/dashboard_tab.dart';
import 'package:flutter_messaging_app/app/landing_page.dart';
import 'package:flutter_messaging_app/app/my_conversation_tab.dart';
import 'package:flutter_messaging_app/app/my_custom_bottom_navi.dart';
import 'package:flutter_messaging_app/app/profile_tab.dart';
import 'package:flutter_messaging_app/app/tab_items.dart';
import 'package:flutter_messaging_app/app/users_tab.dart';
import 'package:flutter_messaging_app/common_widget/platform_sensetive_widget/platform_sensetive_alert_dialog.dart';
import 'package:flutter_messaging_app/model/user.dart';
import 'package:flutter_messaging_app/notification_handler.dart';
import 'package:flutter_messaging_app/view_model/all_users_view_model.dart';
import 'package:flutter_messaging_app/view_model/user_model.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final User user;

  HomePage({Key key, @required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  TabItem _currentTab = TabItem.Users;

  Map<TabItem, GlobalKey<NavigatorState>> navigatorsKeys = {
    TabItem.AppointmentListFragmentTab: GlobalKey<NavigatorState>(),
    TabItem.Dashboard: GlobalKey<NavigatorState>(),
    TabItem.Users: GlobalKey<NavigatorState>(),
    TabItem.MyChat: GlobalKey<NavigatorState>(),
    TabItem.Profile: GlobalKey<NavigatorState>(),
  }; //Burasını normalde MyCustomBottomNAvi sınıfında da yabilirdim ama sayfaların keylerini homepage'de tutmak daha mantıklı. 244.ders

  Map<TabItem, Widget> allTabs() {
    return {
      TabItem.AppointmentListFragmentTab: AppointmentListFragment(),
      TabItem.Dashboard: DashboardTab(),
      TabItem.Users: ChangeNotifierProvider(
        create: (context) => AllUsersViewModel(),
        child: UsersTab(),
      ),
      TabItem.MyChat: MyConversationTab(),
      TabItem.Profile: ProfileTab(),
    };
  } //Bu Map gerekli yönlendirmeleri yapacak yolları gösteriyor.

  @override
  void initState() {
    super.initState();
    // NotificationHandler().initializeFCMNotification(context);

    //Firebase Messaging Setup Configuration in Splash Screen
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      String title = message['notification']['title'];
      String body = message['notification']['body'];
      showNotification(title, body);
    }, onLaunch: (Map<String, dynamic> message) async {
      final notification = message['data'];
    }, onResume: (Map<String, dynamic> message) async {
      final notification = message['data'];
      setState(() {});
    });

    //Register Notification Settings for Android and iOS
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});

    //Local Notification Settings.
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onSelectNotification: onSelectNotification,
    );
  }

    //Show Notification
  showNotification(String title, String body) async {
    var android = new AndroidNotificationDetails(
        'channel Id', 'channel Name', 'channel Description');
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(0, title, body, platform);
  }

  Future onSelectNotification(String payload) {
    Navigator.pushReplacement(context,
        new MaterialPageRoute(builder: (context) {
      return LandingPage();
    }));
  }

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
