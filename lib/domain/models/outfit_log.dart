import 'garment.dart';

class OutfitLog {
  final String id;
  final String wornDate;
  final Garment top;
  final Garment bottom;
  final Garment footwear;
  final Garment? outerwear;

  const OutfitLog({
    required this.id,
    required this.wornDate,
    required this.top,
    required this.bottom,
    required this.footwear,
    this.outerwear,
  });
}
