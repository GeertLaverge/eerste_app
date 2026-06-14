import 'package:flutter/material.dart';

class OpmetingRaster extends StatelessWidget {
  const OpmetingRaster({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OpmetingRasterPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _OpmetingRasterPainter extends CustomPainter {
  static const double kleineRuit = 20;
  static const double groteRuit = 700;

  @override
  void paint(Canvas canvas, Size size) {
    final kleineLijn = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 0.35;

    final groteLijn = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 0.8;

    for (double x = 0; x <= size.width; x += kleineRuit) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        kleineLijn,
      );
    }

    for (double y = 0; y <= size.height; y += kleineRuit) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        kleineLijn,
      );
    }

    for (double x = 0; x <= size.width; x += groteRuit) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        groteLijn,
      );
    }

    for (double y = 0; y <= size.height; y += groteRuit) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        groteLijn,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
