import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/wardrobe_repository.dart';
import '../../../domain/models/garment.dart';
import '../../../domain/models/outfit_log.dart';
import '../../core/theme/app_theme.dart';

class LookbookScreen extends StatelessWidget {
  const LookbookScreen({super.key});

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppTheme.surfaceLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<WardrobeRepository>(context);
    final logs = repo.outfitLogs;
    final total = repo.garments.length;
    final clean = repo.cleanGarments.length;
    final hamper = repo.hamperGarments.length;

    // Calculate wardrobe utilization (pieces with at least 1 wear)
    final wornPieces = repo.garments.where((g) => g.currentWears > 0).length;
    final utilization = total > 0 ? ((wornPieces / total) * 100).round() : 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'LOOKBOOK & ANALYTICS',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2.5,
                color: AppTheme.accentCamel,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2),
            Text('Style History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Analytics KPI Grid
            Row(
              children: [
                _buildKpiCard('Total Pieces', '$total', Icons.checkroom, AppTheme.accentCamel),
                const SizedBox(width: 10),
                _buildKpiCard('Ready to Wear', '$clean', Icons.check_circle_outline, AppTheme.statusSuccess),
                const SizedBox(width: 10),
                _buildKpiCard('In Hamper', '$hamper', Icons.wash, AppTheme.statusDanger),
              ],
            ),
            const SizedBox(height: 14),

            // Wardrobe Utilization Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.accentCamel.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.accentCamel.withValues(alpha: 0.4)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$utilization%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.accentCamel,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Capsule Utilization',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$wornPieces of $total items actively rotating. High utilization prevents closet clutter.',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Outfits Logged Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'LOGGED OUTFITS',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentCamel,
                  ),
                ),
                Text(
                  '${logs.length} logged',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Outfit List or Empty State
            if (logs.isEmpty)
              _buildEmptyLookbook()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return _buildLogCard(log);
                },
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard(OutfitLog log) {
    return Container(
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
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 13, color: AppTheme.accentCamel),
                  const SizedBox(width: 6),
                  Text(
                    log.wornDate,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'COMPLETED',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.statusSuccess,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.surfaceBorder, height: 1),
          const SizedBox(height: 12),

          // Outfit pieces row
          Row(
            children: [
              _buildMiniPiece(log.top, 'TOP'),
              const SizedBox(width: 8),
              _buildMiniPiece(log.bottom, 'BOTTOM'),
              const SizedBox(width: 8),
              _buildMiniPiece(log.footwear, 'SHOES'),
              if (log.outerwear != null) ...[
                const SizedBox(width: 8),
                _buildMiniPiece(log.outerwear!, 'COAT'),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPiece(Garment garment, String categoryLabel) {
    final color = _parseHex(garment.hexCode);
    final hasPhoto = garment.imageUrl.isNotEmpty && File(garment.imageUrl).existsSync();

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: hasPhoto
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.file(File(garment.imageUrl), fit: BoxFit.cover),
                        )
                      : null,
                ),
                const SizedBox(width: 4),
                Text(
                  categoryLabel,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentCamel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              garment.subType,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              garment.colorName,
              style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyLookbook() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        children: const [
          Icon(Icons.style_outlined, size: 44, color: AppTheme.textMuted),
          SizedBox(height: 12),
          Text(
            'No Outfits Worn Yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          SizedBox(height: 6),
          Text(
            'When you tap "Wear This Today" on the Daily Stylist screen, your outfits and wear counts will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
          ),
        ],
      ),
    );
  }
}
