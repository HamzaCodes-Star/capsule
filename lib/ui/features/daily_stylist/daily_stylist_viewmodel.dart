import 'package:flutter/foundation.dart';
import '../../../domain/models/garment.dart';
import '../../../domain/models/matching_context.dart';
import '../../../domain/models/outfit.dart';
import '../../../domain/styling/outfit_engine.dart';
import '../../../data/repositories/wardrobe_repository.dart';

class DailyStylistViewModel extends ChangeNotifier {
  MatchingContext _context = MatchingContext(
    temperature: 20,
    isRainy: false,
    targetFormality: 2, // Smart Casual by default
  );

  List<Outfit> _availableOutfits = [];
  int _currentIndex = 0;
  bool _isGenerating = false;
  bool _isWornToday = false;

  String? _lockedTopId;
  String? _lockedBottomId;
  String? _lockedFootwearId;

  MatchingContext get context => _context;
  List<Outfit> get availableOutfits => _availableOutfits;
  int get currentIndex => _currentIndex;
  int get totalOutfits => _availableOutfits.length;

  Outfit? get currentOutfit {
    if (_availableOutfits.isEmpty) return null;
    if (_currentIndex >= _availableOutfits.length) {
      _currentIndex = 0;
    }
    return _availableOutfits[_currentIndex];
  }

  bool get isGenerating => _isGenerating;
  bool get isWornToday => _isWornToday;

  String? get lockedTopId => _lockedTopId;
  String? get lockedBottomId => _lockedBottomId;
  String? get lockedFootwearId => _lockedFootwearId;

  bool isTopLocked(String? id) => id != null && _lockedTopId == id;
  bool isBottomLocked(String? id) => id != null && _lockedBottomId == id;
  bool isFootwearLocked(String? id) => id != null && _lockedFootwearId == id;

  String get occasionBadge {
    if (_context.isRainy) return 'RAIN SAFE';
    if (_context.temperature < 15) return 'COLD WEATHER CHIC';
    switch (_context.targetFormality) {
      case 1:
        return 'WEEKEND COZY';
      case 2:
        return 'SMART CASUAL';
      case 3:
        return 'DATE NIGHT';
      default:
        return 'DAILY EDIT';
    }
  }

  void nextOutfit() {
    if (_availableOutfits.isNotEmpty) {
      _currentIndex = (_currentIndex + 1) % _availableOutfits.length;
      notifyListeners();
    }
  }

  void previousOutfit() {
    if (_availableOutfits.isNotEmpty) {
      _currentIndex = (_currentIndex - 1 + _availableOutfits.length) % _availableOutfits.length;
      notifyListeners();
    }
  }

  void selectOutfitIndex(int index) {
    if (index >= 0 && index < _availableOutfits.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void toggleLockTop() {
    if (currentOutfit != null) {
      _lockedTopId = (_lockedTopId == currentOutfit!.top.id) ? null : currentOutfit!.top.id;
      notifyListeners();
    }
  }

  void toggleLockBottom() {
    if (currentOutfit != null) {
      _lockedBottomId = (_lockedBottomId == currentOutfit!.bottom.id) ? null : currentOutfit!.bottom.id;
      notifyListeners();
    }
  }

  void toggleLockFootwear() {
    if (currentOutfit != null) {
      _lockedFootwearId = (_lockedFootwearId == currentOutfit!.footwear.id) ? null : currentOutfit!.footwear.id;
      notifyListeners();
    }
  }

  void clearLocks() {
    _lockedTopId = null;
    _lockedBottomId = null;
    _lockedFootwearId = null;
    notifyListeners();
  }

  void initialize(List<Garment> availableGarments) {
    if (_availableOutfits.isEmpty && availableGarments.isNotEmpty) {
      regenerateOutfit(availableGarments);
    }
  }

  void updateTemperature(int temp, List<Garment> availableGarments) {
    _context = _context.copyWith(temperature: temp);
    regenerateOutfit(availableGarments);
  }

  void toggleRain(bool isRainy, List<Garment> availableGarments) {
    _context = _context.copyWith(isRainy: isRainy);
    regenerateOutfit(availableGarments);
  }

  void setFormality(int formality, List<Garment> availableGarments) {
    _context = _context.copyWith(targetFormality: formality);
    regenerateOutfit(availableGarments);
  }

  List<Outfit> _filterByLocks(List<Outfit> list) {
    return list.where((o) {
      if (_lockedTopId != null && o.top.id != _lockedTopId) return false;
      if (_lockedBottomId != null && o.bottom.id != _lockedBottomId) return false;
      if (_lockedFootwearId != null && o.footwear.id != _lockedFootwearId) return false;
      return true;
    }).toList();
  }

  void regenerateOutfit(List<Garment> availableGarments) {
    _isGenerating = true;
    _isWornToday = false;
    notifyListeners();

    final all = OutfitEngine.generateAllValidOutfits(
      availableGarments: availableGarments,
      context: _context,
      limit: 50,
    );

    final filtered = _filterByLocks(all);
    _availableOutfits = filtered.isNotEmpty ? filtered : all;
    _currentIndex = 0;
    _isGenerating = false;
    notifyListeners();
  }

  void shuffle(List<Garment> availableGarments) {
    _isGenerating = true;
    _isWornToday = false;
    notifyListeners();

    final all = OutfitEngine.generateAllValidOutfits(
      availableGarments: availableGarments,
      context: _context,
      limit: 50,
    );

    final filtered = _filterByLocks(all);
    final pool = filtered.isNotEmpty ? filtered : all;

    if (pool.isNotEmpty) {
      final shuffled = List<Outfit>.from(pool)..shuffle();
      _availableOutfits = shuffled;
      _currentIndex = 0;
    } else {
      _availableOutfits = [];
      _currentIndex = 0;
    }

    _isGenerating = false;
    notifyListeners();
  }

  Future<void> wearThisOutfit(WardrobeRepository repo) async {
    if (currentOutfit == null || _isWornToday) return;

    await repo.recordWornOutfit(currentOutfit!);
    _isWornToday = true;
    clearLocks();
    notifyListeners();
  }
}
