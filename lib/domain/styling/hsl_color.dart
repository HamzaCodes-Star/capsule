import 'dart:math';

class HslColor {
  final double h; // 0 - 360
  final double s; // 0 - 100
  final double l; // 0 - 100

  const HslColor({required this.h, required this.s, required this.l});

  static HslColor fromHex(String hex) {
    String cleanHex = hex.replaceAll('#', '').trim();
    if (cleanHex.length == 3) {
      cleanHex = cleanHex.split('').map((c) => '$c$c').join();
    }
    if (cleanHex.length != 6) {
      return const HslColor(h: 0, s: 0, l: 50);
    }

    final num = int.tryParse(cleanHex, radix: 16) ?? 0;
    final r = ((num >> 16) & 0xFF) / 255.0;
    final g = ((num >> 8) & 0xFF) / 255.0;
    final b = (num & 0xFF) / 255.0;

    final maxVal = max(r, max(g, b));
    final minVal = min(r, min(g, b));
    double h = 0.0;
    double s = 0.0;
    final l = (maxVal + minVal) / 2.0;

    if (maxVal != minVal) {
      final d = maxVal - minVal;
      s = l > 0.5 ? d / (2.0 - maxVal - minVal) : d / (maxVal + minVal);

      if (maxVal == r) {
        h = (g - b) / d + (g < b ? 6.0 : 0.0);
      } else if (maxVal == g) {
        h = (b - r) / d + 2.0;
      } else {
        h = (r - g) / d + 4.0;
      }
      h = (h * 60.0).roundToDouble();
    }

    return HslColor(
      h: h.clamp(0.0, 360.0),
      s: (s * 100.0).roundToDouble().clamp(0.0, 100.0),
      l: (l * 100.0).roundToDouble().clamp(0.0, 100.0),
    );
  }

  @override
  String toString() => 'HslColor(h: $h, s: $s%, l: $l%)';
}
