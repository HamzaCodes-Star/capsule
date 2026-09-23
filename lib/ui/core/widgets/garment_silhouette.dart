import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/models/garment.dart';

class GarmentSilhouette extends StatelessWidget {
  final Garment garment;
  final double? width;
  final double? height;
  final double size;
  final bool showShadow;
  final String? badgeText;

  const GarmentSilhouette({
    super.key,
    required this.garment,
    this.width,
    this.height,
    this.size = 130,
    this.showShadow = true,
    this.badgeText,
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
    final effectiveWidth = width ?? size;
    final effectiveHeight = height ?? size;

    final isAsset = garment.imageUrl.startsWith('assets/');
    final isLocalFile = garment.imageUrl.isNotEmpty && !isAsset && File(garment.imageUrl).existsSync();

    Widget garmentWidget;

    if (isAsset || isLocalFile) {
      garmentWidget = SizedBox(
        width: effectiveWidth,
        height: effectiveHeight,
        child: isAsset
            ? Image.asset(garment.imageUrl, fit: BoxFit.contain)
            : Image.file(File(garment.imageUrl), fit: BoxFit.contain),
      );
    } else {
      final color = _parseHex(garment.hexCode);
      garmentWidget = SizedBox(
        width: effectiveWidth,
        height: effectiveHeight,
        child: CustomPaint(
          painter: _GarmentPainter(category: garment.category, color: color),
        ),
      );
    }

    if (badgeText != null && badgeText!.isNotEmpty) {
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          garmentWidget,
          Positioned(
            top: -16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2420),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    badgeText!,
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
                CustomPaint(
                  size: const Size(8, 4),
                  painter: _CaretPainter(color: const Color(0xFF1E2420)),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return garmentWidget;
  }
}

class _CaretPainter extends CustomPainter {
  final Color color;
  _CaretPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
