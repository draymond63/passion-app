import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:PassionFruit/widgets/feed/itemView.dart';
import 'package:PassionFruit/helpers/globals.dart';

class PreviewItem extends StatefulWidget {
  final String site;
  final double width;
  final Function() onClick;
  const PreviewItem(this.site, {this.width = 300, this.onClick});
  @override
  _PreviewItemState createState() => _PreviewItemState();
}

class _PreviewItemState extends State<PreviewItem> {
  @override
  Widget build(BuildContext context) {
    final vitals = Provider.of<Map>(context);
    final info = vitals[widget.site] ?? {};

    if (info.length != VitCol.length) return Container(width: 0);

    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: widget.width,
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          boxShadow: boxShadow,
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        // * ITEMS
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(child: Text(info['name'], style: ItemHeader)),
            FittedBox(child: buildPath(info))
          ],
        ),
      ),
    );
  }

  Widget buildPath(Map info) {
    List<String> row = [
      info['l0'].replaceAll('_', ' '),
      info['l1'].replaceAll('_', ' '),
      info['l2'].replaceAll('_', ' '),
      info['l3'].replaceAll('_', ' '),
      info['l4'].replaceAll('_', ' ')
    ];
    row = row.toSet().toList(); // Remove duplicates
    return Text(row.join(' -> '));
  }

  void onClick() {
    if (widget.onClick == null)
      pushNewScreen(
        context,
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.fade,
        screen: ViewItem(widget.site),
      );
    else
      widget.onClick(); // Override click if set
  }
}
