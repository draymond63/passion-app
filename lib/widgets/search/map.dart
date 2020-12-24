import 'package:PassionFruit/widgets/search/canvas.dart';
import 'package:flutter/material.dart';
import 'package:PassionFruit/helpers/globals.dart';
// import 'package:PassionFruit/widgets/feed/itemView.dart';

class Graph extends StatefulWidget {
  final List<List> map;
  final List<String> items;
  Graph(this.map, this.items);
  @override
  _GraphState createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  final _zoomer = TransformationController();
  List<Point> points;
  Size mapSize;
  Size canvasSize;
  Offset userCoords;
  double scale = 20;

  /* Type   | Dim | Scale | Size   | Translate | Ratio 
   * screen | w   | 10    | 411.4  | 41        | 10.03
   * screen | h   | 10    | 845.7  | 72        | 11.74
   * map    | w   | 10    | 1307.2 | 411       | 3.18
   * map    | h   | 10    | 1230.0 | 720       | 1.71
   * screen | w   | 15    | 411.4  | 27.3      | 15.07
   * screen | h   | 15    | 845.7  | 48        | 17.62
   * map    | w   | 15    | 1307.2 | 438       | 2.98
   * map    | h   | 15    | 1230.0 | 768       | 1.6
   */

  @override
  void initState() {
    super.initState();
    // Only needs to run once
    points = getPlotData();
    mapSize = getMapSize();
    // Add the user
    userCoords = getUserCoords(widget.items);
    points.add(Point(userCoords.dx, userCoords.dy, 'You'));
    // Center on the user's position
    Future.delayed(
        Duration(seconds: 0), () => focusCoords(userCoords, context));
  }

  @override
  void dispose() {
    _zoomer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reruns whenever user interacts
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.home),
        onPressed: () => focusCoords(userCoords, context),
      ),
      body: InteractiveViewer(
        transformationController: _zoomer,
        onInteractionEnd: (_) => setState(
          () => scale = _zoomer.value.getMaxScaleOnAxis(),
        ),
        maxScale: 75,
        minScale: 5,
        child: CustomPaint(
          painter: GraphPainter(
            points,
            mapSize, // ! THIS COULD PROBABLY BE BETTER
            setCanvasSize, // ! ~
            scale: scale,
          ),
          isComplex: true,
          willChange: false,
          size: mapSize,
        ),
      ),
    );
  }

  // ? Make this less sloppy ?
  void setCanvasSize(Size size) => canvasSize = size;

  void focusSite(String site, BuildContext context) {
    final info = widget.map.firstWhere((row) => row[MapCol.site.index]);
    final x = info[MapCol.x.index];
    final y = info[MapCol.y.index];
    focusCoords(Offset(x, y), context);
  }

  // Translates map coordinates to viewer coordinates
  // ! Assumes starting in the top left
  void focusCoords(Offset coords, BuildContext context) {
    assert(canvasSize != null);
    final xScale = canvasSize.width / mapSize.width;
    final yScale = canvasSize.height / mapSize.height;
    final screenSize = MediaQuery.of(context).size;
    // Reset position
    _zoomer.value = Matrix4.diagonal3Values(scale, scale, 1);
    // Move to coordinates
    setState(
      () => _zoomer.value.translate(
        -coords.dx * xScale + (screenSize.width / scale / 2),
        -coords.dy * yScale + (screenSize.height / scale / 2),
      ),
    );
  }

  Size getMapSize() {
    // Data starts at 0, 0 - we don't need to keep track of mins
    double xMax = widget.map[0][MapCol.x.index];
    double yMax = widget.map[0][MapCol.y.index];
    widget.map.forEach((row) {
      final xNew = row[MapCol.x.index];
      final yNew = row[MapCol.y.index];
      if (xNew > xMax) xMax = xNew;
      if (yNew > yMax) yMax = yNew;
    });
    return Size(xMax, yMax);
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
        info[MapCol.site.index].toString(),
        color: categoryColors[info[MapCol.l0.index]],
      );
    });
  }
}