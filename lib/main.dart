import 'package:PassionFruit/helpers/storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  runApp(ProviderApp());
}

// Setup all firebase datastreams
class ProviderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // * PROVIDERS
            return MultiProvider(
                providers: [
                  // User
                  StreamProvider<User>.value(
                    value: FirebaseAuth.instance.authStateChanges(),
                  ),
                  // List<List>
                  FutureProvider(
                    create: (_) => loadVitals(),
                    initialData: [
                      List.generate(VitCol.values.length, (_) => '')
                    ],
                    lazy: false,
                  ),
                  // Map
                  FutureProvider(
                    create: (_) => readUserFile(),
                    initialData: {},
                  ),
                  // Wiki
                  Provider(create: (_) => Wiki()),
                ],
                // * SECONDARY PROVIDERS
                child: MultiProvider(
                  providers: [
                    // UserDoc
                    StreamProvider(
                      create: (context) => DBService().getUserData(context),
                      initialData: UserDoc(),
                    ),
                    // Storage
                    ChangeNotifierProvider(
                        create: (context) => Storage.fromFile(context)),
                  ],
                  child: DataApp(),
                ));
          } else
            return LoadingWidget;
        });
  }
}

// Configures local data and theme data
class DataApp extends StatelessWidget {
  final db = DBService();

  @override
  Widget build(BuildContext context) {
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
