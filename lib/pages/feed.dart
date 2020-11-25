import 'package:flutter/material.dart';
import '../widgets/item.dart';
import '../wikipedia.dart';

class FeedPage extends StatefulWidget {
  final buffer = 10; // How many items to preload
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<Item> items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Feed'),
          actions: [IconButton(icon: Icon(Icons.settings), onPressed: () {})],
        ),
        body: ListView.builder(itemBuilder: (BuildContext context, i) {
          if (i >= items.length - widget.buffer) {
            fetchItemData('Basketball').then(
                (json) => setState(() => items.add(Item.fromMap(map: json))));

            return Item(name: 'Loading');
          }
          return items[i];
        }));
  }
}
