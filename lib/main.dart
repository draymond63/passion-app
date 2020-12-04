import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_analytics/observer.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

import './helpers/globals.dart';
import './helpers/firebase.dart';
import './helpers/wikipedia.dart';
import 'widgets/navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Setup all firebase datastreams
  runApp(MultiProvider(
      providers: [
        StreamProvider<FirebaseUser>.value(
          value: FirebaseAuth.instance.onAuthStateChanged,
        ),
        FutureProvider(
          create: (_) => loadVitals(),
          initialData: [List.generate(VitCol.values.length, (_) => '')],
          lazy: false,
        ),
        Provider(
          create: (context) => Wiki(),
        ),
      ],
      // Secondary providers that depend on the previous ones
      child: MultiProvider(providers: [
        StreamProvider(
          create: (context) => DBService().getUserData(context),
          initialData: User(),
        ),
      ], child: MyApp())));
}

class MyApp extends StatelessWidget {
  final db = DBService();

  void initUser() {
    // ! MOVE TO NEW USER PAGE
    writeUserFile({
      'settings': {
        'categories': {
          'People': true,
          'History': true,
          'Geography': true,
          'Arts': true,
          'Social Sciences': true,
          'Biology': true,
          'Physical Sciences': true,
          'Technology': true,
          'Mathematics': true,
        },
        'allow-random': true
      },
      // 'items': ['Basketball', 'LeBron James'],
      'preferences': {'list-view': true}
    });
  }

  @override
  Widget build(BuildContext context) {
    initUser();
    // If the user is not logged in, redirect to the login page
    final user = db.getUser(context);
    if (user == null) {
      db.login();
      return MaterialApp(
          home: Scaffold(
              body: Center(child: Text('Please wait', style: ItemSubtitle))));
    }

    return MaterialApp(
        title: 'PassionFruit',
        theme: ThemeData(
            primaryColor: Color(MAIN_COLOR),
            accentColor: Color(SECOND_ACCENT_COLOR),
            fontFamily: 'Roboto',
            textTheme: TextTheme(
              headline1: TextStyle(
                  fontSize: 36,
                  color: Color(MAIN_COLOR),
                  fontWeight: FontWeight.w500),
              headline2: TextStyle(
                  fontSize: 20,
                  color: Color(MAIN_COLOR),
                  fontWeight: FontWeight.w500),
              bodyText1: TextStyle(
                  fontSize: 14.0,
                  color: Color(TEXT_COLOR),
                  fontWeight: FontWeight.w300),
            )),
        home: PageRouter());
  }
}
