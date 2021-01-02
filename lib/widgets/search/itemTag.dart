import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemTag extends StatelessWidget {
  const ItemTag({
    Key key,
    @required this.site,
    @required this.scale,
    this.visible = true,
  }) : super(key: key);

  final String site;
  final double scale;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final vitals = Provider.of<Map>(context);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      opacity: visible ? 0.9 : 0,
      child: Container(
        padding: EdgeInsets.all(5 / scale),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1 / scale),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(64),
              bottomRight: Radius.circular(64),
              topRight: Radius.circular(64)),
        ),
        child: Text(
          vitals[site]['name'],
          textScaleFactor: 1 / scale,
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }
}
