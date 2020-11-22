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
  final inputController = TextEditingController();

  void swipe(DragEndDetails details) {
    if (details.primaryVelocity > 0)
      setState(() => showDetail = true);
    else if (details.primaryVelocity < 0) setState(() => showDetail = false);
    print("Velocity: ${details.primaryVelocity}");
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
        child: GestureDetector(
            child: Container(
                width: width,
                child: Column(children: [
                  ItemImage(widget.site),
                  Text(widget.site,
                      style: Theme.of(context).textTheme.headline1),
                  details(width)
                ])),
            onVerticalDragEnd: swipe));
  }

  // ! USE HERO WIDGET
  Widget details(double width) {
    if (!showDetail) return Text(inputController.text);

    return Container(
        width: width * 0.8,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          TextField(
              controller: inputController,
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
  ItemImage(this.site);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
        height: height / 2,
        child: futureBuilder(fetch('images/$site'),
            (data) => Image.network(data[0], width: width, fit: BoxFit.cover)));
  }
}
