import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/wardrobe_repository.dart';
import '../../../domain/models/garment.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/garment_silhouette.dart';

class GarmentDetailScreen extends StatelessWidget {
  final Garment garment;

  const GarmentDetailScreen({super.key, required this.garment});

  String _formatFormality(int tier) {
    switch (tier) {
      case 1:
        return 'Casual';
      case 2:
        return 'Smart casual';
      case 3:
        return 'Tailored';
      default:
        return 'Smart casual';
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<WardrobeRepository>(context);
    final total = repo.garments.length;
    final index = repo.garments.indexWhere((g) => g.id == garment.id);
    final itemNum = index >= 0 ? (index + 1).toString().padLeft(2, '0') : '01';
    final totalNum = total.toString().padLeft(2, '0');

    final remaining = (garment.maxWearsBeforeWash - garment.currentWears).clamp(0, garment.maxWearsBeforeWash);

    return Scaffold(
      backgroundColor: AppTheme.neutralDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar (Matching Image 5)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: const Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 20),
                    ),
                  ),
                  Text(
                    'GARMENT $itemNum / $totalNum',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppTheme.surface,
                          title: const Text('Delete Piece'),
                          content: Text('Remove "${garment.subType}" from your capsule?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusDanger),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await repo.deleteGarment(garment.id);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: const Icon(Icons.more_horiz, color: AppTheme.textPrimary, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Big Garment Flat-Lay Showcase + Yellow Pencil FAB (Matching Image 5)
                    SizedBox(
                      height: 260,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Center(
                            child: Hero(
                              tag: 'garment-${garment.id}',
                              child: GarmentSilhouette(
                                garment: garment,
                                size: 190,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: AppTheme.tertiaryGold,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
                                ],
                              ),
                              child: const Icon(Icons.edit, color: Colors.black, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Garment Meta & Title
                    Text(
                      '${garment.colorName.toUpperCase()} · ${garment.category.name.toUpperCase()}',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.tertiaryGold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            garment.subType,
                            style: GoogleFonts.epilogue(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.tertiaryGold,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _formatFormality(garment.formalityTier),
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // WEAR CYCLE Card (Matching Image 5)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'WEAR CYCLE',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              Text(
                                '${garment.currentWears} of ${garment.maxWearsBeforeWash} wears',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: garment.wearProgress,
                              minHeight: 6,
                              backgroundColor: AppTheme.surfaceLight,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.tertiaryGold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            garment.inHamper
                                ? 'Currently resting in hamper awaiting laundry.'
                                : (remaining == 0
                                    ? 'Reached wear threshold. Capsule suggests a wash.'
                                    : '$remaining more ${remaining == 1 ? "wear" : "wears"} before Capsule suggests a wash.'),
                            style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // BEST FOR Tags
                    Text(
                      'BEST FOR',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.tertiaryGold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        '12–22°C',
                        'Dry weather',
                        'Office',
                        'Dinner',
                      ].map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.surfaceBorder),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),

                    // OUTFIT HISTORY
                    Text(
                      'OUTFIT HISTORY',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.tertiaryGold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: repo.getByCategory(GarmentCategory.bottom).take(3).length,
                        separatorBuilder: (context, index) => const SizedBox(width: 10),
                        itemBuilder: (context, idx) {
                          final bottoms = repo.getByCategory(GarmentCategory.bottom).take(3).toList();
                          final b = bottoms[idx];
                          final dateLabels = ['14 MAY', '09 MAY', '02 MAY'];
                          return Container(
                            width: 82,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.surfaceBorder),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: GarmentSilhouette(garment: b, size: 48, showShadow: false),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  idx < dateLabels.length ? dateLabels[idx] : 'PAST',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Button: "Move to hamper" / "Mark as clean" (Matching Image 5)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await repo.toggleHamper(garment);
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: Icon(
                    garment.inHamper ? Icons.wash : Icons.delete_outline,
                    color: garment.inHamper ? AppTheme.statusSuccess : AppTheme.textPrimary,
                    size: 18,
                  ),
                  label: Text(
                    garment.inHamper ? 'Mark as fresh & clean' : 'Move to hamper',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: garment.inHamper ? AppTheme.statusSuccess : AppTheme.textPrimary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: garment.inHamper ? AppTheme.statusSuccess : AppTheme.surfaceBorder,
                      width: 1.5,
                    ),
                    backgroundColor: AppTheme.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
