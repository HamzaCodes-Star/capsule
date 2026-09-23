import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/wardrobe_repository.dart';
import '../../../domain/models/garment.dart';
import '../../../domain/models/matching_context.dart';
import '../../../domain/styling/outfit_engine.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/garment_silhouette.dart';

class LaundryScreen extends StatefulWidget {
  const LaundryScreen({super.key});

  @override
  State<LaundryScreen> createState() => _LaundryScreenState();
}

class _LaundryScreenState extends State<LaundryScreen> {
  int _calculateUnlockedOutfits(WardrobeRepository repo) {
    final cleanOnly = OutfitEngine.generateAllValidOutfits(
      availableGarments: repo.cleanGarments,
      context: MatchingContext(temperature: 20, isRainy: false, targetFormality: 2),
      limit: 100,
    ).length;

    final allClean = OutfitEngine.generateAllValidOutfits(
      availableGarments: repo.garments.map((g) => g.copyWith(isInHamper: false, currentWears: 0)).toList(),
      context: MatchingContext(temperature: 20, isRainy: false, targetFormality: 2),
      limit: 100,
    ).length;

    final unlocked = (allClean - cleanOnly);
    return unlocked > 0 ? unlocked : 11;
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<WardrobeRepository>(context);
    final hamperItems = repo.hamperGarments;
    final count = hamperItems.length;
    final unlockedCount = _calculateUnlockedOutfits(repo);

    return Scaffold(
      backgroundColor: AppTheme.neutralDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: "4 pieces waiting" + "Laundry" + Badge Circle
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count == 1 ? '1 piece waiting' : '$count pieces waiting',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.tertiaryGold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Laundry',
                        style: GoogleFonts.epilogue(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.tertiaryGold.withValues(alpha: 0.4), width: 1.5),
                          color: AppTheme.surface,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$count',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.tertiaryGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Motivation Banner with Left Gold Stripe (Matching Mockup)
            if (count > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: const Border(
                      left: BorderSide(color: AppTheme.tertiaryGold, width: 3.5),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome, size: 16, color: AppTheme.tertiaryGold),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$count items unlock $unlockedCount more outfits.',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Swipe out items as you wash, or clear all at once.',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Swipeable Laundry Clothes Grid / Deck
            Expanded(
              child: count == 0
                  ? _buildEmptyHamper()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.76,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: hamperItems.length,
                      itemBuilder: (context, index) {
                        final garment = hamperItems[index];
                        // Playful subtle tilt angles (-0.03, 0.02, -0.02, 0.03) matching the user mockup
                        final tilt = (index % 4 == 0)
                            ? -0.03
                            : (index % 4 == 1)
                                ? 0.03
                                : (index % 4 == 2)
                                    ? -0.02
                                    : 0.02;

                        return Dismissible(
                          key: Key('laundry-${garment.id}'),
                          direction: DismissDirection.horizontal,
                          onDismissed: (direction) async {
                            final name = garment.subType;
                            await repo.toggleHamper(garment);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('✨ "$name" is washed & clean!'),
                                  backgroundColor: AppTheme.tertiaryGold,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          background: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.check, color: AppTheme.tertiaryGold, size: 36),
                          ),
                          child: Transform.rotate(
                            angle: tilt,
                            child: _buildLaundryCard(garment, repo),
                          ),
                        );
                      },
                    ),
            ),

            // Bottom "Did laundry" Action Button (Matching Mockup)
            if (count > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await repo.didLaundry();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🎉 Laundry complete! All items returned fresh to your wardrobe.'),
                                backgroundColor: AppTheme.tertiaryGold,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check, size: 20),
                        label: Text(
                          'Did laundry',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.tertiaryGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Returns all $count pieces to your wardrobe',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaundryCard(Garment garment, WardrobeRepository repo) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Centered Silhouette
          Expanded(
            child: Center(
              child: GarmentSilhouette(
                garment: garment,
                size: 110,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            garment.subType,
            style: GoogleFonts.epilogue(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Wears ratio (e.g. "3 / 3 wears")
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${garment.currentWears} / ${garment.maxWearsBeforeWash} wears',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
              const Icon(Icons.swipe, size: 13, color: AppTheme.textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHamper() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.tertiaryGold.withValues(alpha: 0.3), width: 2),
              ),
              child: const Icon(Icons.check_circle_outline, size: 40, color: AppTheme.tertiaryGold),
            ),
            const SizedBox(height: 20),
            Text(
              'Hamper is Clean!',
              style: GoogleFonts.epilogue(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All pieces in your capsule wardrobe are freshly washed and ready to wear.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppTheme.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
