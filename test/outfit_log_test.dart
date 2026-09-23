import 'package:flutter_test/flutter_test.dart';
import 'package:capsule/domain/models/garment.dart';
import 'package:capsule/domain/models/outfit.dart';
import 'package:capsule/domain/models/outfit_log.dart';

void main() {
  group('OutfitLog Domain Tests', () {
    test('Constructs OutfitLog correctly from garments', () {
      final top = Garment(
        id: 'top-1',
        imageUrl: '',
        category: GarmentCategory.top,
        subType: 'Oxford Shirt',
        colorName: 'White',
        hexCode: '#FFFFFF',
        formalityTier: 2,
        currentWears: 1,
        maxWears: 1,
        inHamper: true,
      );

      final bottom = Garment(
        id: 'bot-1',
        imageUrl: '',
        category: GarmentCategory.bottom,
        subType: 'Chinos',
        colorName: 'Khaki',
        hexCode: '#C3B091',
        formalityTier: 2,
        currentWears: 1,
        maxWears: 3,
        inHamper: false,
      );

      final shoe = Garment(
        id: 'sho-1',
        imageUrl: '',
        category: GarmentCategory.footwear,
        subType: 'Penny Loafers',
        colorName: 'Dark Brown',
        hexCode: '#4A2E18',
        formalityTier: 2,
        currentWears: 1,
        maxWears: 10,
        inHamper: false,
      );

      final log = OutfitLog(
        id: 'log-101',
        wornDate: '2026-09-23',
        top: top,
        bottom: bottom,
        footwear: shoe,
      );

      expect(log.id, equals('log-101'));
      expect(log.wornDate, equals('2026-09-23'));
      expect(log.top.subType, equals('Oxford Shirt'));
      expect(log.bottom.currentWears, equals(1));
      expect(log.outerwear, isNull);
    });

    test('Garment wear progress calculation works properly', () {
      final bottom = Garment(
        id: 'bot-1',
        imageUrl: '',
        category: GarmentCategory.bottom,
        subType: 'Chinos',
        colorName: 'Khaki',
        hexCode: '#C3B091',
        formalityTier: 2,
        currentWears: 2,
        maxWears: 4,
      );

      expect(bottom.wearProgress, equals(0.5));
      expect(bottom.isReadyToWear, isTrue);

      final wornOut = bottom.copyWith(currentWears: 4, isInHamper: true);
      expect(wornOut.wearProgress, equals(1.0));
      expect(wornOut.isReadyToWear, isFalse);
    });
  });
}
