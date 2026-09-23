import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../domain/models/garment.dart';

class GarmentSilhouette extends StatelessWidget {
  final Garment garment;
  final double size;
  final bool showShadow;

  const GarmentSilhouette({
    super.key,
    required this.garment,
    this.size = 120,
    this.showShadow = true,
  });

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFFE2D9CC);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAsset = garment.imageUrl.startsWith('assets/');
    final isLocalFile = garment.imageUrl.isNotEmpty && !isAsset && File(garment.imageUrl).existsSync();

    if (isAsset || isLocalFile) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: isAsset
              ? Image.asset(garment.imageUrl, fit: BoxFit.cover)
              : Image.file(File(garment.imageUrl), fit: BoxFit.contain),
        ),
      );
    }

    final color = _parseHex(garment.hexCode);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        painter: _GarmentPainter(category: garment.category, color: color),
      ),
    );
  }
}

class _GarmentPainter extends CustomPainter {
  final GarmentCategory category;
  final Color color;

  _GarmentPainter({required this.category, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final outline = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final detailPaint = Paint()
      ..color = (color.computeLuminance() > 0.4 ? Colors.black : Colors.white).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    switch (category) {
      case GarmentCategory.top:
        final path = Path();
        path.moveTo(w * 0.35, h * 0.12);
        path.lineTo(w * 0.20, h * 0.18);
        path.lineTo(w * 0.05, h * 0.32);
        path.lineTo(w * 0.18, h * 0.44);
        path.lineTo(w * 0.28, h * 0.36);
        path.lineTo(w * 0.28, h * 0.88);
        path.lineTo(w * 0.72, h * 0.88);
        path.lineTo(w * 0.72, h * 0.36);
        path.lineTo(w * 0.82, h * 0.44);
        path.lineTo(w * 0.95, h * 0.32);
        path.lineTo(w * 0.80, h * 0.18);
        path.lineTo(w * 0.65, h * 0.12);
        path.quadraticBezierTo(w * 0.50, h * 0.22, w * 0.35, h * 0.12);
        path.close();

        canvas.drawPath(path, paint);
        canvas.drawPath(path, outline);

        canvas.drawLine(Offset(w * 0.50, h * 0.18), Offset(w * 0.50, h * 0.55), detailPaint);
        canvas.drawLine(Offset(w * 0.42, h * 0.15), Offset(w * 0.50, h * 0.22), detailPaint);
        canvas.drawLine(Offset(w * 0.58, h * 0.15), Offset(w * 0.50, h * 0.22), detailPaint);
        break;

      case GarmentCategory.bottom:
        final path = Path();
        path.moveTo(w * 0.22, h * 0.10);
        path.lineTo(w * 0.78, h * 0.10);
        path.lineTo(w * 0.75, h * 0.90);
        path.lineTo(w * 0.55, h * 0.90);
        path.lineTo(w * 0.50, h * 0.36);
        path.lineTo(w * 0.45, h * 0.90);
        path.lineTo(w * 0.25, h * 0.90);
        path.close();

        canvas.drawPath(path, paint);
        canvas.drawPath(path, outline);

        canvas.drawLine(Offset(w * 0.36, h * 0.15), Offset(w * 0.34, h * 0.30), detailPaint);
        canvas.drawLine(Offset(w * 0.64, h * 0.15), Offset(w * 0.66, h * 0.30), detailPaint);
        break;

      case GarmentCategory.footwear:
        final path = Path();
        path.moveTo(w * 0.12, h * 0.68);
        path.lineTo(w * 0.30, h * 0.44);
        path.lineTo(w * 0.52, h * 0.50);
        path.quadraticBezierTo(w * 0.78, h * 0.56, w * 0.90, h * 0.70);
        path.quadraticBezierTo(w * 0.92, h * 0.82, w * 0.82, h * 0.84);
        path.lineTo(w * 0.12, h * 0.84);
        path.quadraticBezierTo(w * 0.08, h * 0.76, w * 0.12, h * 0.68);
        path.close();

        canvas.drawPath(path, paint);
        canvas.drawPath(path, outline);

        canvas.drawLine(Offset(w * 0.10, h * 0.80), Offset(w * 0.86, h * 0.80), detailPaint);
        canvas.drawLine(Offset(w * 0.32, h * 0.50), Offset(w * 0.46, h * 0.54), detailPaint);
        canvas.drawLine(Offset(w * 0.30, h * 0.56), Offset(w * 0.44, h * 0.60), detailPaint);
        break;

      case GarmentCategory.outerwear:
      case GarmentCategory.accessory:
        final path = Path();
        path.moveTo(w * 0.35, h * 0.10);
        path.lineTo(w * 0.15, h * 0.18);
        path.lineTo(w * 0.05, h * 0.50);
        path.lineTo(w * 0.20, h * 0.56);
        path.lineTo(w * 0.28, h * 0.42);
        path.lineTo(w * 0.28, h * 0.90);
        path.lineTo(w * 0.72, h * 0.90);
        path.lineTo(w * 0.72, h * 0.42);
        path.lineTo(w * 0.80, h * 0.56);
        path.lineTo(w * 0.95, h * 0.50);
        path.lineTo(w * 0.85, h * 0.18);
        path.lineTo(w * 0.65, h * 0.10);
        path.close();

        canvas.drawPath(path, paint);
        canvas.drawPath(path, outline);

        canvas.drawLine(Offset(w * 0.50, h * 0.10), Offset(w * 0.50, h * 0.90), detailPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _GarmentPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.category != category;
  }
}
