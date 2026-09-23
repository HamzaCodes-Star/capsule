import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/wardrobe_repository.dart';
import '../../../domain/models/garment.dart';
import '../../../domain/models/outfit.dart';
import '../../core/theme/app_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<WardrobeRepository>(context);
    final vm = Provider.of<DailyStylistViewModel>(context);

    if (vm.currentOutfit == null && repo.cleanGarments.isNotEmpty) {
      vm.initialize(repo.cleanGarments);
    }

    final outfit = vm.currentOutfit;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'C A P S U L E',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2.5,
                color: AppTheme.accentCamel,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Daily Stylist',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny_outlined, size: 14, color: AppTheme.accentGold),
                const SizedBox(width: 6),
                Text(
                  '${vm.context.temperature}°C',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
      body: repo.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentCamel))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContextControls(vm, repo.cleanGarments),
                  const SizedBox(height: 18),
                  if (outfit != null) ...[
                    _buildOutfitCard(outfit, vm),
                    const SizedBox(height: 20),
                    _buildActionButtons(vm, repo),
                  ] else ...[
                    _buildEmptyState(repo),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildContextControls(DailyStylistViewModel vm, List<Garment> cleanGarments) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.thermostat, size: 16, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      '${vm.context.temperature}°C',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          activeTrackColor: AppTheme.accentCamel,
                          inactiveTrackColor: AppTheme.surfaceBorder,
                          thumbColor: AppTheme.accentCamel,
                        ),
                        child: Slider(
                          value: vm.context.temperature.toDouble(),
                          min: 5,
                          max: 35,
                          onChanged: (val) {
                            vm.updateTemperature(val.round(), cleanGarments);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  vm.toggleRain(!vm.context.isRainy, cleanGarments);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: vm.context.isRainy
                        ? Colors.blue.withValues(alpha: 0.2)
                        : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: vm.context.isRainy ? Colors.blueAccent : AppTheme.surfaceBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        vm.context.isRainy ? Icons.water_drop : Icons.water_drop_outlined,
                        size: 14,
                        color: vm.context.isRainy ? Colors.lightBlueAccent : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vm.context.isRainy ? 'Rain' : 'Dry',
                        style: TextStyle(
                          fontSize: 12,
                          color: vm.context.isRainy ? Colors.lightBlueAccent : AppTheme.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'VIBE:',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              _buildFormalityChip('Casual', 1, vm, cleanGarments),
              const SizedBox(width: 8),
              _buildFormalityChip('Smart Casual', 2, vm, cleanGarments),
              const SizedBox(width: 8),
              _buildFormalityChip('Tailored', 3, vm, cleanGarments),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormalityChip(
      String label, int tier, DailyStylistViewModel vm, List<Garment> cleanGarments) {
    final isSelected = vm.context.targetFormality == tier;
    return Expanded(
      child: GestureDetector(
        onTap: () => vm.setFormality(tier, cleanGarments),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accentCamel.withValues(alpha: 0.15)
                : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.accentCamel : AppTheme.surfaceBorder,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppTheme.accentCamel : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutfitCard(Outfit outfit, DailyStylistViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentCamel.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.accentCamel.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 12, color: AppTheme.accentCamel),
                    const SizedBox(width: 5),
                    Text(
                      outfit.paletteType.displayName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentCamel,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.statusSuccess.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${outfit.matchScore}% Match',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.statusSuccess,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            outfit.harmonyReason,
            style: const TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: AppTheme.surfaceBorder, height: 1),
          const SizedBox(height: 16),

          // Garment Rows with Lock buttons
          if (outfit.outerwear != null) ...[
            _buildGarmentRow(
              outfit.outerwear!,
              'OUTERWEAR',
              isLocked: false,
              onToggleLock: null,
            ),
            const SizedBox(height: 12),
          ],
          _buildGarmentRow(
            outfit.top,
            'BASE TOP',
            isLocked: vm.isTopLocked(outfit.top.id),
            onToggleLock: () => vm.toggleLockTop(),
          ),
          const SizedBox(height: 12),
          _buildGarmentRow(
            outfit.bottom,
            'TROUSERS',
            isLocked: vm.isBottomLocked(outfit.bottom.id),
            onToggleLock: () => vm.toggleLockBottom(),
          ),
          const SizedBox(height: 12),
          _buildGarmentRow(
            outfit.footwear,
            'FOOTWEAR',
            isLocked: vm.isFootwearLocked(outfit.footwear.id),
            onToggleLock: () => vm.toggleLockFootwear(),
          ),
        ],
      ),
    );
  }

  Widget _buildGarmentRow(
    Garment garment,
    String categoryBadge, {
    required bool isLocked,
    required VoidCallback? onToggleLock,
  }) {
    Color parsedColor;
    try {
      final hex = garment.hexCode.replaceAll('#', '');
      parsedColor = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      parsedColor = Colors.grey;
    }

    final hasPhoto = garment.imageUrl.isNotEmpty && File(garment.imageUrl).existsSync();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLocked ? AppTheme.accentGold : AppTheme.surfaceBorder,
          width: isLocked ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: parsedColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 2),
              boxShadow: [
                BoxShadow(
                  color: parsedColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: hasPhoto
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Image.file(File(garment.imageUrl), fit: BoxFit.cover),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      categoryBadge,
                      style: const TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentCamel,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• ${garment.colorName}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  garment.subType,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (onToggleLock != null)
            IconButton(
              icon: Icon(
                isLocked ? Icons.lock : Icons.lock_open_outlined,
                color: isLocked ? AppTheme.accentGold : AppTheme.textMuted,
                size: 20,
              ),
              onPressed: onToggleLock,
              tooltip: isLocked ? 'Locked in place' : 'Lock piece for shuffle',
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: Text(
              '${garment.currentWears}/${garment.maxWears}w',
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(DailyStylistViewModel vm, WardrobeRepository repo) {
    final anyLocked = vm.lockedTopId != null || vm.lockedBottomId != null || vm.lockedFootwearId != null;

    return Column(
      children: [
        if (anyLocked)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 14, color: AppTheme.accentGold),
                const SizedBox(width: 6),
                const Text(
                  'One or more pieces locked in place',
                  style: TextStyle(fontSize: 12, color: AppTheme.accentGold, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => vm.clearLocks(),
                  child: const Text('Unlock All', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: vm.isWornToday
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await vm.wearThisOutfit(repo);
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Logged! Top sent to hamper. Outfit saved to Lookbook.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                icon: Icon(
                  vm.isWornToday ? Icons.check_circle : Icons.checkroom,
                  size: 18,
                ),
                label: Text(vm.isWornToday ? 'Worn Today' : 'Wear This Today'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: vm.isWornToday ? AppTheme.surfaceLight : AppTheme.accentCamel,
                  foregroundColor: vm.isWornToday ? AppTheme.textMuted : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => vm.shuffle(repo.cleanGarments),
              icon: const Icon(Icons.shuffle, color: AppTheme.textPrimary),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.surface,
                padding: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppTheme.surfaceBorder),
                ),
              ),
              tooltip: 'Shuffle Outfit',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(WardrobeRepository repo) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.wash, size: 54, color: AppTheme.accentCamel),
            const SizedBox(height: 16),
            const Text(
              'No Clean Outfit Combinations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'All tops or bottoms are currently in the hamper,\nor do not match the current weather conditions.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await repo.didLaundry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCamel,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Do Laundry & Wash All Pieces'),
            ),
          ],
        ),
      ),
    );
  }
}
