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
  PageController _controller;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    // Animate to page
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Widget build(BuildContext context) {
    return GestureDetector(
        child: PageView(
            controller: _controller,
            children: List<Widget>.generate(
                widget.items.length, (i) => Item(widget.items[i]))),
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
