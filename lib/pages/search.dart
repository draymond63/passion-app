import 'package:flutter/material.dart';
// import 'package:charts_flutter/flutter.dart' as chart;
// import '../helpers/globals.dart';
import '../widgets/map.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

final double _initScale = 10;

class _SearchPageState extends State<SearchPage> {
  final _zoomer = TransformationController();
  double scale = _initScale;

  // Set initial zoom and translation (!translation not working)
  void center(double x, double y) {
    // ! NOT FULLY CENTERING
    _zoomer.value = Matrix4.translationValues(-x / 2 - 200, -y / 2, 1) *
        Matrix4.diagonal3Values(_initScale, _initScale, 1);
  }

  setScale(_) {
    final _scale = _zoomer.value.getMaxScaleOnAxis();
    setState(() => scale = _scale);
  }

  @override
  void dispose() {
    _zoomer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildSearchBar(),
        // Improves render efficiencQy
        body: ClipRect(
          clipBehavior: Clip.hardEdge,
          child: InteractiveViewer(
              maxScale: 20,
              minScale: 1,
              constrained: false,
              transformationController: _zoomer,
              onInteractionEnd: setScale,
              // Graph
              child: Graph(
                scale: scale,
                updateViewer: center,
              )),
        ));
  }

  // * SEARCH BAR
  Widget buildSearchBar() {
    return AppBar(
      title: TextField(
          decoration:
              InputDecoration(border: InputBorder.none, hintText: 'Search...')),
      leadingWidth: 0,
      toolbarHeight: 45,
      toolbarOpacity: 0.1,
      backgroundColor: Color(0xFFF2F2F2),
      shadowColor: Color(0xFF888888),
      actions: [
        Icon(
          Icons.search,
          color: Colors.grey,
        )
      ],
    );
  }
}
