import 'package:flutter/material.dart';
import '../globals.dart';
import '../widgets/item.dart';

class BookShelfPage extends StatefulWidget {
  @override
  _BookShelfPageState createState() => _BookShelfPageState();
}

class _BookShelfPageState extends State<BookShelfPage> {
  final items = ['Basketball', 'LeBron James'];

  // For list vue
  bool _isList = true;
  _switchView() {
    setState(() => _isList = !_isList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isList ? BookShelfList(items) : BookShelfMain(items),
      floatingActionButton: IconButton(
        onPressed: _switchView,
        tooltip: 'Switch View',
        icon: Icon(
          _isList
              ? Icons.featured_play_list
              : Icons.featured_play_list_outlined,
          color: Color(MAIN_COLOR),
        ),
      ),
    );
  }
}

class BookShelfMain extends StatelessWidget {
  final items;
  BookShelfMain(this.items);

  List<Widget> constructedItems() {
    List<Widget> widgItems = [];
    for (final i in items) {
      widgItems.add(Item(i));
    }
    return widgItems;
  }

  Widget build(BuildContext context) {
    return ListView(
        scrollDirection: Axis.horizontal, children: constructedItems());
  }
}

class BookShelfList extends StatelessWidget {
  final items;
  BookShelfList(this.items);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 50,
          child: Center(child: Text(items[index])),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
