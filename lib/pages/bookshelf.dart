import 'package:PassionFruit/wikipedia.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../globals.dart';
import '../firebase.dart';

import '../widgets/item.dart';

class BookShelfPage extends StatelessWidget {
  final DBService db = DBService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUser>(context);

    return Scaffold(
        body: StreamBuilder(
            stream: db.getUserData(user),
            initialData: [],
            builder: (context, AsyncSnapshot snap) {
              User data = User();
              if (snap.data is User) data = snap.data;
              // Show most recent
              return RecentItems(data.items);
            }));
  }
}

class RecentItems extends StatelessWidget {
  final List<String> items;
  RecentItems(this.items);

  @override
  Widget build(BuildContext context) {
    return ListView(
        scrollDirection: Axis.horizontal,
        children: List.generate(
            items.length,
            (i) => FutureBuilder(
                future: fetchItemData(items[i]),
                builder: (context, AsyncSnapshot snap) {
                  Map data = {'title': 'loading'};
                  if (snap.hasData) data = snap.data;
                  print(data);
                  return Item.fromMap(data);
                })));
  }
}
