import 'package:PassionFruit/widgets/itemView.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import '../helpers/globals.dart';

class PreviewItem extends StatefulWidget {
  final String name;
  const PreviewItem({this.name = ''});
  @override
  _PreviewItemState createState() => _PreviewItemState();
}

class _PreviewItemState extends State<PreviewItem> {
  Future<List> vitals = loadVitals();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        pushNewScreen(context,
            pageTransitionAnimation: PageTransitionAnimation.fade,
            screen: ViewItem(
              name: widget.name,
            ));
      },
      child: Container(
        width: 200,
        margin: EdgeInsets.all(4),
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
        child: Center(
          child: Column(children: [
            Center(child: Text(widget.name, style: ItemHeader)),
            buildPath()
          ]),
        ),
      ),
    );
  }

  Widget buildPath() {
    return FutureBuilder<List>(
        future: vitals,
        builder: (context, AsyncSnapshot<List> snap) {
          if (snap.hasData) {
            List row = snap.data
                .firstWhere((row) => row[VitCol.name.index] == widget.name);
            row = [
              row[VitCol.l0.index],
              row[VitCol.l1.index],
              row[VitCol.l2.index],
              row[VitCol.l3.index],
              row[VitCol.l4.index]
            ];
            row = row.toSet().toList();
            return Text(
              row.join(' -> '),
              softWrap: true,
            );
          }
          return Text('Loading');
        });
  }
}
