import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:PassionFruit/widgets/feed/itemView.dart';
import '../../helpers/globals.dart';

class PreviewItem extends StatefulWidget {
  final String site;
  const PreviewItem(this.site);
  @override
  _PreviewItemState createState() => _PreviewItemState();
}

class _PreviewItemState extends State<PreviewItem> {
  List info = [];

  @override
  Widget build(BuildContext context) {
    final vitals = Provider.of<List<List>>(context);
    setState(() => info = vitals.firstWhere(
          (row) => row[VitCol.site.index] == widget.site,
          orElse: () => <String>[],
        ));

    return GestureDetector(
      onTap: () {
        pushNewScreen(context,
            withNavBar: false,
            pageTransitionAnimation: PageTransitionAnimation.fade,
            screen: ViewItem(widget.site));
      },
      child: Container(
        width: 300,
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
        child: info.length == VitCol.values.length
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                FittedBox(
                    child: Text(info[VitCol.name.index], style: ItemHeader)),
                FittedBox(child: buildPath())
              ])
            : LoadingWidget,
      ),
    );
  }

  Widget buildPath() {
    List<String> row = [
      info[VitCol.l0.index].replaceAll('_', ' '),
      info[VitCol.l1.index].replaceAll('_', ' '),
      info[VitCol.l2.index].replaceAll('_', ' '),
      info[VitCol.l3.index].replaceAll('_', ' '),
      info[VitCol.l4.index].replaceAll('_', ' ')
    ];
    row = row.toSet().toList(); // Remove duplicates
    return Text(row.join(' -> '));
  }
}
