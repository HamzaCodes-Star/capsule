enum GarmentCategory {
  top,
  bottom,
  footwear,
  outerwear,
  accessory;

  static GarmentCategory fromString(String val) {
    return GarmentCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => GarmentCategory.top,
    );
  }
}

enum WeatherBracket {
  freezing, // < 5°C
  cold,     // 5 - 17°C
  mild,     // 17 - 26°C
  hot;      // >= 26°C

  static WeatherBracket fromString(String val) {
    return WeatherBracket.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => WeatherBracket.mild,
    );
  }
}

class Garment {
  final String id;
  final String imageUrl;
  final GarmentCategory category;
  final String subType;
  final String colorName;
  final String hexCode;
  final int formalityTier; // 1: Casual, 2: Smart Casual, 3: Tailored / Business
  final List<WeatherBracket> weatherBrackets;
  final int currentWears;
  final int maxWearsBeforeWash;
  final bool isInHamper;
  final DateTime createdAt;

  Garment({
    required this.id,
    required this.imageUrl,
    required this.category,
    required this.subType,
    required this.colorName,
    required this.hexCode,
    required this.formalityTier,
    this.weatherBrackets = const [WeatherBracket.cold, WeatherBracket.mild, WeatherBracket.hot],
    this.currentWears = 0,
    int? maxWears,
    int? maxWearsBeforeWash,
    bool? inHamper,
    bool? isInHamper,
    DateTime? createdAt,
  })  : maxWearsBeforeWash = maxWears ?? maxWearsBeforeWash ?? (category == GarmentCategory.top ? 1 : 3),
        isInHamper = inHamper ?? isInHamper ?? false,
        createdAt = createdAt ?? DateTime.now();

  int get maxWears => maxWearsBeforeWash;
  bool get inHamper => isInHamper;

  bool get isReadyToWear => !isInHamper && (currentWears < maxWearsBeforeWash);

  double get wearProgress => maxWearsBeforeWash > 0
      ? (currentWears / maxWearsBeforeWash).clamp(0.0, 1.0)
      : 1.0;

  Garment copyWith({
    String? id,
    String? imageUrl,
    GarmentCategory? category,
    String? subType,
    String? colorName,
    String? hexCode,
    int? formalityTier,
    List<WeatherBracket>? weatherBrackets,
    int? currentWears,
    int? maxWearsBeforeWash,
    bool? isInHamper,
    DateTime? createdAt,
  }) {
    return Garment(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      subType: subType ?? this.subType,
      colorName: colorName ?? this.colorName,
      hexCode: hexCode ?? this.hexCode,
      formalityTier: formalityTier ?? this.formalityTier,
      weatherBrackets: weatherBrackets ?? this.weatherBrackets,
      currentWears: currentWears ?? this.currentWears,
      maxWearsBeforeWash: maxWearsBeforeWash ?? this.maxWearsBeforeWash,
      isInHamper: isInHamper ?? this.isInHamper,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_url': imageUrl,
      'category': category.name,
      'sub_type': subType,
      'color_name': colorName,
      'hex_code': hexCode,
      'formality_tier': formalityTier,
      'current_wears': currentWears,
      'max_wears': maxWearsBeforeWash,
      'in_hamper': isInHamper ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Garment.fromMap(Map<String, dynamic> map) {
    final cat = GarmentCategory.fromString(map['category'] as String? ?? 'top');
    final maxW = map['max_wears'] as int? ?? (cat == GarmentCategory.top ? 1 : 3);
    return Garment(
      id: map['id'] as String,
      imageUrl: map['image_url'] as String? ?? '',
      category: cat,
      subType: map['sub_type'] as String? ?? 'Garment',
      colorName: map['color_name'] as String? ?? 'Neutral',
      hexCode: map['hex_code'] as String? ?? '#000000',
      formalityTier: map['formality_tier'] as int? ?? 1,
      currentWears: map['current_wears'] as int? ?? 0,
      maxWearsBeforeWash: maxW,
      isInHamper: (map['in_hamper'] as int? ?? 0) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      weatherBrackets: _inferWeatherBrackets(map['sub_type'] as String? ?? ''),
    );
  }

  static List<WeatherBracket> _inferWeatherBrackets(String subType) {
    final s = subType.toLowerCase();
    if (s.contains('coat') || s.contains('jacket') || s.contains('wool') || s.contains('sweater') || s.contains('parka')) {
      return [WeatherBracket.freezing, WeatherBracket.cold];
    } else if (s.contains('shorts') || s.contains('linen') || s.contains('sandal') || s.contains('t-shirt') || s.contains('polo')) {
      return [WeatherBracket.mild, WeatherBracket.hot];
    }
    return [WeatherBracket.cold, WeatherBracket.mild, WeatherBracket.hot];
  }
}
