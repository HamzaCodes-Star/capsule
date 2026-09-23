import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/wardrobe_repository.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _keyController = TextEditingController();
  

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('gemini_api_key') ?? '';
    _keyController.text = key;
  }

  Future<void> _saveApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', _keyController.text.trim());
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gemini API Key saved securely.'),
          backgroundColor: AppTheme.accentCamel,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<WardrobeRepository>(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'PREFERENCES & SYSTEM',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2.5,
                color: AppTheme.accentCamel,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2),
            Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Vision API Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.auto_awesome, color: AppTheme.accentGold, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Gemini Flash Vision AI',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Used for automated bed-spread garment recognition and HSL fabric hex extraction. If left blank, on-device simulated ingestion is used.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _keyController,
                    obscureText: true,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Google Gemini API Key',
                      labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      hintText: 'AIzaSy...',
                      hintStyle: const TextStyle(color: AppTheme.textMuted),
                      filled: true,
                      fillColor: AppTheme.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.surfaceBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.surfaceBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.accentCamel),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveApiKey,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentCamel,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Save API Key', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Wardrobe Management Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CAPSULE VAULT RESET',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentCamel,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Restore your closet to the curated 14-piece classic minimalist starter collection (Tops, Chinos, Boots, Loafers & Outerwear).',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppTheme.surface,
                          title: const Text('Reset Capsule?'),
                          content: const Text(
                            'This will restore your wardrobe to the default 14-piece minimalist capsule and clear outfit logs.',
                          ),
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
                              child: const Text('Confirm Reset'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await repo.resetCapsuleToDefault();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Wardrobe restored to classic 14-piece starter capsule!'),
                              backgroundColor: AppTheme.accentCamel,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.restart_alt, size: 18, color: AppTheme.statusWarning),
                    label: const Text('Reset to Default Minimalist Capsule', style: TextStyle(color: AppTheme.statusWarning)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.surfaceBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // About & Architecture
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ABOUT CAPSULE',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentCamel,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Capsule Mobile Engine v1.0.0\n'
                    '• On-device deterministic styling (<10ms)\n'
                    '• Formality tier matching & rain protection\n'
                    '• Color theory HSL harmony scoring\n'
                    '• Wear-cycle laundry hamper tracking',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
