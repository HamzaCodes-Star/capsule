import 'package:flutter_test/flutter_test.dart';
import 'package:capsule/main.dart';
import 'package:capsule/data/repositories/wardrobe_repository.dart';
import 'package:capsule/ui/features/daily_stylist/daily_stylist_viewmodel.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('CapsuleApp basic smoke test', (WidgetTester tester) async {
    final wardrobeRepo = WardrobeRepository();
    final dailyVM = DailyStylistViewModel();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<WardrobeRepository>.value(value: wardrobeRepo),
          ChangeNotifierProvider<DailyStylistViewModel>.value(value: dailyVM),
        ],
        child: const CapsuleApp(),
      ),
    );

    expect(find.text('Start Bed-Spread Scan'), findsOneWidget);
  });
}
