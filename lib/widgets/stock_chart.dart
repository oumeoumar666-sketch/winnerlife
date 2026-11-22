import 'package:flutter/material.dart';

class StockChart extends StatelessWidget {
  final List<double> priceHistory;
  final bool isUp;
  final double height;

  const StockChart({
    super.key,
    required this.priceHistory,
    required this.isUp,
    this.height = 160.0,
  });

  @override
  Widget build(BuildContext context) {
    if (priceHistory.isEmpty) {
      return SizedBox(height: height, child: const Center(child: Text('Aucune donnée de cours')));
    }

    final lineColor = isUp ? const Color(0xFF00C853) : const Color(0xFFFF3D00); // Vivid Green vs Vivid Red

    return Column(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: StockChartPainter(
              priceHistory: priceHistory,
              lineColor: lineColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Début: \$${priceHistory.first.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            Text(
              'Actuel: \$${priceHistory.last.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 12, color: lineColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}

class StockChartPainter extends CustomPainter {
  final List<double> priceHistory;
  final Color lineColor;

  StockChartPainter({
    required this.priceHistory,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (priceHistory.length < 2) return;

    final double minPrice = priceHistory.reduce((a, b) => a < b ? a : b);
    final double maxPrice = priceHistory.reduce((a, b) => a > b ? a : b);
    final double priceRange = (maxPrice - minPrice) == 0 ? 1.0 : (maxPrice - minPrice);

    final double paddingVertical = size.height * 0.15;
    final double usableHeight = size.height - (paddingVertical * 2);

    final List<Offset> points = [];
    final double stepX = size.width / (priceHistory.length - 1);

    for (int i = 0; i < priceHistory.length; i++) {
      final double x = i * stepX;
      final double normalizedY = (priceHistory[i] - minPrice) / priceRange;
      final double y = size.height - paddingVertical - (normalizedY * usableHeight);
      points.add(Offset(x, y));
    }

    // 1. Draw subtle background horizontal grid lines
    final Paint gridPaint = Paint()
      ..color = Colors.grey.withAlpha(40)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, paddingVertical), Offset(size.width, paddingVertical), gridPaint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), gridPaint);
    canvas.drawLine(Offset(0, size.height - paddingVertical), Offset(size.width, size.height - paddingVertical), gridPaint);

    // 2. Build smooth curve path
    final Path linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      linePath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p2.dx, p2.dy);
    }

    // 3. Draw Gradient Area Fill under the curve
    final Path fillPath = Path.from(linePath);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          lineColor.withAlpha(100),
          lineColor.withAlpha(5),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // 4. Draw Main Glowing Line Curve
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // 5. Draw Dots & Glowing Highlight at data points
    final Paint dotPaint = Paint()..color = lineColor;
    final Paint whiteDotPaint = Paint()..color = Colors.white;

    for (final point in points) {
      canvas.drawCircle(point, 5.0, dotPaint);
      canvas.drawCircle(point, 2.5, whiteDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant StockChartPainter oldDelegate) {
    return oldDelegate.priceHistory != priceHistory || oldDelegate.lineColor != lineColor;
  }
}
