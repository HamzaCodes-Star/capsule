import 'package:flutter_test/flutter_test.dart';
import 'package:capsule/domain/models/garment.dart';
import 'package:capsule/domain/models/matching_context.dart';
import 'package:capsule/domain/styling/outfit_engine.dart';

void main() {
  group('OutfitEngine Tests', () {
    final sampleGarments = [
      Garment(
        id: 'top-1',
        imageUrl: '',
        category: GarmentCategory.top,
        subType: 'Oxford Shirt',
        colorName: 'White',
        hexCode: '#F8FAFC',
        formalityTier: 2,
        currentWears: 0,
        maxWears: 1,
        inHamper: false,
      ),
      Garment(
        id: 'top-2',
        imageUrl: '',
        category: GarmentCategory.top,
        subType: 'Athletic Hoodie',
        colorName: 'Grey',
        hexCode: '#94A3B8',
        formalityTier: 1,
        currentWears: 0,
        maxWears: 1,
        inHamper: false,
      ),
      Garment(
        id: 'bot-1',
        imageUrl: '',
        category: GarmentCategory.bottom,
        subType: 'Chinos',
        colorName: 'Navy',
        hexCode: '#1E293B',
        formalityTier: 2,
        currentWears: 0,
        maxWears: 3,
        inHamper: false,
      ),
      Garment(
        id: 'bot-2',
        imageUrl: '',
        category: GarmentCategory.bottom,
        subType: 'Suit Trousers',
        colorName: 'Charcoal',
        hexCode: '#334155',
        formalityTier: 3,
        currentWears: 0,
        maxWears: 4,
        inHamper: false,
      ),
      Garment(
        id: 'sho-1',
        imageUrl: '',
        category: GarmentCategory.footwear,
        subType: 'White Minimalist Sneaker',
        colorName: 'White',
        hexCode: '#FFFFFF',
        formalityTier: 1,
        currentWears: 0,
        maxWears: 10,
        inHamper: false,
      ),
      Garment(
        id: 'sho-2',
        imageUrl: '',
        category: GarmentCategory.footwear,
        subType: 'Suede Chelsea Boots',
        colorName: 'Tan',
        hexCode: '#C19A6B',
        formalityTier: 2,
        currentWears: 0,
        maxWears: 10,
        inHamper: false,
      ),
      Garment(
        id: 'out-1',
        imageUrl: '',
        category: GarmentCategory.outerwear,
        subType: 'Overcoat',
        colorName: 'Camel',
        hexCode: '#C19A6B',
        formalityTier: 3,
        currentWears: 0,
        maxWears: 10,
        inHamper: false,
      ),
    ];

    test('Generates daily outfit recommendation adhering to target formality', () {
      final context = MatchingContext(
        temperature: 21,
        isRainy: false,
        targetFormality: 2,
      );

      final outfit = OutfitEngine.generateDailyRecommendation(
        availableGarments: sampleGarments,
        context: context,
      );

      expect(outfit, isNotNull);
      expect((outfit!.top.formalityTier - outfit.bottom.formalityTier).abs(), lessThanOrEqualTo(1));
      // Outerwear should not be forced at 21C and dry
      expect(outfit.outerwear, isNull);
    });

    test('Enforces rain protection by rejecting suede footwear in rain', () {
      final context = MatchingContext(
        temperature: 20,
        isRainy: true,
        targetFormality: 2,
      );

      final validOutfits = OutfitEngine.generateAllValidOutfits(
        availableGarments: sampleGarments,
        context: context,
      );

      for (final o in validOutfits) {
        expect(o.footwear.subType.toLowerCase().contains('suede'), isFalse);
      }
    });

    test('Appends outerwear automatically when temperature is cold (<17C)', () {
      final context = MatchingContext(
        temperature: 12,
        isRainy: false,
        targetFormality: 2,
      );

      final outfit = OutfitEngine.generateDailyRecommendation(
        availableGarments: sampleGarments,
        context: context,
      );

      expect(outfit, isNotNull);
      expect(outfit!.outerwear, isNotNull);
    });
  });
}
