import 'package:flutter/material.dart';
import '../helpers/globals.dart';
import '../helpers/csv.dart';

class Graph extends StatefulWidget {
  final double initX;
  final double initY;
  final double scale;
  final void Function(double, double) updateViewer;
  Graph({this.initX, this.initY, this.scale = 1, this.updateViewer});
  @override
  _GraphState createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  CSV points = CSV.map();
  bool csvLoaded = false;
  double width = 0;
  double height = 0;
  // List<MapPoint> closest = [];

  @override
  initState() {
    points.addListener(() {
      setState(() => width = points.getRange(MapCol.x));
      setState(() => height = points.getRange(MapCol.y));
      widget.updateViewer(width, height);
      setState(() => csvLoaded = true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!csvLoaded) return Center(child: Text('Loading', style: ItemSubtitle));

    return Container(
        // padding: EdgeInsets.all(16),
        decoration:
            BoxDecoration(border: Border.all(color: Colors.grey, width: 1.0)),
        width: width,
        height: height,
        child: Stack(children: [
          ...List<Widget>.generate(
              points.length,
              (i) => MapPoint.fromCSV(
                  points.row(i), widget.scale, Offset(width / 2, height / 2))),
          Positioned(
            child: Text('YOU'),
            left: width / 2,
            bottom: height / 2,
          )
        ]));
  }
}

Map<String, Color> categoryColors = {
  'People': Colors.green,
  'History': Colors.blue,
  'Geography': Colors.yellow,
  'Arts': Colors.purple,
  'Social Sciences': Colors.red,
  'Biology': Colors.cyan,
  'Physical Sciences': Colors.amber,
  'Technology': Colors.orange,
  'Mathematics': Colors.indigo,
};

class MapPoint extends StatelessWidget {
  final String name;
  final String category;
  final double x;
  final double y;
  final Offset offset;
  final double scale;
  MapPoint({
    this.name,
    this.category,
    this.x,
    this.y,
    this.offset,
    this.scale,
  });

  factory MapPoint.fromCSV(List data, double scale, Offset center) {
    // ! TEMPORARY FIX for string type
    return MapPoint(
        name: data[MapCol.name.index].toString(),
        category: data[MapCol.l0.index].toString(),
        x: data[MapCol.x.index],
        y: data[MapCol.y.index],
        offset: center,
        scale: scale);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: (x + offset.dx),
        bottom: (y + offset.dy),
        child: GestureDetector(
          onTap: () => print(name),
          child: Column(
            children: [
              Container(
                  width: 20 / scale,
                  height: 20 / scale,
                  decoration: BoxDecoration(
                      color: categoryColors[category], shape: BoxShape.circle)),
              // Text(name, style: TextStyle(fontSize: 10 / viewScale))
            ],
          ),
        )); // Icon(Icons.circle)
  }
}
