import '../models/garment.dart';
import '../models/matching_context.dart';
import '../models/outfit.dart';
import 'color_science.dart';
import 'hsl_color.dart';

class OutfitEngine {
  /// Deterministic on-device outfit generator (<10ms execution, zero network tokens).
  static List<Outfit> generateAllValidOutfits({
    required List<Garment> availableGarments,
    required MatchingContext context,
    int limit = 20,
  }) {
    final activeBracket = context.activeWeatherBracket;
    final requiresOuterwear = context.requiresOuterwear;

    // Filter available garments:
    // 1. Not in laundry hamper
    // 2. Wear count below wash threshold
    // 3. Appropriate for current temperature bracket
    // 4. Footwear rain protection (no suede/canvas in rain)
    final availableItems = availableGarments.where((item) {
      if (item.isInHamper) return false;
      if (item.currentWears >= item.maxWearsBeforeWash) return false;
      if (!item.weatherBrackets.contains(activeBracket)) return false;

      if (context.isRainy && item.category == GarmentCategory.footwear) {
        final sub = item.subType.toLowerCase();
        if (sub.contains('suede') || sub.contains('canvas') || sub.contains('espadrille')) {
          return false;
        }
      }
      return true;
    }).toList();

    final tops = availableItems.where((i) => i.category == GarmentCategory.top).toList();
    final bottoms = availableItems.where((i) => i.category == GarmentCategory.bottom).toList();
    final shoes = availableItems.where((i) => i.category == GarmentCategory.footwear).toList();
    final outerwear = availableItems.where((i) => i.category == GarmentCategory.outerwear).toList();

    if (tops.isEmpty || bottoms.isEmpty || shoes.isEmpty) {
      return [];
    }

    final List<Outfit> candidates = [];

    for (final top in tops) {
      for (final bottom in bottoms) {
        // Formality Guardrail: Top and Bottom within ±1 tier
        if ((top.formalityTier - bottom.formalityTier).abs() > 1) continue;
        if ((top.formalityTier - context.targetFormality).abs() > 1) continue;
        if ((bottom.formalityTier - context.targetFormality).abs() > 1) continue;

        final topHsl = HslColor.fromHex(top.hexCode);
        final bottomHsl = HslColor.fromHex(bottom.hexCode);

        final topBottomHarmony = ColorScience.evaluatePairHarmony(
          hsl1: topHsl,
          name1: top.colorName,
          hsl2: bottomHsl,
          name2: bottom.colorName,
        );

        if (!topBottomHarmony.isCompatible) continue;

        for (final shoe in shoes) {
          // Formality Guardrail: Shoe and Bottom within ±1 tier
          if ((shoe.formalityTier - bottom.formalityTier).abs() > 1) continue;

          final shoeHsl = HslColor.fromHex(shoe.hexCode);
          final shoeBottomHarmony = ColorScience.evaluatePairHarmony(
            hsl1: shoeHsl,
            name1: shoe.colorName,
            hsl2: bottomHsl,
            name2: bottom.colorName,
          );

          if (!shoeBottomHarmony.isCompatible) continue;

          double totalScore = (topBottomHarmony.score * 0.6) + (shoeBottomHarmony.score * 0.4);

          // Target formality alignment bonus
          if (top.formalityTier == context.targetFormality && bottom.formalityTier == context.targetFormality) {
            totalScore += 10.0;
          }

          if (requiresOuterwear) {
            if (outerwear.isEmpty) continue;
            for (final coat in outerwear) {
              if ((coat.formalityTier - top.formalityTier).abs() > 1) continue;

              final coatHsl = HslColor.fromHex(coat.hexCode);
              final coatHarmony = ColorScience.evaluatePairHarmony(
                hsl1: coatHsl,
                name1: coat.colorName,
                hsl2: bottomHsl,
                name2: bottom.colorName,
              );

              if (!coatHarmony.isCompatible) continue;

              candidates.add(Outfit(
                id: 'outfit-${DateTime.now().millisecondsSinceEpoch}-${candidates.length}',
                top: top,
                bottom: bottom,
                footwear: shoe,
                outerwear: coat,
                score: totalScore + 5.0,
                paletteType: topBottomHarmony.type,
              ));
            }
          } else {
            candidates.add(Outfit(
              id: 'outfit-${DateTime.now().millisecondsSinceEpoch}-${candidates.length}',
              top: top,
              bottom: bottom,
              footwear: shoe,
              score: totalScore,
              paletteType: topBottomHarmony.type,
            ));
          }
        }
      }
    }

    // Sort by highest harmonic score
    candidates.sort((a, b) => b.score.compareTo(a.score));

    return _deduplicateOutfits(candidates, limit);
  }

  static Outfit? generateDailyRecommendation({
    required List<Garment> availableGarments,
    required MatchingContext context,
  }) {
    final valid = generateAllValidOutfits(
      availableGarments: availableGarments,
      context: context,
      limit: 5,
    );
    return valid.isNotEmpty ? valid.first : null;
  }

  static List<Outfit> _deduplicateOutfits(List<Outfit> outfits, int limit) {
    final List<Outfit> results = [];
    final Set<String> seenCombos = {};

    for (final outfit in outfits) {
      final key = '${outfit.top.id}_${outfit.bottom.id}';
      if (!seenCombos.contains(key)) {
        seenCombos.add(key);
        results.add(outfit);
      }
      if (results.length >= limit) break;
    }

    return results;
  }
}

typedef CapsuleOutfitEngine = OutfitEngine;
