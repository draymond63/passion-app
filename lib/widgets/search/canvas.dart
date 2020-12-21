import 'package:flutter/material.dart';

class GraphPainter extends CustomPainter {
  final List<Point> data;
  final double radius;
  final double scale;
  GraphPainter(this.data, {this.radius = 8, this.scale = 1});

  paint(Canvas canvas, Size size) {
    final paint = Paint();
    final offsetX = size.width / 2;
    final offsetY = size.height / 2;
    final scaledRadius = radius / this.scale;

    data.forEach((point) {
      paint.color = point.color ?? Colors.grey;
      canvas.drawCircle(
          point.offset.translate(offsetX, offsetY), scaledRadius, paint);
    });
  }

  shouldRepaint(GraphPainter oldPainter) =>
      oldPainter.data.length != data.length && oldPainter.scale != scale;
}

class Point {
  final double x;
  final double y;
  final MaterialColor color;
  Point(this.x, this.y, {this.color = Colors.grey});

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
