import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'data/repositories/wardrobe_repository.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/daily_stylist/daily_stylist_viewmodel.dart';
import 'ui/features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final wardrobeRepository = WardrobeRepository();
  await wardrobeRepository.loadWardrobe();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<WardrobeRepository>.value(value: wardrobeRepository),
        ChangeNotifierProvider<DailyStylistViewModel>(create: (_) => DailyStylistViewModel()),
      ],
      child: const CapsuleApp(),
    ),
  );
}

class CapsuleApp extends StatelessWidget {
  const CapsuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capsule',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const OnboardingScreen(),
    );
  }
}
