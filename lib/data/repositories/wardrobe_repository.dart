import 'package:flutter/foundation.dart';
import '../../domain/models/garment.dart';
import '../../domain/models/outfit.dart';
import '../../domain/models/outfit_log.dart';
import '../services/database_service.dart';

class WardrobeRepository extends ChangeNotifier {
  final DatabaseService _dbService;
  List<Garment> _garments = [];
  List<OutfitLog> _outfitLogs = [];
  bool _isLoading = false;

  WardrobeRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  List<Garment> get garments => List.unmodifiable(_garments);
  List<OutfitLog> get outfitLogs => List.unmodifiable(_outfitLogs);
  bool get isLoading => _isLoading;

  List<Garment> get cleanGarments =>
      _garments.where((g) => !g.inHamper).toList();

  List<Garment> get hamperGarments =>
      _garments.where((g) => g.inHamper).toList();

  List<Garment> getByCategory(GarmentCategory category, {bool cleanOnly = true}) {
    return _garments.where((g) {
      final matchesCat = g.category == category;
      return cleanOnly ? (matchesCat && !g.inHamper) : matchesCat;
    }).toList();
  }

  Future<void> loadWardrobe() async {
    _isLoading = true;
    notifyListeners();

    try {
      _garments = await _dbService.getGarments();
      _outfitLogs = await _dbService.getOutfitLogs();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGarment(Garment garment) async {
    await _dbService.insertGarment(garment);
    await loadWardrobe();
  }

  Future<void> addGarments(List<Garment> newGarments) async {
    await _dbService.insertGarments(newGarments);
    await loadWardrobe();
  }

  Future<void> updateGarment(Garment garment) async {
    await _dbService.updateGarment(garment);
    await loadWardrobe();
  }

  Future<void> deleteGarment(String id) async {
    await _dbService.deleteGarment(id);
    await loadWardrobe();
  }

  Future<void> toggleHamper(Garment garment) async {
    await _dbService.toggleHamper(garment.id, !garment.inHamper);
    await loadWardrobe();
  }

  Future<void> resetGarmentWears(Garment garment) async {
    await _dbService.resetGarmentWears(garment.id);
    await loadWardrobe();
  }

  Future<void> recordWornOutfit(Outfit outfit) async {
    await _dbService.logWornOutfit(outfit);
    await loadWardrobe();
  }

  Future<void> didLaundry() async {
    await _dbService.clearHamper();
    await loadWardrobe();
  }

  Future<void> resetCapsuleToDefault() async {
    await _dbService.resetToDefaultCapsule();
    await loadWardrobe();
  }
}
