import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/wardrobe_repository.dart';
import '../../../domain/models/garment.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/garment_silhouette.dart';
import 'add_single_garment_dialog.dart';
import 'garment_detail_screen.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Tops', 'Bottoms', 'Footwear', 'Outerwear'];

  List<Garment> _getFilteredItems(WardrobeRepository repo) {
    switch (_selectedFilterIndex) {
      case 1:
        return repo.garments.where((g) => g.category == GarmentCategory.top).toList();
      case 2:
        return repo.garments.where((g) => g.category == GarmentCategory.bottom).toList();
      case 3:
        return repo.garments.where((g) => g.category == GarmentCategory.footwear).toList();
      case 4:
        return repo.garments.where((g) => g.category == GarmentCategory.outerwear).toList();
      default:
        return repo.garments;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<WardrobeRepository>(context);
    final total = repo.garments.length;
    final clean = repo.cleanGarments.length;
    final items = _getFilteredItems(repo);

    return Scaffold(
      backgroundColor: AppTheme.neutralDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: "32 pieces · 28 ready" + "Wardrobe" + Yellow (+) Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$total pieces · $clean ready',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.tertiaryGold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Wardrobe',
                        style: GoogleFonts.epilogue(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  // Yellow (+) Add Button (Matching Image 4)
                  GestureDetector(
                    onTap: () => AddSingleGarmentDialog.show(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppTheme.tertiaryGold,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add, color: Colors.black, size: 26),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Filter Pills (Matching Image 4)
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSel = _selectedFilterIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilterIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? AppTheme.tertiaryGold : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSel ? AppTheme.tertiaryGold : AppTheme.surfaceBorder,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _filters[index],
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          color: isSel ? Colors.black : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // 2-Column Garment Cards Grid
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'No pieces in this category',
                        style: GoogleFonts.dmSans(color: AppTheme.textMuted),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final garment = items[index];
                        return _buildGarmentCard(context, garment);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGarmentCard(BuildContext context, Garment garment) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GarmentDetailScreen(garment: garment),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flat-lay Garment Silhouette Showcase (Centered)
            Expanded(
              child: Center(
                child: Hero(
                  tag: 'garment-${garment.id}',
                  child: GarmentSilhouette(
                    garment: garment,
                    size: 110,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Title & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    garment.subType,
                    style: GoogleFonts.epilogue(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (garment.inHamper) ...[
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: AppTheme.statusDanger,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        garment.inHamper ? 'Hamper' : 'Clean',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: garment.inHamper ? AppTheme.statusDanger : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),

            // Wear count subtitle
            Text(
              '${garment.currentWears} wears',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
