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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Weather & Formality Context'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Temperature: ${vm.context.temperature}°C'),
                  Switch(
                    value: vm.context.isRainy,
                    activeThumbColor: AppTheme.tertiaryGold,
                    onChanged: (val) {
                      setDialogState(() {});
                      vm.toggleRain(val, cleanGarments);
                    },
                  ),
                ],
              ),
              Slider(
                value: vm.context.temperature.toDouble(),
                min: 5,
                max: 35,
                activeColor: AppTheme.tertiaryGold,
                onChanged: (val) {
                  setDialogState(() {});
                  vm.updateTemperature(val.round(), cleanGarments);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [1, 2, 3].map((tier) {
                  final isSel = vm.context.targetFormality == tier;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(_formatFormality(tier)),
                        selected: isSel,
                        selectedColor: AppTheme.tertiaryGold,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.black : AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) {
                          setDialogState(() {});
                          vm.setFormality(tier, cleanGarments);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done', style: TextStyle(color: AppTheme.tertiaryGold)),
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

    if (vm.currentOutfit == null && repo.cleanGarments.isNotEmpty) {
      vm.initialize(repo.cleanGarments);
    }

    final outfit = vm.currentOutfit;
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMM').format(now).toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.neutralDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Greeting & Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.tertiaryGold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Morning, Alex.',
                        style: GoogleFonts.epilogue(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.surfaceBorder, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'AK',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Weather Sub-header (Interactive)
              GestureDetector(
                onTap: () => _showWeatherDialog(context, vm, repo.cleanGarments),
                child: Row(
                  children: [
                    Icon(
                      vm.context.isRainy ? Icons.water_drop : Icons.wb_sunny_outlined,
                      size: 15,
                      color: vm.context.isRainy ? Colors.lightBlueAccent : AppTheme.tertiaryGold,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${vm.context.temperature}°  ${vm.context.isRainy ? "Rain" : "Clear"} · High ${vm.context.temperature + 4}°  London',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Main Assembled Outfit Card (Matching Image 3)
              if (outfit != null) ...[
                _buildOutfitCard(context, outfit, vm, repo),
              ] else ...[
                _buildEmptyState(repo),
              ],
              const SizedBox(height: 16),

              // Secondary Banner: "TRIP COMING UP?"
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
                      decoration: BoxDecoration(
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

  Widget _buildOutfitCard(
    BuildContext context,
    Outfit outfit,
    DailyStylistViewModel vm,
    WardrobeRepository repo,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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

          // Headline in Epilogue
          Text(
            _getHeadline(outfit),
            style: GoogleFonts.epilogue(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 18),

          // COMPLETE OUTFIT FLAT-LAY CANVAS (As in Image 3)
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.canvasCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                // Top Left: SHIRT
                Positioned(
                  top: 0,
                  left: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outfit.top.subType.toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GarmentSilhouette(
                        garment: outfit.top,
                        size: 130,
                      ),
                    ],
                  ),
                ),

                // Top Right: TROUSERS
                Positioned(
                  top: 0,
                  right: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        outfit.bottom.subType.toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GarmentSilhouette(
                        garment: outfit.bottom,
                        size: 130,
                      ),
                    ],
                  ),
                ),

                // Bottom Center: SHOES
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GarmentSilhouette(
                          garment: outfit.footwear,
                          size: 120,
                        ),
                        const SizedBox(height: 2),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            outfit.footwear.subType.toUpperCase(),
                            style: GoogleFonts.dmSans(
                              fontSize: 9,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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

          // Action Buttons: "Wear this" and "Shuffle"
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
                    vm.isWornToday ? 'Worn Today' : 'Wear this',
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
            'Wash your garments or reset laundry to get today\'s curated edit.',
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
