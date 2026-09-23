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

  Outfit? _currentOutfit;
  bool _isGenerating = false;
  bool _isWornToday = false;

  String? _lockedTopId;
  String? _lockedBottomId;
  String? _lockedFootwearId;

  MatchingContext get context => _context;
  Outfit? get currentOutfit => _currentOutfit;
  bool get isGenerating => _isGenerating;
  bool get isWornToday => _isWornToday;

  String? get lockedTopId => _lockedTopId;
  String? get lockedBottomId => _lockedBottomId;
  String? get lockedFootwearId => _lockedFootwearId;

  bool isTopLocked(String? id) => id != null && _lockedTopId == id;
  bool isBottomLocked(String? id) => id != null && _lockedBottomId == id;
  bool isFootwearLocked(String? id) => id != null && _lockedFootwearId == id;

  void toggleLockTop() {
    if (_currentOutfit != null) {
      _lockedTopId = (_lockedTopId == _currentOutfit!.top.id) ? null : _currentOutfit!.top.id;
      notifyListeners();
    }
  }

  void toggleLockBottom() {
    if (_currentOutfit != null) {
      _lockedBottomId = (_lockedBottomId == _currentOutfit!.bottom.id) ? null : _currentOutfit!.bottom.id;
      notifyListeners();
    }
  }

  void toggleLockFootwear() {
    if (_currentOutfit != null) {
      _lockedFootwearId = (_lockedFootwearId == _currentOutfit!.footwear.id) ? null : _currentOutfit!.footwear.id;
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
    if (_currentOutfit == null && availableGarments.isNotEmpty) {
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

    _currentOutfit = filtered.isNotEmpty ? filtered.first : (all.isNotEmpty ? all.first : null);
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

    if (filtered.isNotEmpty) {
      filtered.shuffle();
      if (filtered.length > 1 && _currentOutfit != null) {
        _currentOutfit = filtered.firstWhere(
          (o) => o.top.id != _currentOutfit!.top.id || o.bottom.id != _currentOutfit!.bottom.id,
          orElse: () => filtered.first,
        );
      } else {
        _currentOutfit = filtered.first;
      }
    } else if (all.isNotEmpty) {
      all.shuffle();
      _currentOutfit = all.first;
    } else {
      _currentOutfit = null;
    }

    _isGenerating = false;
    notifyListeners();
  }

  Future<void> wearThisOutfit(WardrobeRepository repo) async {
    if (_currentOutfit == null || _isWornToday) return;

    await repo.recordWornOutfit(_currentOutfit!);
    _isWornToday = true;
    clearLocks();
    notifyListeners();
  }
}
