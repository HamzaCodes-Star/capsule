import 'garment.dart';

enum PaletteType {
  monochromatic,
  neutralAnchor,
  complementaryContrast;

  String get displayName {
    switch (this) {
      case PaletteType.monochromatic:
        return 'Monochromatic Harmony';
      case PaletteType.neutralAnchor:
        return 'Neutral Anchor';
      case PaletteType.complementaryContrast:
        return 'Complementary Contrast';
    }
  }
}

class Outfit {
  final String id;
  final Garment top;
  final Garment bottom;
  final Garment footwear;
  final Garment? outerwear;
  final double score;
  final PaletteType paletteType;
  final DateTime? wornDate;

  const Outfit({
    required this.id,
    required this.top,
    required this.bottom,
    required this.footwear,
    this.outerwear,
    required this.score,
    required this.paletteType,
    this.wornDate,
  });

  bool get hasOuterwear => outerwear != null;

  int get matchScore => score.round().clamp(70, 99);

  String get harmonyReason {
    switch (paletteType) {
      case PaletteType.neutralAnchor:
        return '${top.colorName} top paired with ${bottom.colorName} ${bottom.subType.toLowerCase()} creates a clean, timeless neutral anchor balance.';
      case PaletteType.monochromatic:
        return 'Sophisticated tonal layering: ${top.colorName} against ${bottom.colorName} provides intentional depth with high lightness contrast.';
      case PaletteType.complementaryContrast:
        return 'Dynamic complementary harmony pairing ${top.colorName} with ${bottom.colorName} for tailored visual pop without saturation clashing.';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'worn_date': wornDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'top_id': top.id,
      'bottom_id': bottom.id,
      'footwear_id': footwear.id,
      'outerwear_id': outerwear?.id,
    };
  }
}
