import 'package:flutter/material.dart';
import '../globals.dart';
import '../widgets/item.dart';

class BookShelfPage extends StatefulWidget {
  @override
  _BookShelfPageState createState() => _BookShelfPageState();
}

class _BookShelfPageState extends State<BookShelfPage> {
  List items = [];
  bool _isList = true;

  @override
  _BookShelfPageState() : super() {
    readUserFile().then((data) {
      setState(() => items = data['items']);
      setState(() => _isList = data['preferences']['list-view']);
    });
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

class BookShelfMain extends StatefulWidget {
  final items;
  BookShelfMain(this.items);
  // Swipe animation duration
  final duration = Duration(seconds: 1);
  @override
  _BookShelfMainState createState() => _BookShelfMainState();
}

class _BookShelfMainState extends State<BookShelfMain> {
  List<Widget> itemWidgets = <Widget>[];
  int index = 0;
  double _shift = 0; // How far along the

  _BookShelfMainState() {
    itemWidgets = List<Widget>.generate(
        widget.items.length, (i) => Item(widget.items[i]));
  }

  tap(TapUpDetails details, context) {
    final division = MediaQuery.of(context).size.width / 2;
    // Move item in view
    if (details.globalPosition.dx > division)
      setState(() => index++);
    else
      setState(() => index--);
    // Edge cases
    if (index >= widget.items.length)
      setState(() => index = widget.items.length - 1);
    else if (index < 0) setState(() => index = 0);

    setState(() => _shift = index * division * 2);
  }

  Widget build(BuildContext context) {
    return GestureDetector(
        child: TweenAnimationBuilder(
            child: ListView(
                children: itemWidgets,
                physics: const NeverScrollableScrollPhysics()),
            // Animation tracking
            duration: widget.duration,
            tween: Tween(begin: 0, end: _shift),
            builder: (context, offset, child) {
              return Transform.translate(
                offset: Offset(_shift, 0),
                child: child,
              );
            }),
        onTapUp: (d) => tap(d, context));
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
