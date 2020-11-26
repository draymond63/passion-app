import 'package:flutter/material.dart';

import '../helpers/wikipedia.dart';
import '../helpers/globals.dart';
import '../helpers/firebase.dart';
import '../widgets/item.dart';

class BookShelfPage extends StatelessWidget {
  final db = DBService();
  final wiki = Wiki();

  BookShelfPage() {
    print("CREATING BOOKSHELF");
  }

  @override
  Widget build(BuildContext context) {
    final user = db.getUser(context);
    // final wiki = context.watch<Wiki>();

    return Scaffold(
        body: StreamBuilder(
            stream: db.getUserData(user),
            initialData: [],
            builder: (context, AsyncSnapshot snap) {
              User data = User();
              if (snap.data is User) data = snap.data;
              // Show most recent
              return buildRecentItem(data.items);
            }));
  }

  Widget buildRecentItem(List<String> items) {
    return ListView(
        // scrollDirection: Axis.horizontal,
        children: List.generate(
            items.length,
            (i) => futureBuilder(
                wiki.fetchItem(items[i]),
                (data) => Item.fromMap(
                      map: data,
                      height: 200.0,
                    ))));
  }
}
