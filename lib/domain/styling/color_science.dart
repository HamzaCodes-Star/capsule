import 'dart:math';
import '../models/outfit.dart';
import 'hsl_color.dart';

class PairHarmonyResult {
  final bool isCompatible;
  final double score;
  final PaletteType type;

  const PairHarmonyResult({
    required this.isCompatible,
    required this.score,
    required this.type,
  });
}

class ColorScience {
  static const List<String> neutralTerms = [
    'white',
    'black',
    'grey',
    'gray',
    'charcoal',
    'beige',
    'khaki',
    'tan',
    'cream',
    'ivory',
    'navy',
  ];

  static bool isNeutral(HslColor hsl, String colorName) {
    final normalized = colorName.toLowerCase();
    if (neutralTerms.any((term) => normalized.contains(term))) return true;

    // Very low saturation = neutral grey/slate
    if (hsl.s <= 18.0) return true;

    // Extreme lightness = pure white/off-white or near-black
    if (hsl.l >= 90.0 || hsl.l <= 12.0) return true;

    // Muted Olive / Military green acting as neutral anchor
    if (hsl.h >= 70.0 && hsl.h <= 130.0 && hsl.s <= 35.0) return true;

    return false;
  }

  static double getHueDistance(double h1, double h2) {
    final diff = (h1 - h2).abs();
    return min(diff, 360.0 - diff);
  }

  static PairHarmonyResult evaluatePairHarmony({
    required HslColor hsl1,
    required String name1,
    required HslColor hsl2,
    required String name2,
  }) {
    final n1 = isNeutral(hsl1, name1);
    final n2 = isNeutral(hsl2, name2);

    // Case 1: Both are neutrals (e.g. Navy + Khaki, Charcoal + White)
    if (n1 && n2) {
      final lightnessDiff = (hsl1.l - hsl2.l).abs();
      // Block muddy same-lightness neutrals (e.g. dark grey on dark brown without contrast)
      if (lightnessDiff < 15.0 && hsl1.l > 20.0 && hsl1.l < 80.0) {
        return const PairHarmonyResult(
          isCompatible: false,
          score: 20.0,
          type: PaletteType.neutralAnchor,
        );
      }
      final bonus = min(lightnessDiff / 5.0, 15.0);
      return PairHarmonyResult(
        isCompatible: true,
        score: 85.0 + bonus,
        type: PaletteType.neutralAnchor,
      );
    }

    // Case 2: One neutral anchor + One colored accent (e.g. Olive chinos + Navy shirt)
    if (n1 || n2) {
      return const PairHarmonyResult(
        isCompatible: true,
        score: 90.0,
        type: PaletteType.neutralAnchor,
      );
    }

    // Case 3: Both are non-neutrals
    final hueDiff = getHueDistance(hsl1.h, hsl2.h);
    final lightnessDiff = (hsl1.l - hsl2.l).abs();

    // 3A: Monochromatic Harmony (Same color family with distinct lightness contrast)
    if (hueDiff <= 25.0) {
      if (lightnessDiff >= 25.0) {
        return const PairHarmonyResult(
          isCompatible: true,
          score: 95.0,
          type: PaletteType.monochromatic,
        );
      }
      // Same hue but muddy / near-identical lightness = mismatch
      return const PairHarmonyResult(
        isCompatible: false,
        score: 30.0,
        type: PaletteType.monochromatic,
      );
    }

    // 3B: Complementary Contrast (Opposite sides of color wheel: 180° ± 30°)
    if (hueDiff >= 150.0 && hueDiff <= 210.0) {
      // Must not be overly saturated to avoid neon clash
      if (hsl1.s < 75.0 || hsl2.s < 75.0) {
        return const PairHarmonyResult(
          isCompatible: true,
          score: 85.0,
          type: PaletteType.complementaryContrast,
        );
      }
    }

    return const PairHarmonyResult(
      isCompatible: false,
      score: 10.0,
      type: PaletteType.complementaryContrast,
    );
  }
}
