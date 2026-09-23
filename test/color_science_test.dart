import 'package:flutter_test/flutter_test.dart';
import 'package:capsule/domain/styling/color_science.dart';
import 'package:capsule/domain/styling/hsl_color.dart';
import 'package:capsule/domain/models/outfit.dart';

void main() {
  group('ColorScience Tests', () {
    test('Navy + Khaki should identify as high-harmony neutral anchor', () {
      final navy = HslColor.fromHex('#1E293B');
      final khaki = HslColor.fromHex('#C3B091');

      final result = ColorScience.evaluatePairHarmony(
        hsl1: navy,
        name1: 'Navy',
        hsl2: khaki,
        name2: 'Khaki',
      );

      expect(result.isCompatible, isTrue);
      expect(result.type, PaletteType.neutralAnchor);
      expect(result.score, greaterThanOrEqualTo(85.0));
    });

    test('White + Charcoal should identify as high-harmony neutral anchor with lightness contrast', () {
      final white = HslColor.fromHex('#FFFFFF');
      final charcoal = HslColor.fromHex('#334155');

      final result = ColorScience.evaluatePairHarmony(
        hsl1: white,
        name1: 'White',
        hsl2: charcoal,
        name2: 'Charcoal',
      );

      expect(result.isCompatible, isTrue);
      expect(result.type, PaletteType.neutralAnchor);
      expect(result.score, greaterThanOrEqualTo(90.0));
    });

    test('Monochromatic shades with strong lightness difference succeed', () {
      // Light blue vs Deep Indigo (same hue ~210 deg, high lightness difference)
      final lightBlue = HslColor(h: 210, s: 60, l: 85);
      final deepNavy = HslColor(h: 215, s: 65, l: 20);

      final result = ColorScience.evaluatePairHarmony(
        hsl1: lightBlue,
        name1: 'Sky Blue',
        hsl2: deepNavy,
        name2: 'Deep Indigo',
      );

      expect(result.isCompatible, isTrue);
      expect(result.score, greaterThanOrEqualTo(85.0));
    });

    test('Mismatched saturated hues without complementarity fail', () {
      // Red (h=0) + Green (h=120) with high saturation
      final red = HslColor(h: 0, s: 80, l: 50);
      final green = HslColor(h: 120, s: 80, l: 50);

      final result = ColorScience.evaluatePairHarmony(
        hsl1: red,
        name1: 'Neon Red',
        hsl2: green,
        name2: 'Bright Green',
      );

      expect(result.isCompatible, isFalse);
    });
  });
}
