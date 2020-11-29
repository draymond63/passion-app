import 'package:flutter/material.dart';
import '../helpers/globals.dart';
import '../helpers/csv.dart';

class Graph extends StatefulWidget {
  final double initX;
  final double initY;
  final int scale;
  Graph({this.initX, this.initY, this.scale = 2});
  @override
  _GraphState createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  final _zoomer = TransformationController(Matrix4.diagonal3Values(1, 1, 1));
  CSV points = CSV.map();
  bool csvLoaded = false;
  double width = 0;
  double height = 0;
  // List<MapPoint> closest = [];

  @override
  initState() {
    points.addListener(() => setState(() => csvLoaded = true));
    super.initState();
  }

  getRange() {
    setState(() => width = points.getRange(MapCol.x) * widget.scale);
    setState(() => height = points.getRange(MapCol.y) * widget.scale);
    _zoomer.toScene(Offset(width / 2, height / 2));
  }

  @override
  Widget build(BuildContext context) {
    if (!csvLoaded) return Center(child: Text('Loading', style: ItemSubtitle));
    if (width == 0) getRange();

    return InteractiveViewer(
        transformationController: _zoomer, child: buildMap());
  }

  Widget buildMap() {
    return Container(
        padding: EdgeInsets.all(16),
        decoration:
            BoxDecoration(border: Border.all(color: Colors.grey, width: 1.0)),
        width: width * widget.scale,
        height: height * widget.scale,
        child: points.isLoaded
            ? Stack(
                children: List<Widget>.generate(
                    points.length,
                    (i) => MapPoint.fromCSV(points.row(i), widget.scale,
                        Offset(width / 2, height / 2))))
            : Text('Loading'));
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
  final int scale;
  MapPoint({
    this.name,
    this.category,
    this.x,
    this.y,
    this.offset,
    this.scale,
  });

  factory MapPoint.fromCSV(List data, int scale, Offset center) {
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
        left: (x + offset.dx) * scale,
        bottom: (y + offset.dy) * scale,
        child: Column(
          children: [
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: categoryColors[category], shape: BoxShape.circle)),
            // Text(name, style: TextStyle(fontSize: 10 / viewScale))
          ],
        )); // Icon(Icons.circle)
  }
}
