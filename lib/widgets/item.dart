import 'package:flutter/material.dart';
import '../helpers/globals.dart';

// For the like button
import '../helpers/firebase.dart';
// import 'package:cached_network_image/cached_network_image.dart';

class Item extends StatefulWidget {
  final String name;
  final Image image;
  final String content;
  final double width; // Fraction of viewport
  final double height; // image height
  const Item(
      {this.name,
      this.image,
      this.content = '',
      this.width = 0.8,
      this.height = 256});
  @override
  _ItemState createState() => _ItemState();

  factory Item.fromMap({Map map, width = 0.8, height = 256.0}) {
    return Item(
        name: map['name'],
        content: map['content'],
        image: map['image'],
        width: width,
        height: height);
  }
}

class _ItemState extends State<Item> with AutomaticKeepAliveClientMixin<Item> {
  final db = DBService();
  bool isOpen = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // For keepAlive
    final width = MediaQuery.of(context).size.width;
    final user = db.getUser(context);

    return Container(
      child: Column(children: [
        // * IMAGE
        GestureDetector(
          // ? Move conditional inside the contrained box to maintain size ?
          child: widget.image != null
              ? ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: widget.height),
                  child: SizedBox.expand(child: widget.image))
              : Container(),
          onTap: () => setState(() => isOpen = !isOpen),
        ),
        // * TEXT
        Text(widget.name, style: ItemHeader),
        Container(
            padding: EdgeInsets.all(8),
            child:
                Text(isOpen ? widget.content : widget.content.split('.')[0])),
        // * BUTTONS
        Center(
          child: Row(children: [
            IconButton(
                icon: Icon(Icons.thumb_up_rounded),
                color: Color(0xFFAAAAAA),
                onPressed: () => db.writeItem(user, widget.name))
          ]),
        ),
      ]),
      width: width * widget.width,
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Color(0xFFDDDDDD),
                spreadRadius: 1,
                offset: Offset(2, 2),
                blurRadius: 2)
          ],
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16))),
    );
  }
}
