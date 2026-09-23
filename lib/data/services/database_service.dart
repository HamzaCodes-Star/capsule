import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../domain/models/garment.dart';
import '../../domain/models/outfit.dart';
import '../../domain/models/outfit_log.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'capsule_wardrobe.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE garments (
            id TEXT PRIMARY KEY,
            image_url TEXT NOT NULL,
            category TEXT NOT NULL,
            sub_type TEXT NOT NULL,
            color_name TEXT NOT NULL,
            hex_code TEXT NOT NULL,
            formality_tier INTEGER NOT NULL,
            current_wears INTEGER DEFAULT 0,
            max_wears INTEGER DEFAULT 1,
            in_hamper INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        await db.execute('''
          CREATE TABLE outfit_logs (
            id TEXT PRIMARY KEY,
            worn_date DATE NOT NULL,
            top_id TEXT NOT NULL,
            bottom_id TEXT NOT NULL,
            footwear_id TEXT NOT NULL,
            outerwear_id TEXT,
            FOREIGN KEY(top_id) REFERENCES garments(id),
            FOREIGN KEY(bottom_id) REFERENCES garments(id),
            FOREIGN KEY(footwear_id) REFERENCES garments(id)
          )
        ''');

        await _seedInitialCapsule(db);
      },
    );
  }

  Future<void> _seedInitialCapsule(Database db) async {
    final initialPieces = [
      // Tops
      {'id': 'g-top-1', 'image_url': 'assets/clothes/stone_oxford.jpg', 'category': 'top', 'sub_type': 'Stone Oxford', 'color_name': 'White', 'hex_code': '#F8FAFC', 'formality_tier': 2, 'current_wears': 0, 'max_wears': 1, 'in_hamper': 0},
      {'id': 'g-top-2', 'image_url': 'assets/clothes/navy_polo.jpg', 'category': 'top', 'sub_type': 'Navy Overshirt', 'color_name': 'Navy', 'hex_code': '#1E293B', 'formality_tier': 2, 'current_wears': 0, 'max_wears': 2, 'in_hamper': 0},
      {'id': 'g-top-3', 'image_url': 'assets/clothes/ecru_tee.jpg', 'category': 'top', 'sub_type': 'Ecru Tee', 'color_name': 'Beige', 'hex_code': '#E2D9CC', 'formality_tier': 1, 'current_wears': 3, 'max_wears': 3, 'in_hamper': 1},
      {'id': 'g-top-4', 'image_url': 'assets/clothes/stone_oxford.jpg', 'category': 'top', 'sub_type': 'Blue Poplin', 'color_name': 'Light Blue', 'hex_code': '#BAE6FD', 'formality_tier': 2, 'current_wears': 3, 'max_wears': 3, 'in_hamper': 1},

      // Bottoms
      {'id': 'g-bot-1', 'image_url': 'assets/clothes/khaki_chinos.jpg', 'category': 'bottom', 'sub_type': 'Khaki Chinos', 'color_name': 'Khaki', 'hex_code': '#C3B091', 'formality_tier': 2, 'current_wears': 0, 'max_wears': 3, 'in_hamper': 0},
      {'id': 'g-bot-2', 'image_url': 'assets/clothes/charcoal_trousers.jpg', 'category': 'bottom', 'sub_type': 'Charcoal Pleat', 'color_name': 'Charcoal', 'hex_code': '#334155', 'formality_tier': 3, 'current_wears': 0, 'max_wears': 4, 'in_hamper': 0},
      {'id': 'g-bot-3', 'image_url': 'assets/clothes/selvedge_denim.jpg', 'category': 'bottom', 'sub_type': 'Selvedge Denim', 'color_name': 'Dark Indigo', 'hex_code': '#0F172A', 'formality_tier': 1, 'current_wears': 1, 'max_wears': 5, 'in_hamper': 0},
      {'id': 'g-bot-4', 'image_url': 'assets/clothes/khaki_chinos.jpg', 'category': 'bottom', 'sub_type': 'Olive Chino', 'color_name': 'Olive', 'hex_code': '#556B2F', 'formality_tier': 2, 'current_wears': 4, 'max_wears': 4, 'in_hamper': 1},

      // Footwear
      {'id': 'g-sho-1', 'image_url': 'assets/clothes/white_sneaker.jpg', 'category': 'footwear', 'sub_type': 'Minimalist Sneaker', 'color_name': 'White', 'hex_code': '#FFFFFF', 'formality_tier': 1, 'current_wears': 0, 'max_wears': 10, 'in_hamper': 0},
      {'id': 'g-sho-2', 'image_url': 'assets/clothes/brown_derby.jpg', 'category': 'footwear', 'sub_type': 'Leather Derby', 'color_name': 'Dark Brown', 'hex_code': '#4A2E18', 'formality_tier': 2, 'current_wears': 0, 'max_wears': 10, 'in_hamper': 0},
      {'id': 'g-sho-3', 'image_url': 'assets/clothes/chelsea_boots.jpg', 'category': 'footwear', 'sub_type': 'Chelsea Boots', 'color_name': 'Black', 'hex_code': '#111827', 'formality_tier': 2, 'current_wears': 0, 'max_wears': 10, 'in_hamper': 0},

      // Outerwear
      {'id': 'g-out-1', 'image_url': 'assets/clothes/camel_overcoat.jpg', 'category': 'outerwear', 'sub_type': 'Camel Overcoat', 'color_name': 'Camel', 'hex_code': '#C19A6B', 'formality_tier': 3, 'current_wears': 0, 'max_wears': 10, 'in_hamper': 0},
      {'id': 'g-out-2', 'image_url': 'assets/clothes/olive_jacket.jpg', 'category': 'outerwear', 'sub_type': 'Olive Harrington', 'color_name': 'Olive', 'hex_code': '#556B2F', 'formality_tier': 2, 'current_wears': 0, 'max_wears': 8, 'in_hamper': 0},
    ];

    final batch = db.batch();
    for (final p in initialPieces) {
      batch.insert('garments', p);
    }
    await batch.commit(noResult: true);
  }

  // --- Garments CRUD ---
  Future<List<Garment>> getGarments() async {
    final db = await database;
    // Check if initial items need image URL hydration
    final check = await db.rawQuery('SELECT count(*) as count FROM garments WHERE image_url = ""');
    if (check.isNotEmpty && (check.first['count'] as int? ?? 0) > 0) {
      await db.delete('garments');
      await _seedInitialCapsule(db);
    }
    final maps = await db.query('garments', orderBy: 'category ASC, created_at DESC');
    return maps.map((m) => Garment.fromMap(m)).toList();
  }

  Future<Garment?> getGarmentById(String id) async {
    final db = await database;
    final maps = await db.query('garments', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Garment.fromMap(maps.first);
  }

  Future<void> insertGarment(Garment garment) async {
    final db = await database;
    await db.insert('garments', garment.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertGarments(List<Garment> garments) async {
    final db = await database;
    final batch = db.batch();
    for (final g in garments) {
      batch.insert('garments', g.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> updateGarment(Garment garment) async {
    final db = await database;
    await db.update('garments', garment.toMap(), where: 'id = ?', whereArgs: [garment.id]);
  }

  Future<void> deleteGarment(String id) async {
    final db = await database;
    await db.delete('garments', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleHamper(String id, bool inHamper) async {
    final db = await database;
    await db.update(
      'garments',
      {'in_hamper': inHamper ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> resetGarmentWears(String id) async {
    final db = await database;
    await db.update(
      'garments',
      {'current_wears': 0, 'in_hamper': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Wear Lifecycle & Hamper Management ---
  Future<void> logWornOutfit(Outfit outfit) async {
    final db = await database;
    final now = DateTime.now();

    await db.transaction((txn) async {
      await txn.insert('outfit_logs', {
        'id': 'log-${now.millisecondsSinceEpoch}',
        'worn_date': now.toIso8601String().split('T')[0],
        'top_id': outfit.top.id,
        'bottom_id': outfit.bottom.id,
        'footwear_id': outfit.footwear.id,
        'outerwear_id': outfit.outerwear?.id,
      });

      // Top: goes to hamper
      await txn.rawUpdate('''
        UPDATE garments 
        SET current_wears = current_wears + 1,
            in_hamper = 1
        WHERE id = ?
      ''', [outfit.top.id]);

      // Bottom: increment wear, hamper if threshold reached
      await txn.rawUpdate('''
        UPDATE garments 
        SET current_wears = current_wears + 1,
            in_hamper = CASE WHEN (current_wears + 1) >= max_wears THEN 1 ELSE in_hamper END
        WHERE id = ?
      ''', [outfit.bottom.id]);

      // Outerwear: increment wear if present
      if (outfit.outerwear != null) {
        await txn.rawUpdate('''
          UPDATE garments 
          SET current_wears = current_wears + 1,
              in_hamper = CASE WHEN (current_wears + 1) >= max_wears THEN 1 ELSE in_hamper END
          WHERE id = ?
        ''', [outfit.outerwear!.id]);
      }
    });
  }

  Future<List<OutfitLog>> getOutfitLogs() async {
    final db = await database;
    final logsData = await db.query('outfit_logs', orderBy: 'worn_date DESC, id DESC');
    if (logsData.isEmpty) return [];

    final allGarments = await getGarments();
    final garmentMap = {for (var g in allGarments) g.id: g};

    final List<OutfitLog> logs = [];
    for (final row in logsData) {
      final topId = row['top_id'] as String;
      final bottomId = row['bottom_id'] as String;
      final footwearId = row['footwear_id'] as String;
      final outerwearId = row['outerwear_id'] as String?;

      final top = garmentMap[topId];
      final bottom = garmentMap[bottomId];
      final footwear = garmentMap[footwearId];
      final outerwear = outerwearId != null ? garmentMap[outerwearId] : null;

      if (top != null && bottom != null && footwear != null) {
        logs.add(OutfitLog(
          id: row['id'] as String,
          wornDate: row['worn_date'] as String,
          top: top,
          bottom: bottom,
          footwear: footwear,
          outerwear: outerwear,
        ));
      }
    }
    return logs;
  }

  Future<void> clearHamper() async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE garments 
      SET in_hamper = 0,
          current_wears = 0
      WHERE in_hamper = 1
    ''');
  }

  Future<void> resetToDefaultCapsule() async {
    final db = await database;
    await db.delete('outfit_logs');
    await db.delete('garments');
    await _seedInitialCapsule(db);
  }
}
