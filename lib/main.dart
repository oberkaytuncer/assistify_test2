import 'package:flutter/material.dart';
import 'package:flutter_messaging_app/app/landing_page.dart';
import 'package:flutter_messaging_app/locator.dart';

import 'package:flutter_messaging_app/view_model/user_model.dart';
import 'package:provider/provider.dart';





void main() {
  setupLocator();
  runApp(
    ChangeNotifierProvider(
      create: (BuildContext context) => UserModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Assistify Coach',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: LandingPage(),
    );
  }
}


