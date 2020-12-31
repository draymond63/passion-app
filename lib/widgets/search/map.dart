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

  // Graph constants
  final userRadius = 17.5;

  @override
  _GraphState createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  final _zoomer = TransformationController();
  List<Point> points;
  Point userPoint;
  Size mapSize;
  double scale = 50;

  @override
  void initState() {
    super.initState();
    // Only needs to run once
    points = getPlotData();
    mapSize = getMapSize();
    // Add the user
    final coords = userCoords;
    userPoint = Point(coords.dx, coords.dy, 'You');
    // Center on the user's position (Future required for context)
    Future.microtask(() => focusCoords(userPoint.offset, context));
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
        minScale: 1,
        constrained: false, // Let painting take mapSize
        boundaryMargin: EdgeInsets.all(16), // Give space for border points
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            CustomPaint(
              painter: GraphPainter(points, scale: scale),
              isComplex: true,
              willChange: false,
              size: mapSize,
            ),
            // * User Node
            Positioned(
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                  width: widget.userRadius / scale,
                  color: Colors.amber,
                )),
              ),
              // Default positioned puts top left at the coordinates
              left: userPoint.x - widget.userRadius / scale,
              top: userPoint.y - widget.userRadius / scale,
            ),
          ],
        ),
      ),
    );
  }

  // *** INTERACTIVE VIEWER FUNCTIONS
  void startPan(_) => hideItem();

  void endPan(_) {
    // Set scale
    final _scale = _zoomer.value.getMaxScaleOnAxis();
    if (scale != _scale) setState(() => scale = _scale);
  }

  // * Centers viewer on given site
  void focusSite(String site, BuildContext context) {
    final point = points.singleWhere(
      (point) => point.site == site,
      orElse: () => throw Exception('site not found'),
    );
    focusCoords(point.offset, context);
  }

  // * Centers viewer coordinates on given map coordinates
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

  // *** MAP FUNCTIONS
  // * Get the size of the total map
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

  // * Calculate coordinates of the user
  Offset get userCoords {
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

  // * Convert table data into a list of objects
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

  // * Get list of points on screen (5 milliseconds)
  List<Point> get onscreenPoints {
    final screenSize = MediaQuery.of(context).size;
    // Get max and min offset of map on screen
    final mapTopLeft = _zoomer.toScene(Offset.zero);
    final mapBottomRight = _zoomer.toScene(screenSize.bottomRight(Offset.zero));
    // Filter points to only those within the restraints
    return points
        .where((point) =>
            point.x >= mapTopLeft.dx &&
            point.x <= mapBottomRight.dx &&
            point.y >= mapTopLeft.dy &&
            point.y <= mapBottomRight.dy)
        .toList();
  }

  // *** CLICK FUNCTIONS
  // * Calculates which item was clicked
  clickItem(Offset clickCoords, BuildContext context) {
    // Convert screen to canvas/map coordinates
    final coords = _zoomer.toScene(clickCoords);
    // Get distances to viable points (Roughly 6X using onscreenPoints)
    final dists = getDistances(onscreenPoints, coords);
    // Search for point in data
    final result = selectDistance(dists);
    // Possibly display item info
    if (result != null)
      displayItem(result.site, clickCoords);
    else
      hideItem();
  }

  // * Get distances of the points given
  Map<Point, double> getDistances(List<Point> sites, Offset coords) {
    return Map<Point, double>.fromIterable(
      sites,
      key: (point) => point,
      value: (point) =>
          square(point.x - coords.dx) + square(point.y - coords.dy),
    );
  }

  // * Select the minimum distance from a map of points
  Point selectDistance(Map<Point, double> distances, {thresh = 10}) {
    if (distances.length == 0) return null;
    Point closestPoint = distances.keys.first;
    double closestDist = distances.values.first;
    // Iterate through distances
    distances.forEach((point, dist) {
      if (dist < closestDist) {
        closestPoint = point;
        closestDist = dist;
      }
    });
    return closestDist < thresh / scale ? closestPoint : null;
  }

  double square(double val) => val * val;

  // *** ITEM OVERLAY FUNCTIONS
  OverlayEntry itemPrompt;

  void displayItem(String site, Offset coords) {
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

  void hideItem() {
    if (itemPrompt != null) itemPrompt.remove();
    itemPrompt = null;
  }
}
