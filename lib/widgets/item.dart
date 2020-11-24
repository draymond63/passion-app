import 'package:flutter/material.dart';
import '../globals.dart';
// import 'package:cached_network_image/cached_network_image.dart';

class Item extends StatefulWidget {
  final String name;
  final String image; // url
  final String summary;
  final double width;
  Item({this.name, this.image = '', this.summary = '', this.width = 0.8});
  @override
  _ItemState createState() => _ItemState();

  factory Item.fromMap(Map json) {
    return Item(
        name: json['title'], summary: json['content'], image: json['image']);
  }
}

class _ItemState extends State<Item> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      child: Column(
        children: [
          Container(
              height: 256,
              child: SizedBox.expand(
                  child: Image.network(widget.image, fit: BoxFit.cover))),
          Text(widget.name, style: ItemHeader),
          Container(padding: EdgeInsets.all(8), child: Text(widget.summary))
        ],
      ),
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
