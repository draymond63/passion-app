import 'package:flutter/material.dart';
import '../globals.dart';
// import 'package:cached_network_image/cached_network_image.dart';

class Item extends StatefulWidget {
  final String site;
  Item(this.site);
  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> {
  bool showDetail = false;
  final _scroller = ScrollController();
  final _inputController = TextEditingController();

  @override
  void initState() {
    _scroller.addListener(swipe);
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _scroller.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void swipe() {
    // if (_scroller.position.isScrollingNotifier.value) {
    //   setState(() => showDetail = true);
    // }
    if (_scroller.offset <= _scroller.position.minScrollExtent)
      setState(() => showDetail = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: ListView(
            controller: _scroller,
            physics: showDetail
                ? AlwaysScrollableScrollPhysics()
                : NeverScrollableScrollPhysics(),
            children: [
              ItemImage(widget.site, !showDetail),
              Text(widget.site, style: Theme.of(context).textTheme.headline1),
              details()
            ]),
        onTap: () => setState(() => showDetail = true));
  }

  Widget details() {
    return AnimatedOpacity(
        opacity: showDetail ? 1 : 0,
        duration: Duration(milliseconds: 200),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          TextField(
              controller: _inputController,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Enter notes here')),
          Text('Suggested Lessons',
              style: Theme.of(context).textTheme.headline2),
          Text('Related Topics', style: Theme.of(context).textTheme.headline2),
          Text(
              '\n\n\n\n\n\n\n\n\n\n\n\nhi\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nhi')
        ]));
  }
}

class ItemImage extends StatelessWidget {
  final String site;
  final bool showImage;
  ItemImage(this.site, this.showImage);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: showImage ? (height / 2) : 0,
        child: futureBuilder(fetch('images/$site'),
            (data) => Image.network(data[0], width: width, fit: BoxFit.cover)));
  }
}
