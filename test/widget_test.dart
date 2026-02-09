
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:deep_sea_oversea/ui/screens/game_screen.dart';
import 'package:deep_sea_oversea/providers/economy_provider.dart';
import 'package:mockito/mockito.dart';

// Mock Provider
class MockEconomyProvider extends ChangeNotifier implements EconomyProvider {
  @override
  double getResourceAmount(String resourceId) => 100.0;
  
  @override
  double get mineralsPerSecond => 5.0;
  
  @override
  bool get isInitialized => true;

  @override
  void manualClick() {}
  
  // Stubs for other members to satisfy interface...
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('GameScreen renders resource amount', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<EconomyProvider>(
          create: (_) => MockEconomyProvider(),
          child: const GameScreen(),
        ),
      ),
    );

    // Verify static texts
    expect(find.text('MINERALS'), findsOneWidget);
    expect(find.text('PER SEC'), findsOneWidget);
    
    // Verify mocked values
    expect(find.text('100'), findsOneWidget);
    expect(find.text('+5.0'), findsOneWidget);
    
    // Verify tap interaction
    await tester.tap(find.text('TAP TO MINE'));
    await tester.pump();
  });
}
