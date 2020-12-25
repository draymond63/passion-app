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
  Map info = {};

  @override
  Widget build(BuildContext context) {
    final vitals = Provider.of<Map>(context);
    setState(() => info = vitals[widget.site] ?? {});

    return GestureDetector(
      onTap: () => widget.onClick == null
          ? pushNewScreen(context,
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.fade,
              screen: ViewItem(widget.site))
          : widget.onClick(),
      child: Container(
        width: widget.width,
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(8),
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
        // * ITEMS
        child: info.length == VitCol.length
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                FittedBox(child: Text(info['name'], style: ItemHeader)),
                FittedBox(child: buildPath())
              ])
            : LoadingWidget,
      ),
    );
  }

  Widget buildPath() {
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
}
