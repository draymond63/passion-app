import 'package:PassionFruit/widgets/search/canvas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/helpers/storage.dart';
// import 'package:PassionFruit/widgets/feed/itemView.dart';

class Graph extends StatefulWidget {
  final List<List> map;
  Graph(this.map);
  @override
  _GraphState createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  final _zoomer = TransformationController();
  List<Point> points;
  Size mapSize;
  double scale = 10;

  @override
  void initState() {
    super.initState();
    // Only needs to run once
    points = getPlotData();
    mapSize = getMapSize();
    // Viewer config
    _zoomer.value.scale(scale, scale);
    // Requires context
    Future.delayed(Duration(seconds: 0), () {
      final items = Provider.of<Storage>(context, listen: false).items;
      final userCoords = getUserCoords(items);
      // Calculate the plot data
      points.add(Point(userCoords.dx, userCoords.dy));
      // Center on the user's position
      focusMapOn(userCoords, context);
      setState(() {}); // Update UI
    });
  }

  @override
  void dispose() {
    _zoomer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reruns whenever user interacts
    return InteractiveViewer(
      transformationController: _zoomer,
      onInteractionEnd: (_) => setState(
        () => scale = _zoomer.value.getMaxScaleOnAxis(),
      ),
      scaleEnabled: false,
      // maxScale: 100,
      // minScale: 1,
      child: Center(
        child: CustomPaint(
          painter: GraphPainter(points, scale: scale),
          size: mapSize,
          isComplex: true,
          willChange: false,
        ),
      ),
    );
  }

  void focusMapOn(Offset coords, BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    _zoomer.value.translate(
      coords.dx * scale - screenSize.width / 2,
      coords.dy * scale - screenSize.height / 2,
    );
  }

  Size getMapSize() {
    double xMin = widget.map[0][MapCol.x.index];
    double xMax = xMin;
    double yMin = widget.map[0][MapCol.y.index];
    double yMax = yMin;
    widget.map.forEach((row) {
      final xNew = row[MapCol.x.index];
      final yNew = row[MapCol.y.index];
      if (xNew > xMax)
        xMax = xNew;
      else if (xNew < xMin) xMin = xNew;
      if (yNew > yMax)
        yMax = yNew;
      else if (yNew < yMin) yMin = yNew;
    });
    return Size(xMax - xMin + 50, yMax - yMin + 50);
  }

  Offset getUserCoords(List<String> sites) {
    final rows = widget.map
        .where((row) => sites.contains(row[MapCol.site.index]))
        .toList();
    double x =
        rows.map((row) => row[MapCol.x.index]).reduce((acc, x) => acc + x);
    double y =
        rows.map((row) => row[MapCol.y.index]).reduce((acc, y) => acc + y);
    x /= rows.length;
    y /= rows.length;
    return Offset(x, y);
  }

  List<Point> getPlotData() {
    return List<Point>.generate(widget.map.length, (i) {
      final info = widget.map[i];
      return Point(
        info[MapCol.x.index],
        info[MapCol.y.index],
        color: categoryColors[info[MapCol.l0.index]],
      );
    });
  }
}
