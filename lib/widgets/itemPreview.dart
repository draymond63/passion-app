import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:PassionFruit/widgets/itemView.dart';
import '../helpers/globals.dart';

class PreviewItem extends StatefulWidget {
  final String site;
  const PreviewItem(this.site);
  @override
  _PreviewItemState createState() => _PreviewItemState();
}

class _PreviewItemState extends State<PreviewItem> {
  Future<List> vitals = loadVitals(); // ! CHANGE TO GLOBAL LOAD

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        pushNewScreen(context,
            withNavBar: false,
            pageTransitionAnimation: PageTransitionAnimation.fade,
            screen: ViewItem(widget.site));
      },
      child: Container(
        width: 300,
        margin: EdgeInsets.all(16),
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
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          FittedBox(child: buildTitle()),
          FittedBox(child: buildPath())
        ]),
      ),
    );
  }

  Widget buildTitle() {
    return FutureBuilder(
        future: vitals,
        builder: (_, snap) {
          if (snap.hasData) {
            List row = snap.data
                .firstWhere((row) => row[VitCol.site.index] == widget.site);
            return Text(row[VitCol.name.index], style: ItemHeader);
          }
          return Text('Loading', style: ItemHeader);
        });
  }

  Widget buildPath() {
    return FutureBuilder<List>(
        future: vitals,
        builder: (context, AsyncSnapshot<List> snap) {
          if (snap.hasData) {
            List row = snap.data
                .firstWhere((row) => row[VitCol.site.index] == widget.site);
            row = [
              row[VitCol.l0.index].replaceAll('_', ' '),
              row[VitCol.l1.index].replaceAll('_', ' '),
              row[VitCol.l2.index].replaceAll('_', ' '),
              row[VitCol.l3.index].replaceAll('_', ' '),
              row[VitCol.l4.index].replaceAll('_', ' ')
            ];
            row = row.toSet().toList(); // Remove duplicates
            return Text(row.join(' -> '));
          }
          return Text('Loading');
        });
  }
}