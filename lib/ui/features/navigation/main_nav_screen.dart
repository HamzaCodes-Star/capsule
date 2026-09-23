import 'package:flutter/material.dart';
import '../daily_stylist/daily_stylist_screen.dart';
import '../wardrobe/wardrobe_screen.dart';
import '../batch_capture/batch_capture_screen.dart';
import '../lookbook/lookbook_screen.dart';
import '../settings/settings_screen.dart';
import '../../core/theme/app_theme.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DailyStylistScreen(),
    WardrobeScreen(),
    BatchCaptureScreen(),
    LookbookScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.surfaceBorder, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.style_outlined),
              activeIcon: Icon(Icons.style),
              label: 'Stylist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checkroom_outlined),
              activeIcon: Icon(Icons.checkroom),
              label: 'Wardrobe',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_enhance_outlined),
              activeIcon: Icon(Icons.camera_enhance),
              label: 'Ingest',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories_outlined),
              activeIcon: Icon(Icons.auto_stories),
              label: 'Lookbook',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
