import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/helpers/storage.dart';
import 'package:PassionFruit/helpers/csv.dart';
// import 'package:PassionFruit/widgets/feed/itemView.dart';

class Graph extends StatefulWidget {
  final CSV map;
  Graph(this.map);
  @override
  _GraphState createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  String centerSite = '';
  double scale = 1;
  double _scale = 1;

  updateHiddenScale(ScaleUpdateDetails details) {
    _scale = details.scale;
    print(_scale);
  }

  updateScale(_) => setState(() => scale *= _scale);

  clickItem(ScatterTouchResponse response) {
    // print(response.touchInput);
    // final index = response.touchedSpotIndex;
    // if (index != -1) {
    //   print(widget.map.iRow(index)[MapCol.site.index]);
    // }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate user position
    final items = Provider.of<Storage>(context).items;
    final userCoords = getUserCoords(items, context);
    // ? Calculate borders around the graph
    // Calculate the plot data
    final points = getPlotData();
    points.add(ScatterSpot(userCoords.dx, userCoords.dy, radius: 1));

    return InteractiveViewer(
      onInteractionUpdate: updateHiddenScale,
      onInteractionEnd: updateScale,
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: points,
          // axisTitleData: FlAxisTitleData(show: false),
          borderData: FlBorderData(show: false),
          scatterTouchData: ScatterTouchData(touchCallback: clickItem),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  Offset getUserCoords(List<String> sites, BuildContext context) {
    final rows = widget.map.rows(sites, MapCol.site);
    double x =
        rows.map((row) => row[MapCol.x.index]).reduce((acc, x) => acc + x);
    double y =
        rows.map((row) => row[MapCol.y.index]).reduce((acc, y) => acc + y);
    x /= rows.length;
    y /= rows.length;
    return Offset(x, y);
  }

  List<ScatterSpot> getPlotData() {
    return List<ScatterSpot>.generate(widget.map.length, (i) {
      final info = widget.map.iRow(i);
      return ScatterSpot(info[MapCol.x.index], info[MapCol.y.index],
          color: categoryColors[info[MapCol.l0.index]], radius: 0.3);
    });
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
