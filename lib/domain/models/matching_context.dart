import 'garment.dart';

class MatchingContext {
  final double temperatureCelsius;
  final bool isRainy;
  final int targetFormality; // 1: Casual, 2: Smart Casual, 3: Business/Tailored

  MatchingContext({
    double? temperatureCelsius,
    int? temperature,
    this.isRainy = false,
    this.targetFormality = 2,
  }) : temperatureCelsius = temperatureCelsius ?? (temperature?.toDouble() ?? 20.0);

  int get temperature => temperatureCelsius.round();

  WeatherBracket get activeWeatherBracket {
    if (temperatureCelsius < 5) return WeatherBracket.freezing;
    if (temperatureCelsius < 17) return WeatherBracket.cold;
    if (temperatureCelsius < 26) return WeatherBracket.mild;
    return WeatherBracket.hot;
  }

  bool get requiresOuterwear => temperatureCelsius < 17.0 || isRainy;

  MatchingContext copyWith({
    double? temperatureCelsius,
    int? temperature,
    bool? isRainy,
    int? targetFormality,
  }) {
    return MatchingContext(
      temperatureCelsius: temperatureCelsius ?? (temperature?.toDouble() ?? this.temperatureCelsius),
      isRainy: isRainy ?? this.isRainy,
      targetFormality: targetFormality ?? this.targetFormality,
    );
  }
}
