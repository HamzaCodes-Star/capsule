import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/wardrobe_repository.dart';
import '../../../data/services/vision_ingestion_service.dart';
import '../../../domain/models/garment.dart';
import '../../core/theme/app_theme.dart';

class BatchCaptureScreen extends StatefulWidget {
  const BatchCaptureScreen({super.key});

  @override
  State<BatchCaptureScreen> createState() => _BatchCaptureScreenState();
}

class _BatchCaptureScreenState extends State<BatchCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final VisionIngestionService _visionService = VisionIngestionService();

  File? _capturedImage;
  bool _isAnalyzing = false;
  List<Garment> _detectedGarments = [];
  String? _statusText;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (picked != null) {
        // Persist permanently into Application Documents Directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'flatlay_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final permanentFile = await File(picked.path).copy('${appDir.path}/$fileName');

        setState(() {
          _capturedImage = permanentFile;
          _isAnalyzing = true;
          _statusText = 'AI Vision scanning garments on bed-spread...';
        });

        final results = await _visionService.analyzeBedSpreadImage(permanentFile.path);

        setState(() {
          _isAnalyzing = false;
          _detectedGarments = results;
          _statusText = null;
        });
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _statusText = 'Error analyzing image: $e';
      });
    }
  }

  void _simulateDemoIngestion() async {
    setState(() {
      _isAnalyzing = true;
      _statusText = 'Simulating Bed-Spread flat lay ingestion...';
    });

    await Future.delayed(const Duration(milliseconds: 1400));
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final simulated = [
      Garment(
        id: 'g-$timestamp-1',
        imageUrl: '',
        category: GarmentCategory.top,
        subType: 'Merino Wool Turtleneck',
        colorName: 'Camel / Warm Tan',
        hexCode: '#C19A6B',
        formalityTier: 2,
        currentWears: 0,
        maxWears: 3,
        inHamper: false,
      ),
      Garment(
        id: 'g-$timestamp-2',
        imageUrl: '',
        category: GarmentCategory.bottom,
        subType: 'Gurkha Chinos',
        colorName: 'Navy Blue',
        hexCode: '#1E293B',
        formalityTier: 2,
        currentWears: 0,
        maxWears: 3,
        inHamper: false,
      ),
      Garment(
        id: 'g-$timestamp-3',
        imageUrl: '',
        category: GarmentCategory.outerwear,
        subType: 'Minimal Harrington Jacket',
        colorName: 'Olive Green',
        hexCode: '#556B2F',
        formalityTier: 2,
        currentWears: 0,
        maxWears: 8,
        inHamper: false,
      ),
      Garment(
        id: 'g-$timestamp-4',
        imageUrl: '',
        category: GarmentCategory.footwear,
        subType: 'Suede Chelsea Boots',
        colorName: 'Espresso Brown',
        hexCode: '#3D2817',
        formalityTier: 2,
        currentWears: 0,
        maxWears: 10,
        inHamper: false,
      ),
    ];

    setState(() {
      _isAnalyzing = false;
      _detectedGarments = simulated;
      _statusText = null;
    });
  }

  Future<void> _commitGarments(WardrobeRepository repo) async {
    if (_detectedGarments.isEmpty) return;

    await repo.addGarments(_detectedGarments);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${_detectedGarments.length} pieces to your Wardrobe Vault!'),
          backgroundColor: AppTheme.accentCamel,
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {
        _detectedGarments = [];
        _capturedImage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<WardrobeRepository>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'COMPUTER VISION SCANNER',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2.5,
                color: AppTheme.accentCamel,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2),
            Text('Batch Ingestion', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions Hero Card
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.accentCamel.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bed, color: AppTheme.accentCamel),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'The Bed-Spread Flat Lay',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Lay up to 5 items flat on your bed or floor. Our Vision AI detects categories, dominant fabric colors, and fabric formality instantly.',
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Capture action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Flat Lay'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentCamel,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isAnalyzing ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, color: AppTheme.textPrimary),
                    label: const Text('Upload Photo', style: TextStyle(color: AppTheme.textPrimary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.surfaceBorder),
                      backgroundColor: AppTheme.surface,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Captured Image Preview if any
            if (_capturedImage != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Image.file(_capturedImage!, fit: BoxFit.cover),
                ),
              ),
            ],

            // Quick Demo Simulation Button (For instant testing without camera)
            Center(
              child: TextButton.icon(
                onPressed: _isAnalyzing ? null : _simulateDemoIngestion,
                icon: const Icon(Icons.flash_on, size: 16, color: AppTheme.accentCamel),
                label: const Text(
                  'Demo: Simulate 4-Piece Ingestion (Zero Wait)',
                  style: TextStyle(fontSize: 12, color: AppTheme.accentCamel, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Analyzing status
            if (_isAnalyzing) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentCamel.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: AppTheme.accentCamel),
                    const SizedBox(height: 16),
                    Text(
                      _statusText ?? 'AI Vision Segmenting Garments...',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Extracting HSL fabric colors, formality tiers & wear limits...',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Verification Rack
            if (_detectedGarments.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'VERIFICATION RACK (${_detectedGarments.length})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppTheme.accentCamel,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _detectedGarments = [];
                        _capturedImage = null;
                      });
                    },
                    child: const Text('Clear', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _detectedGarments.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final garment = _detectedGarments[index];
                  return _buildVerificationItem(garment, index);
                },
              ),
              const SizedBox(height: 20),

              // Save to Wardrobe CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _commitGarments(repo),
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: Text('Confirm & Save ${_detectedGarments.length} Items to Wardrobe'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCamel,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationItem(Garment garment, int index) {
    Color fabricColor;
    try {
      final hex = garment.hexCode.replaceAll('#', '');
      fabricColor = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      fabricColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: fabricColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        garment.category.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentCamel,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      garment.colorName,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  garment.subType,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppTheme.textMuted),
            onPressed: () {
              setState(() {
                _detectedGarments.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }
}
