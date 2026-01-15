import 'package:flutter/material.dart';

class AppIconWidget extends StatelessWidget {
  final double size;

  const AppIconWidget({super.key, this.size = 512});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3),
        borderRadius: BorderRadius.circular(size * 0.1),
        border: Border.all(
          color: const Color(0xFF1976D2),
          width: size * 0.02,
        ),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.7, size * 0.7),
          painter: BrainIconPainter(),
        ),
      ),
    );
  }
}

class BrainIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFFE3F2FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.01;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw brain outline
    final brainPath = Path();
    brainPath.addOval(Rect.fromCenter(
      center: center,
      width: size.width * 0.8,
      height: size.height * 0.7,
    ));

    // Add brain lobes
    brainPath.addOval(Rect.fromCenter(
      center:
          Offset(center.dx - size.width * 0.15, center.dy - size.height * 0.1),
      width: size.width * 0.4,
      height: size.height * 0.5,
    ));

    brainPath.addOval(Rect.fromCenter(
      center:
          Offset(center.dx + size.width * 0.15, center.dy - size.height * 0.1),
      width: size.width * 0.4,
      height: size.height * 0.5,
    ));

    canvas.drawPath(brainPath, paint);
    canvas.drawPath(brainPath, strokePaint);

    // Draw brain division
    final divisionPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.008;

    canvas.drawLine(
      Offset(center.dx, center.dy - size.height * 0.3),
      Offset(center.dx, center.dy + size.height * 0.3),
      divisionPaint,
    );

    // Draw neural connections
    final connectionPaint = Paint()
      ..color = const Color(0xFFFF5722)
      ..style = PaintingStyle.fill;

    final nodeRadius = size.width * 0.02;

    // Left nodes
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.2, center.dy - size.height * 0.15),
      nodeRadius,
      connectionPaint,
    );

    // Right nodes
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.2, center.dy - size.height * 0.15),
      nodeRadius,
      connectionPaint,
    );

    // Center nodes
    connectionPaint.color = const Color(0xFF4CAF50);
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.15, center.dy + size.height * 0.05),
      nodeRadius,
      connectionPaint,
    );

    canvas.drawCircle(
      Offset(center.dx + size.width * 0.15, center.dy + size.height * 0.05),
      nodeRadius,
      connectionPaint,
    );

    // Bottom node
    connectionPaint.color = const Color(0xFFFFC107);
    canvas.drawCircle(
      Offset(center.dx, center.dy + size.height * 0.2),
      nodeRadius,
      connectionPaint,
    );

    // Draw connection lines
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.005;

    linePaint.color = const Color(0xFFFF5722).withValues(alpha: 0.6);
    canvas.drawLine(
      Offset(center.dx - size.width * 0.2, center.dy - size.height * 0.15),
      Offset(center.dx + size.width * 0.2, center.dy - size.height * 0.15),
      linePaint,
    );

    linePaint.color = const Color(0xFF4CAF50).withValues(alpha: 0.6);
    canvas.drawLine(
      Offset(center.dx - size.width * 0.15, center.dy + size.height * 0.05),
      Offset(center.dx + size.width * 0.15, center.dy + size.height * 0.05),
      linePaint,
    );

    // Spark effects
    final sparkPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.2),
      size.width * 0.01,
      sparkPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.3),
      size.width * 0.008,
      sparkPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.8),
      size.width * 0.008,
      sparkPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.7),
      size.width * 0.01,
      sparkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
