import 'package:flutter/material.dart';
import '../globals.dart';
import '../widgets/item.dart';
// import 'package:path_provider/path_provider.dart';

class BookShelfPage extends StatefulWidget {
  @override
  _BookShelfPageState createState() => _BookShelfPageState();
}

class _BookShelfPageState extends State<BookShelfPage> {
  // Future<String> get _localPath async {
  //   final directory = await getApplicationDocumentsDirectory();

  //   return directory.path;
  // }

  // For list vue
  bool _isList = true;
  _switchView() {
    setState(() => _isList = !_isList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isList ? BookShelfList() : BookShelfMain(),
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

class BookShelfMain extends StatefulWidget {
  @override
  _BookShelfMainState createState() => _BookShelfMainState();
}

class _BookShelfMainState extends State<BookShelfMain> {
  @override
  Widget build(BuildContext context) {
    return Item('LeBron James');
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
