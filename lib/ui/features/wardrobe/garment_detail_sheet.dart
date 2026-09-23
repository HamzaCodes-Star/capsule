import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/wardrobe_repository.dart';
import '../../../domain/models/garment.dart';
import '../../core/theme/app_theme.dart';

class GarmentDetailSheet extends StatelessWidget {
  final Garment garment;

  const GarmentDetailSheet({super.key, required this.garment});

  static void show(BuildContext context, Garment garment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => GarmentDetailSheet(garment: garment),
    );
  }

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppTheme.surfaceLight;
    }
  }

  String _getFormalityLabel(int tier) {
    switch (tier) {
      case 1:
        return 'Casual (Tier 1)';
      case 2:
        return 'Smart Casual (Tier 2)';
      case 3:
        return 'Business / Tailored (Tier 3)';
      default:
        return 'Versatile';
    }
  }

  IconData _getCategoryIcon(GarmentCategory category) {
    switch (category) {
      case GarmentCategory.top:
        return Icons.checkroom;
      case GarmentCategory.bottom:
        return Icons.straighten;
      case GarmentCategory.footwear:
        return Icons.roller_skating;
      case GarmentCategory.outerwear:
        return Icons.dry_cleaning;
      case GarmentCategory.accessory:
        return Icons.watch;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<WardrobeRepository>(context);
    final color = _parseHex(garment.hexCode);
    final hasPhoto = garment.imageUrl.isNotEmpty && File(garment.imageUrl).existsSync();

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppTheme.surfaceBorder, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header with image / swatch
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.accentCamel.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: hasPhoto
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          File(garment.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Icon(
                          _getCategoryIcon(garment.category),
                          size: 32,
                          color: color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white70,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      garment.category.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        letterSpacing: 2.0,
                        color: AppTheme.accentCamel,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      garment.subType,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 1),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${garment.colorName} (${garment.hexCode})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(color: AppTheme.surfaceBorder, height: 1),
          const SizedBox(height: 20),

          // Wear & Laundry status
          Text(
            'WEAR CYCLE & HYGIENE',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
              color: garment.inHamper ? AppTheme.statusDanger : AppTheme.accentCamel,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: garment.inHamper
                    ? AppTheme.statusDanger.withValues(alpha: 0.4)
                    : AppTheme.surfaceBorder,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      garment.inHamper ? 'Currently in Hamper' : 'Clean & Ready to Wear',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: garment.inHamper ? AppTheme.statusDanger : AppTheme.statusSuccess,
                      ),
                    ),
                    Text(
                      '${garment.currentWears} / ${garment.maxWearsBeforeWash} wears',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: garment.wearProgress,
                    minHeight: 8,
                    backgroundColor: AppTheme.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      garment.inHamper
                          ? AppTheme.statusDanger
                          : (garment.wearProgress >= 0.75
                              ? AppTheme.statusWarning
                              : AppTheme.accentCamel),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Metadata attributes
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Formality',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getFormalityLabel(garment.formalityTier),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weather Profile',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        garment.weatherBrackets.map((w) => w.name).join(', '),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await repo.toggleHamper(garment);
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: Icon(
                    garment.inHamper ? Icons.wash : Icons.local_laundry_service,
                    size: 18,
                  ),
                  label: Text(garment.inHamper ? 'Mark Clean' : 'Send to Hamper'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: garment.inHamper ? AppTheme.statusSuccess : AppTheme.accentCamel,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () async {
                  await repo.resetGarmentWears(garment);
                  if (context.mounted) Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.surfaceBorder),
                  foregroundColor: AppTheme.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Reset Wears'),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.surface,
                      title: const Text('Delete Piece'),
                      content: Text('Remove "${garment.subType}" from your capsule permanently?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.statusDanger,
                          ),
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
                icon: const Icon(Icons.delete_outline, color: AppTheme.statusDanger),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
