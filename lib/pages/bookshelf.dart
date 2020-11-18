import 'package:flutter/material.dart';
import '../globals.dart';

class BookShelfPage extends StatefulWidget {
  @override
  _BookShelfPageState createState() => _BookShelfPageState();
}

class _BookShelfPageState extends State<BookShelfPage> {
  bool _isList = true;
  _switchView() {
    setState(() => _isList = !_isList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isList ? BookShelfList() : Text('hi'),
      floatingActionButton: IconButton(
        onPressed: _switchView,
        tooltip: 'Switch view',
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

class BookShelfList extends StatelessWidget {
  // final List<String> _likedItems = ['1', '2', '3'];
  final List<String> entries = <String>['A', 'B', 'C'];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 50,
          child: Center(child: Text('Entry ${entries[index]}')),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
