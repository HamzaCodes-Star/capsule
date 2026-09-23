import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/wardrobe_repository.dart';
import '../../../domain/models/garment.dart';
import '../../../domain/models/outfit.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/garment_silhouette.dart';
import 'daily_stylist_viewmodel.dart';

class DailyStylistScreen extends StatefulWidget {
  const DailyStylistScreen({super.key});

  @override
  State<DailyStylistScreen> createState() => _DailyStylistScreenState();
}

class _DailyStylistScreenState extends State<DailyStylistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repo = Provider.of<WardrobeRepository>(context, listen: false);
      final vm = Provider.of<DailyStylistViewModel>(context, listen: false);
      vm.initialize(repo.cleanGarments);
    });
  }

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

  String _getHeadline(Outfit? outfit) {
    if (outfit == null) return 'Ready to Dress.';
    switch (outfit.paletteType) {
      case PaletteType.neutralAnchor:
        return 'Sharp, without trying too hard.';
      case PaletteType.monochromatic:
        return 'Tonal layers, effortless depth.';
      case PaletteType.complementaryContrast:
        return 'Refined contrast, tailored pop.';
    }
  }

  void _showWeatherDialog(BuildContext context, DailyStylistViewModel vm, List<Garment> cleanGarments) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.surfaceBorder),
          ),
          title: Text(
            'Adjust Weather Context',
            style: GoogleFonts.epilogue(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Temperature: ${vm.context.temperature}°C',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Slider(
                value: vm.context.temperature.toDouble(),
                min: 0,
                max: 38,
                divisions: 38,
                activeColor: AppTheme.tertiaryGold,
                inactiveColor: AppTheme.surfaceLight,
                onChanged: (val) {
                  setDialogState(() {});
                  vm.updateTemperature(val.round(), cleanGarments);
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppTheme.tertiaryGold,
                title: Text(
                  'Raining outside?',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Enforces outerwear & rejects suede footwear',
                  style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textMuted),
                ),
                value: vm.context.isRainy,
                onChanged: (val) {
                  setDialogState(() {});
                  vm.toggleRain(val, cleanGarments);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Done',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.tertiaryGold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<WardrobeRepository>(context);
    final vm = Provider.of<DailyStylistViewModel>(context);
    final outfit = vm.currentOutfit;

    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMM d').format(now).toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.neutralDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER (Date & Weather Pill)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateStr,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  InkWell(
                    onTap: () => _showWeatherDialog(context, vm, repo.cleanGarments),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            vm.context.isRainy ? Icons.water_drop : Icons.wb_sunny_outlined,
                            size: 13,
                            color: AppTheme.tertiaryGold,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${vm.context.temperature}°C${vm.context.isRainy ? ' • Rain' : ''}',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.tune, size: 11, color: AppTheme.textMuted),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Formality Dial Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFormalityPill('Casual', 1, vm, repo.cleanGarments),
                    const SizedBox(width: 8),
                    _buildFormalityPill('Smart casual', 2, vm, repo.cleanGarments),
                    const SizedBox(width: 8),
                    _buildFormalityPill('Tailored', 3, vm, repo.cleanGarments),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // MAIN EDITORIAL FLAT-LAY CANVAS OR EMPTY STATE
              if (outfit != null) ...[
                _buildEditorialFlatLayCard(context, outfit, vm, repo),
              ] else ...[
                _buildEmptyState(repo),
              ],
              const SizedBox(height: 16),

              // Trip / Capsule Planner Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppTheme.surfaceLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.near_me_outlined, size: 20, color: AppTheme.tertiaryGold),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TRIP COMING UP?',
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pack a smarter capsule',
                            style: GoogleFonts.epilogue(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormalityPill(String label, int tier, DailyStylistViewModel vm, List<Garment> cleanGarments) {
    final isSelected = vm.context.targetFormality == tier;
    return GestureDetector(
      onTap: () => vm.setFormality(tier, cleanGarments),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.tertiaryGold : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.tertiaryGold : AppTheme.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.black : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildEditorialFlatLayCard(
    BuildContext context,
    Outfit outfit,
    DailyStylistViewModel vm,
    WardrobeRepository repo,
  ) {
    final hasOuter = outfit.hasOuterwear && outfit.outerwear != null;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: "YOUR 7:30 EDIT" + Formality Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR 7:30 EDIT',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.tertiaryGold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.tertiaryGold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatFormality(outfit.top.formalityTier),
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Headline
          Text(
            _getHeadline(outfit),
            style: GoogleFonts.epilogue(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),

          // THE ASYMMETRICAL FLAT-LAY STUDIO CANVAS (Matching Reference Photos)
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! < -150) {
                  vm.nextOutfit();
                } else if (details.primaryVelocity! > 150) {
                  vm.previousOutfit();
                }
              }
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2621), // Studio Slate Surface
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                children: [
                  // Stylist / Occasion Badge (e.g. "DATE NIGHT" from Image 3)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: Text(
                        vm.occasionBadge,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: AppTheme.tertiaryGold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2-Column Asymmetrical Grid Layout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT COLUMN: Outerwear on Top + Base Top Below
                      Expanded(
                        child: Column(
                          children: [
                            if (hasOuter) ...[
                              // Outerwear / Jacket
                              GarmentSilhouette(
                                garment: outfit.outerwear!,
                                width: 140,
                                height: 135,
                              ),
                              const SizedBox(height: 14),
                              // Base Top / Knit
                              GarmentSilhouette(
                                garment: outfit.top,
                                width: 130,
                                height: 125,
                              ),
                            ] else ...[
                              // Base Top prominent
                              GarmentSilhouette(
                                garment: outfit.top,
                                width: 145,
                                height: 155,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Base Layer Clean',
                                  style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.textMuted),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // RIGHT COLUMN: Bottoms (with "YOUR ITEM" badge) + Shoes Below
                      Expanded(
                        child: Column(
                          children: [
                            // Trousers / Jeans with "YOUR ITEM" badge (from Image 4)
                            GarmentSilhouette(
                              garment: outfit.bottom,
                              width: 135,
                              height: 160,
                              badgeText: 'YOUR ITEM',
                            ),
                            const SizedBox(height: 20),

                            // Footwear / Sneakers
                            GarmentSilhouette(
                              garment: outfit.footwear,
                              width: 130,
                              height: 95,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // CAROUSEL COMBINATIONS CONTROLLER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: AppTheme.tertiaryGold, size: 24),
                  onPressed: vm.totalOutfits > 1 ? vm.previousOutfit : null,
                  tooltip: 'Previous Outfit Combination',
                ),
                Column(
                  children: [
                    Text(
                      'LOOK ${vm.currentIndex + 1} OF ${vm.totalOutfits}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Swipe left/right to browse looks',
                      style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: AppTheme.tertiaryGold, size: 24),
                  onPressed: vm.totalOutfits > 1 ? vm.nextOutfit : null,
                  tooltip: 'Next Outfit Combination',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Contextual Reason with Star Icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.auto_awesome, size: 14, color: AppTheme.tertiaryGold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  outfit.harmonyReason,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action Buttons: "Wear this" and "Shuffle All"
          Row(
            children: [
              Expanded(
                flex: 6,
                child: ElevatedButton(
                  onPressed: vm.isWornToday
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await vm.wearThisOutfit(repo);
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Outfit logged! Top sent to hamper.'),
                              backgroundColor: AppTheme.tertiaryGold,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vm.isWornToday ? AppTheme.surfaceLight : AppTheme.tertiaryGold,
                    foregroundColor: vm.isWornToday ? AppTheme.textMuted : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    vm.isWornToday ? 'Worn Today' : 'Wear this Look',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: OutlinedButton.icon(
                  onPressed: () => vm.shuffle(repo.cleanGarments),
                  icon: const Icon(Icons.shuffle, size: 16),
                  label: Text(
                    'Shuffle',
                    style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.surfaceBorder, width: 1.5),
                    backgroundColor: AppTheme.surfaceLight,
                    foregroundColor: AppTheme.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(WardrobeRepository repo) {
    return Container(
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.wash, size: 48, color: AppTheme.tertiaryGold),
          const SizedBox(height: 14),
          Text(
            'All Pieces in Hamper',
            style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Wash your garments or reset laundry to get today curated edit.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () async => await repo.didLaundry(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.tertiaryGold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Do Laundry & Wash All'),
          ),
        ],
      ),
    );
  }
}
