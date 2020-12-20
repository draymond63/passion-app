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
  String centerSite = '';
  double scale = 1;
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    // Calculate user position
    final items = Provider.of<Storage>(context).items;
    final userCoords = getUserCoords(items, context);
    // ? Calculate borders around the graph
    // Calculate the plot data
    final points = getPlotData();
    points.add(Point(userCoords.dx, userCoords.dy));

    return InteractiveViewer(
      onInteractionUpdate: (details) => _scale = details.scale,
      onInteractionEnd: (_) => setState(() => scale *= _scale),
      maxScale: 100,
      minScale: 20,
      child: Center(
        child: CustomPaint(
          painter: GraphPainter(points, scale: scale),
          size: MediaQuery.of(context).size,
          isComplex: true,
          willChange: false,
        ),
      ),
    );
  }

  Offset getUserCoords(List<String> sites, BuildContext context) {
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
