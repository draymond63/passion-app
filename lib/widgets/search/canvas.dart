import 'package:flutter/material.dart';

class GraphPainter extends CustomPainter {
  final List<Point> data;
  final Size mapSize;
  final Function(Size) setSize;
  final double radius;
  final double scale;
  GraphPainter(
    this.data,
    this.mapSize,
    this.setSize, {
    this.radius = 8,
    this.scale = 1,
  });

  // Size is different from MediaQuery.size from parent
  paint(Canvas canvas, Size size) {
    setSize(size); // Tells parent about size
    final paint = Paint();
    final scaledRadius = radius / this.scale;
    // Keep everything in the bounds of the canvas
    Offset posScale = Offset(1, 1);
    if (size.width > 0 && size.height > 0)
      posScale = Offset(
        size.width / mapSize.width,
        size.height / mapSize.height,
      );

    // DRAWS VALUES OUTSIZE OF SIZE
    data.forEach((point) {
      paint.color = point.color ?? Colors.grey;
      canvas.drawCircle(
        point.offset.scale(posScale.dx, posScale.dy),
        point.site == 'You' ? scaledRadius * 1.5 : scaledRadius,
        paint,
      );
    });
  }

  shouldRepaint(GraphPainter oldPainter) =>
      oldPainter.data.length != data.length && oldPainter.scale != scale;
}

class Point {
  final double x;
  final double y;
  final String site;
  final MaterialColor color;
  Point(this.x, this.y, this.site, {this.color = Colors.grey});

  Offset get offset => Offset(x, y);
}

Map<String, Color> categoryColors = {
  'People': Colors.green,
  'History': Colors.blue,
  'Geography': Colors.yellow,
  'Arts': Colors.purple,
  'Philosophy_and_religion': Colors.red,
  'Everyday_life': Colors.cyan,
  'Society_and_social_sciences': Colors.amber,
  'Biological_and_health_sciences': Colors.orange,
  'Physical_sciences': Colors.indigo,
  'Technology': Colors.lightBlue,
  'Mathematics': Colors.lime,
};
