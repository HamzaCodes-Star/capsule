import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/wardrobe_repository.dart';
import '../../../domain/models/garment.dart';
import '../../core/theme/app_theme.dart';

class AddSingleGarmentDialog extends StatefulWidget {
  const AddSingleGarmentDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const AddSingleGarmentDialog(),
    );
  }

  @override
  State<AddSingleGarmentDialog> createState() => _AddSingleGarmentDialogState();
}

class _AddSingleGarmentDialogState extends State<AddSingleGarmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  GarmentCategory _category = GarmentCategory.top;
  int _formalityTier = 2; // Smart Casual default
  int _maxWears = 1;

  final List<Map<String, String>> _palettePresets = [
    {'name': 'White', 'hex': '#F8FAFC'},
    {'name': 'Navy', 'hex': '#1E293B'},
    {'name': 'Charcoal', 'hex': '#334155'},
    {'name': 'Khaki', 'hex': '#C3B091'},
    {'name': 'Olive', 'hex': '#556B2F'},
    {'name': 'Camel', 'hex': '#C19A6B'},
    {'name': 'Light Blue', 'hex': '#BAE6FD'},
    {'name': 'Black', 'hex': '#111827'},
    {'name': 'Grey', 'hex': '#94A3B8'},
    {'name': 'Burgundy', 'hex': '#800020'},
  ];

  late String _selectedColorName;
  late String _selectedHexCode;

  @override
  void initState() {
    super.initState();
    _selectedColorName = _palettePresets[0]['name']!;
    _selectedHexCode = _palettePresets[0]['hex']!;
    _updateDefaultMaxWears(_category);
  }

  void _updateDefaultMaxWears(GarmentCategory category) {
    switch (category) {
      case GarmentCategory.top:
        _maxWears = 1;
        break;
      case GarmentCategory.bottom:
        _maxWears = 3;
        break;
      case GarmentCategory.footwear:
      case GarmentCategory.outerwear:
        _maxWears = 10;
        break;
      case GarmentCategory.accessory:
        _maxWears = 20;
        break;
    }
  }

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppTheme.surfaceLight;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.surfaceBorder, width: 1.5),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add to Wardrobe',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textMuted, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name / Subtype
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Piece Name (e.g. Oxford Shirt, Chinos)',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
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
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter piece name' : null,
                ),
                const SizedBox(height: 16),

                // Category Chips
                const Text(
                  'CATEGORY',
                  style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: AppTheme.accentCamel, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: GarmentCategory.values.map((cat) {
                    final isSel = _category == cat;
                    return ChoiceChip(
                      label: Text(cat.name.toUpperCase()),
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSel ? Colors.black : AppTheme.textSecondary,
                      ),
                      selected: isSel,
                      selectedColor: AppTheme.accentCamel,
                      backgroundColor: AppTheme.surfaceLight,
                      side: BorderSide(
                        color: isSel ? AppTheme.accentCamel : AppTheme.surfaceBorder,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _category = cat;
                            _updateDefaultMaxWears(cat);
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Color Palette Preset Swatches
                const Text(
                  'COLOR PALETTE',
                  style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: AppTheme.accentCamel, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _palettePresets.map((p) {
                    final isSel = _selectedHexCode == p['hex'];
                    final color = _parseHex(p['hex']!);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedHexCode = p['hex']!;
                          _selectedColorName = p['name']!;
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSel ? AppTheme.accentGold : Colors.white24,
                            width: isSel ? 3.0 : 1.0,
                          ),
                          boxShadow: isSel
                              ? [BoxShadow(color: AppTheme.accentCamel.withValues(alpha: 0.5), blurRadius: 6)]
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 6),
                Text(
                  'Selected: $_selectedColorName ($_selectedHexCode)',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),

                // Formality Tier
                const Text(
                  'FORMALITY TIER',
                  style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: AppTheme.accentCamel, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildTierButton(1, 'Casual'),
                    const SizedBox(width: 8),
                    _buildTierButton(2, 'Smart Casual'),
                    const SizedBox(width: 8),
                    _buildTierButton(3, 'Tailored'),
                  ],
                ),
                const SizedBox(height: 16),

                // Max Wears Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'WASH CYCLE LIMIT',
                      style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: AppTheme.accentCamel, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '$_maxWears ${_maxWears == 1 ? "wear" : "wears"} before wash',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
                Slider(
                  value: _maxWears.toDouble(),
                  min: 1,
                  max: 15,
                  divisions: 14,
                  activeColor: AppTheme.accentCamel,
                  inactiveColor: AppTheme.surfaceLight,
                  onChanged: (val) {
                    setState(() {
                      _maxWears = val.round();
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final repo = Provider.of<WardrobeRepository>(context, listen: false);
                        final newGarment = Garment(
                          id: 'g-${DateTime.now().millisecondsSinceEpoch}-${_category.name}',
                          imageUrl: '',
                          category: _category,
                          subType: _nameController.text.trim(),
                          colorName: _selectedColorName,
                          hexCode: _selectedHexCode,
                          formalityTier: _formalityTier,
                          currentWears: 0,
                          maxWearsBeforeWash: _maxWears,
                          isInHamper: false,
                        );

                        await repo.addGarment(newGarment);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentCamel,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save to Wardrobe Vault',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTierButton(int tier, String label) {
    final isSel = _formalityTier == tier;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _formalityTier = tier),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? AppTheme.accentCamel : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSel ? AppTheme.accentCamel : AppTheme.surfaceBorder,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSel ? Colors.black : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
