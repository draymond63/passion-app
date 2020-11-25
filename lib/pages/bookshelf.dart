// import 'package:PassionFruit/wikipedia.dart';
import '../helpers/wikipedia.dart';
import 'package:flutter/material.dart';
import '../helpers/globals.dart';
import '../helpers/firebase.dart';

import '../widgets/item.dart';

class BookShelfPage extends StatelessWidget {
  final DBService db = DBService();

  @override
  Widget build(BuildContext context) {
    final user = db.getUser(context);

    return Scaffold(
        body: StreamBuilder(
            stream: db.getUserData(user),
            initialData: [],
            builder: (context, AsyncSnapshot snap) {
              User data = User();
              if (snap.data is User) data = snap.data;
              print('data: ' + data.toString());
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
        // scrollDirection: Axis.horizontal,
        children: List.generate(
            items.length,
            (i) => futureBuilder(
                fetchItemData(items[i]),
                (data) => Item.fromMap(
                      map: data,
                      height: 200.0,
                    ))));
  }
}
