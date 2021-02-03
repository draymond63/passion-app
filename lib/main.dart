import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_analytics/observer.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/helpers/storage.dart';
import 'package:PassionFruit/helpers/wikipedia.dart';
import 'package:PassionFruit/widgets/navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderApp());
}

// Setup all datastreams
class ProviderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: readUserFile(), // ! THIS TAKES TOO LONG
      builder: (_, userfile) => FutureBuilder(
          future: Firebase.initializeApp(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                userfile.hasData) {
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
                      initialData: {},
                      lazy: false,
                    ),
                    // Wiki
                    Provider(create: (_) => Wiki()),
                  ],
                  // * SECONDARY PROVIDERS
                  child: MultiProvider(
                    providers: [
                      // Storage
                      ChangeNotifierProvider(
                        create: (context) => Storage.fromMap(userfile.data),
                      ),
                    ],
                    child: DataApp(),
                  ));
            } else
              // ! Replace with splash page
              return Material(
                child: Center(child: Image.asset('assets/fruit.png')),
              );
          }),
    );
  }
}

// Configures local data and theme data
class DataApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
