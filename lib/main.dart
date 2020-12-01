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
import './widgets/navbar.dart';

import './pages/feed.dart';
// import './pages/settings.dart';
import './pages/bookshelf.dart';
import './pages/search.dart';
// import './pages/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Setup all firebase datastreams
  runApp(MultiProvider(providers: [
    StreamProvider<FirebaseUser>.value(
        value: FirebaseAuth.instance.onAuthStateChanged),
    // StreamProvider(create: (context) => DBService().getUserData(context)),
    Provider.value(value: Wiki())
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
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
        home: Page());
  }
}

class Page extends StatefulWidget {
  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  final db = DBService();
  int _pageIndex = 0;

  final _pages = <Widget>[
    FeedPage(),
    BookShelfPage(),
    SearchPage(),
  ];

  changePage(int i) => setState(() => _pageIndex = i);

  @override
  Widget build(BuildContext context) {
    // If the user is not logged in, redirect to the login page
    final user = db.getUser(context);
    if (user == null) {
      db.login();
      return Scaffold(
          body: Center(child: Text('Please wait', style: ItemSubtitle)));
    }

    return Scaffold(
        // * PAGE
        // Indexed stack used to save page state
        body: SafeArea(
          child: AnimatedSwitcher(
              transitionBuilder: AnimatedSwitcher.defaultTransitionBuilder,
              duration: const Duration(milliseconds: 500),
              child: IndexedStack(
                  children: _pages,
                  // This key causes the AnimatedSwitcher to interpret this as new
                  key: ValueKey<int>(_pageIndex),
                  index: _pageIndex)),
        ),
        // * NAV BAR
        bottomNavigationBar: NavBar(_pageIndex, changePage));
  }
}
