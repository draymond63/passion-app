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
  final _inputController = TextEditingController();

  void swipe(DragEndDetails details, double height) {
    if (details.primaryVelocity > 0) {
      setState(() => showDetail = true);
    } else if (details.primaryVelocity < 0) {
      setState(() => showDetail = false);
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
        child: Column(children: [
          ItemImage(widget.site, !showDetail),
          Text(widget.site, style: Theme.of(context).textTheme.headline1),
          details(width, height)
        ]),
        onVerticalDragEnd: (d) => swipe(d, height));
  }

  // ! USE HERO WIDGET
  Widget details(double width, double height) {
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
