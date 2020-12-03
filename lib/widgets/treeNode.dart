import 'package:PassionFruit/helpers/globals.dart';
import 'package:flutter/material.dart';

class TreeNode extends StatelessWidget {
  final String site;
  TreeNode(this.site);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Color(0xFFDDDDDD),
                spreadRadius: 1,
                offset: Offset(2, 2),
                blurRadius: 2)
          ],
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Row(
        children: [
          Text(site.replaceAll('_', ' '), style: ItemSubtitle),
          Flexible(child: Container()), // Right align arrow
          Icon(Icons.arrow_right_rounded),
        ],
      ),
    );
  }
}
