import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../globals.dart';
import '../firebase.dart';

import '../widgets/item.dart';

class BookShelfPage extends StatefulWidget {
  @override
  _BookShelfPageState createState() => _BookShelfPageState();
}

class _BookShelfPageState extends State<BookShelfPage> {
  bool _isList = true;
  final DBService db = DBService();

  @override
  _BookShelfPageState() : super() {
    readUserFile().then(
        (data) => setState(() => _isList = data['preferences']['list-view']));
  }

  // For list vue
  void _switchView() {
    setState(() => _isList = !_isList);
    // Save preference
    editUserFile((data) {
      data['preferences']['list-view'] = _isList;
    });
  }

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
            print(data.items);
            // Return one of the formats
            return _isList
                ? BookShelfList(data.items)
                : BookShelfMain(data.items);
          }),
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
  final List items;
  BookShelfMain(this.items);
  // Swipe animation duration
  final duration = Duration(seconds: 1);
  @override
  _BookShelfMainState createState() => _BookShelfMainState();
}

class _BookShelfMainState extends State<BookShelfMain> {
  // final PageController pageController = PageController(viewportFraction: 0.8);
  Widget build(BuildContext context) {
    return PageView(
        // controller: pageController,
        children: List<Widget>.generate(
            widget.items.length, (i) => Item(widget.items[i])));
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
