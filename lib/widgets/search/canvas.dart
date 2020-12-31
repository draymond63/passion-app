import 'package:flutter/material.dart';

class GraphPainter extends CustomPainter {
  final List<Point> data;
  final double radius;
  final double scale;
  GraphPainter(
    this.data, {
    this.radius = 10,
    this.scale = 1,
  });

  // Size must be mapSize or it will draw out of bounds
  paint(Canvas canvas, Size size) {
    final paint = Paint();
    final scaledRadius = radius / this.scale;
    // Draws each point in the data given
    data.forEach((point) {
      paint.color = point.color ?? Colors.grey;
      canvas.drawCircle(point.offset, scaledRadius, paint);
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

  String toString() => '$site ($x, $y)';
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
