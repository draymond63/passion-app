import 'package:flutter/material.dart';
import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/widgets/search/canvas.dart';
import 'package:PassionFruit/widgets/bookshelf/itemPreview.dart';

class Graph extends StatefulWidget {
  final List<List> map;
  final List<String> items;
  final String focusedSite;
  final bool isSearching;
  Graph(this.map, this.items, this.focusedSite, this.isSearching);
  @override
  _GraphState createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  final _zoomer = TransformationController();
  List<Point> points;
  Point userPoint;
  Size mapSize;
  double scale = 50;

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
    final userCoords = getUserCoords();
    userPoint = Point(userCoords.dx, userCoords.dy, 'You');
    // Center on the user's position
    // Future required for context
    Future.delayed(
      Duration(seconds: 0),
      () => focusCoords(userCoords, context),
    );
  }

  // Checks if dependencies change
  @override
  void didUpdateWidget(covariant Graph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusedSite == '')
      focusCoords(userPoint.offset, context);
    else
      focusSite(widget.focusedSite, context);
    // Check if the user has entered search mode
    if (widget.isSearching) hideItem();
  }

  @override
  void dispose() {
    _zoomer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reruns whenever user interacts
    return GestureDetector(
      onTapUp: (details) => clickItem(details.localPosition, context),
      // Lets paint use the mapSize even if it breaks constraints
      child: InteractiveViewer(
        transformationController: _zoomer,
        onInteractionStart: startPan,
        onInteractionEnd: endPan,
        maxScale: 200,
        minScale: 5,
        constrained: false, // Let painting take mapSize
        child: CustomPaint(
          painter: GraphPainter(
            points,
            userPoint,
            scale: scale,
          ),
          isComplex: true,
          willChange: false,
          size: mapSize,
        ),
      ),
    );
  }

  void startPan(_) => hideItem();

  void endPan(_) {
    // Set scale
    final _scale = _zoomer.value.getMaxScaleOnAxis();
    if (scale != _scale) setState(() => scale = _scale);
  }

  void focusSite(String site, BuildContext context) {
    final info = widget.map.singleWhere(
      (row) => row[MapCol.site.index] == site,
      orElse: () => throw Exception('site not found'),
    );
    final x = info[MapCol.x.index];
    final y = info[MapCol.y.index];
    focusCoords(Offset(x, y), context);
  }

  // Translates map coordinates to viewer coordinates
  void focusCoords(Offset coords, BuildContext context) {
    hideItem(); // Just in case any overlay is showing
    final screenSize = MediaQuery.of(context).size;
    // Reset position
    _zoomer.value = Matrix4.diagonal3Values(scale, scale, 1);
    // Move to coordinates
    setState(
      () => _zoomer.value.translate(
        -coords.dx + (screenSize.width / scale / 2),
        -coords.dy + (screenSize.height / scale / 2),
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

  Offset getUserCoords() {
    if (widget.items.length == 0) return mapSize.center(Offset.zero);
    final rows = widget.map
        .where((row) => widget.items.contains(row[MapCol.site.index]))
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

  // *** CLICK FUNCTIONS
  // Calculates which item was clicked
  clickItem(Offset clickCoords, BuildContext context) {
    // * Translate click to map coordinates
    // Convert screen to canvas/map coordinates
    Offset coords = _zoomer.toScene(clickCoords);
    coords = Offset(
      coords.dx.roundToDouble(),
      coords.dy.roundToDouble(),
    );
    // * Search for point in data (max ~ 14 milleseconds)
    // ! Clicks are too inprecise
    final info = widget.map.firstWhere(
      (row) =>
          row[MapCol.x.index].round() == coords.dx &&
          row[MapCol.y.index].round() == coords.dy,
      orElse: () => null,
    );
    if (info != null)
      displayItem(info[MapCol.site.index], clickCoords, context);
    else
      hideItem();
  }

  OverlayEntry itemPrompt;

  displayItem(String site, Offset coords, BuildContext context) {
    hideItem(); // Remove last item
    itemPrompt = OverlayEntry(
      builder: (context) => Positioned(
        left: coords.dx - 150, // Preview Item is 300 width
        top: coords.dy + 5,
        child: Material(child: PreviewItem(site)),
      ),
    );
    Overlay.of(context).insert(itemPrompt);
  }

  hideItem() {
    if (itemPrompt != null) itemPrompt.remove();
    itemPrompt = null;
  }
}
