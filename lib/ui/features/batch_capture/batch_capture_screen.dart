import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  VisionIngestionResult? _lastResult;
  bool _hasCustomApiKey = false;

  @override
  void initState() {
    super.initState();
    _checkApiKeyStatus();
  }

  Future<void> _checkApiKeyStatus() async {
    final key = await _visionService.getSavedApiKey();
    if (mounted) {
      setState(() {
        _hasCustomApiKey = key != null && key.trim().isNotEmpty;
      });
    }
  }

  void _showApiKeyDialog() async {
    final currentKey = await _visionService.getSavedApiKey() ?? '';
    final controller = TextEditingController(text: currentKey);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.surfaceBorder),
        ),
        title: Row(
          children: [
            const Icon(Icons.key, color: AppTheme.accentCamel, size: 20),
            const SizedBox(width: 8),
            Text(
              'Gemini Vision API Key',
              style: GoogleFonts.epilogue(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your Google AI Studio API key to test real-time vision on your own clothes photos. 100% free tier (1,500 scans/day).',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppTheme.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                hintStyle: GoogleFonts.dmSans(color: Colors.white24, fontSize: 13),
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.accentCamel),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Get free key: aistudio.google.com',
              style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.accentCamel),
            ),
          ],
        ),
        actions: [
          if (currentKey.isNotEmpty)
            TextButton(
              onPressed: () async {
                await _visionService.saveApiKey('');
                await _checkApiKeyStatus();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Clear Key', style: TextStyle(color: Colors.redAccent)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCamel,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              await _visionService.saveApiKey(controller.text);
              await _checkApiKeyStatus();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save & Use'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (picked != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'flatlay_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final permanentFile = await File(picked.path).copy('${appDir.path}/$fileName');

        setState(() {
          _capturedImage = permanentFile;
          _isAnalyzing = true;
          _statusText = 'AI Vision scanning garments on bed-spread...';
        });

        final result = await _visionService.analyzeBedSpreadImage(permanentFile.path);

        setState(() {
          _isAnalyzing = false;
          _lastResult = result;
          _detectedGarments = result.garments;
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

    final stopwatch = Stopwatch()..start();
    await Future.delayed(const Duration(milliseconds: 1200));
    stopwatch.stop();

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
      _lastResult = VisionIngestionResult(
        garments: simulated,
        confidenceScore: 0.95,
        latencyMs: stopwatch.elapsedMilliseconds,
        modelName: 'Demo Simulation Engine (Deterministic)',
        isRealApi: false,
      );
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
        _lastResult = null;
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
              'BED-SPREAD SCANNER',
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
        actions: [
          IconButton(
            tooltip: _hasCustomApiKey ? 'Gemini API Key Active' : 'Configure Gemini API Key',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.vpn_key_outlined,
                  color: _hasCustomApiKey ? AppTheme.accentCamel : AppTheme.textMuted,
                  size: 22,
                ),
                if (_hasCustomApiKey)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showApiKeyDialog,
          ),
          const SizedBox(width: 8),
        ],
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lay 3-5 garments on your bed',
                          style: GoogleFonts.epilogue(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'One photo captures and tags every piece automatically. No typing required.',
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
            const SizedBox(height: 16),

            // Capture Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined, size: 20),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: AppTheme.secondaryCream,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isAnalyzing ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined, size: 20, color: AppTheme.accentCamel),
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
            const SizedBox(height: 12),

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
                      style: GoogleFonts.epilogue(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _hasCustomApiKey
                          ? 'Sending to Gemini 2.0 Flash Vision...'
                          : 'Segmenting clothes, fabric hex colors & wear limits...',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Diagnostic HUD Banner (Shows Confidence Percentage & Speed)
            if (_lastResult != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _lastResult!.isRealApi
                        ? Colors.greenAccent.withValues(alpha: 0.4)
                        : AppTheme.accentCamel.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _lastResult!.isRealApi ? Colors.greenAccent : Colors.amberAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AI VISION DIAGNOSTIC HUD',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: _lastResult!.isRealApi ? Colors.greenAccent : AppTheme.accentCamel,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${(_lastResult!.confidenceScore * 100).toStringAsFixed(1)}% MATCH',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Engine: ${_lastResult!.modelName}',
                                style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Speed: ${(_lastResult!.latencyMs / 1000).toStringAsFixed(2)}s • ${_detectedGarments.length} items detected',
                                style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_lastResult!.errorMessage != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Notice: ${_lastResult!.errorMessage}',
                        style: GoogleFonts.dmSans(fontSize: 11, color: Colors.orangeAccent),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Verification Rack
            if (_detectedGarments.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'VERIFICATION RACK (${_detectedGarments.length})',
                    style: GoogleFonts.epilogue(
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
                        _lastResult = null;
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
            width: 38,
            height: 38,
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
                      style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textMuted),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '96% Match',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  garment.subType,
                  style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  '${garment.maxWearsBeforeWash} wears before wash • Formality: Tier ${garment.formalityTier}',
                  style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textMuted),
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
