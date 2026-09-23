import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/wardrobe_repository.dart';
import '../../../domain/models/garment.dart';
import '../../core/theme/app_theme.dart';
import 'add_single_garment_dialog.dart';
import 'garment_detail_sheet.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['All Clean', 'Tops', 'Bottoms', 'Shoes', 'Outerwear', 'Hamper'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<WardrobeRepository>(context);
    final hamperCount = repo.hamperGarments.length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'VAULT & COLLECTION',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2.5,
                color: AppTheme.accentCamel,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2),
            Text('Wardrobe', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => AddSingleGarmentDialog.show(context),
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.accentCamel),
            tooltip: 'Add Piece',
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.accentCamel,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.accentCamel,
          indicatorWeight: 2.5,
          tabs: _tabs.map((t) {
            if (t == 'Hamper' && hamperCount > 0) {
              return Tab(
                child: Row(
                  children: [
                    Text(t),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.statusDanger,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$hamperCount',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Tab(text: t);
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          if (hamperCount > 0) _buildLaundryBanner(context, repo, hamperCount),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGarmentGrid(repo.cleanGarments, repo),
                _buildGarmentGrid(repo.getByCategory(GarmentCategory.top), repo),
                _buildGarmentGrid(repo.getByCategory(GarmentCategory.bottom), repo),
                _buildGarmentGrid(repo.getByCategory(GarmentCategory.footwear), repo),
                _buildGarmentGrid(repo.getByCategory(GarmentCategory.outerwear), repo),
                _buildGarmentGrid(repo.hamperGarments, repo, isHamper: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaundryBanner(BuildContext context, WardrobeRepository repo, int count) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentCamel.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_laundry_service, color: AppTheme.accentCamel, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count item${count > 1 ? 's' : ''} in hamper',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Text(
                  'Wash & reset all items back to ready.',
                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await repo.didLaundry();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hamper cleared! All garments fresh & ready.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCamel,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Did Laundry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildGarmentGrid(List<Garment> items, WardrobeRepository repo, {bool isHamper = false}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isHamper ? Icons.sentiment_satisfied_alt : Icons.inventory_2_outlined,
              size: 48,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              isHamper ? 'Hamper is clean!' : 'No garments in this category',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              isHamper ? 'All pieces are ready in your wardrobe.' : 'Tap "+" or use Batch Ingest to add items.',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final garment = items[index];
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => GarmentDetailSheet.show(context, garment),
          child: _buildGarmentCard(garment),
        );
      },
    );
  }

  Widget _buildGarmentCard(Garment garment) {
    Color fabricColor;
    try {
      final hex = garment.hexCode.replaceAll('#', '');
      fabricColor = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      fabricColor = Colors.grey;
    }

    final wearPercent = (garment.currentWears / garment.maxWears).clamp(0.0, 1.0);
    final hasPhoto = garment.imageUrl.isNotEmpty && File(garment.imageUrl).existsSync();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: garment.inHamper ? AppTheme.statusDanger.withValues(alpha: 0.4) : AppTheme.surfaceBorder,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: fabricColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: hasPhoto
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.file(File(garment.imageUrl), fit: BoxFit.cover),
                      )
                    : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: garment.inHamper ? AppTheme.statusDanger.withValues(alpha: 0.15) : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  garment.inHamper ? 'HAMPER' : _tierLabel(garment.formalityTier),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: garment.inHamper ? AppTheme.statusDanger : AppTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),

          Text(
            garment.category.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w700,
              color: AppTheme.accentCamel,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            garment.subType,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            garment.colorName,
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Wears: ${garment.currentWears}/${garment.maxWears}',
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
              ),
              if (garment.inHamper)
                const Icon(Icons.wash, size: 14, color: AppTheme.statusDanger),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: wearPercent,
              minHeight: 4,
              backgroundColor: AppTheme.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                garment.inHamper
                    ? AppTheme.statusDanger
                    : (wearPercent >= 0.8 ? AppTheme.statusWarning : AppTheme.accentCamel),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _tierLabel(int tier) {
    switch (tier) {
      case 1:
        return 'CASUAL';
      case 2:
        return 'SMART';
      case 3:
        return 'TAILORED';
      default:
        return 'SMART';
    }
  }
}
