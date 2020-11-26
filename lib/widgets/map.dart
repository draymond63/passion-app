import 'package:PassionFruit/helpers/globals.dart';
import 'package:flutter/material.dart';
import '../helpers/csv.dart';

class Map extends StatefulWidget {
  final double initX;
  final double initY;
  final int view;
  Map({this.initX, this.initY, this.view = 10});
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  CSV points = CSV();
  double width = 0;
  double height = 0;

  @override
  void initState() {
    loadVitals().then((data) => setState(() {
          points = CSV(data: data);
          width = points.getRange(MapCol.x);
          height = points.getRange(MapCol.y);
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(child: buildMap());
  }

  Widget buildMap() {
    return Container(
        padding: EdgeInsets.all(16),
        width: width,
        height: height,
        child: Stack(
            children: List<Widget>.generate(points.length, (i) {
          return MapPoint.fromCSV(points.loc(i));
        })));
  }
}

class MapPoint extends StatelessWidget {
  final String name;
  final String category;
  final double x;
  final double y;

  MapPoint({this.name, this.category, this.x, this.y});

  factory MapPoint.fromCSV(List data) {
    final tname = data[MapCol.name.index];
    final tcategory = data[MapCol.l0.index];
    final tx = data[MapCol.x.index];
    final ty = data[MapCol.y.index];
    return MapPoint(name: tname, category: tcategory, x: tx, y: ty);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(left: x, bottom: y, child: Container());
  }
}
