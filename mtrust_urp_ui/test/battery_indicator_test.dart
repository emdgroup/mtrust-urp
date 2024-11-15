import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mtrust_urp_ui/mtrust_urp_ui.dart';

import 'golden_utils.dart';
import 'test_utils.dart';

void main() {
  testGoldens('BatteryIndicator', (WidgetTester test) async {
    urpUiDisableAnimations = true;

    final storageAdapter = MockStorageAdapter();

    when(() => storageAdapter.getPairedReader()).thenAnswer(
      (_) async => null,
    );
    when(() => storageAdapter.getLastConnectedReader()).thenAnswer(
      (_) async => null,
    );

    await multiGolden(
      test,
      "BatteryIndicator",
      {
        'Empty': (tester, place) async {
          await place(const BatteryIndicator(percentage: 0));
        },
        '20percent': (tester, place) async {
          await place(const BatteryIndicator(percentage: 20));
        },
        '75percent': (tester, place) async {
          await place(const BatteryIndicator(percentage: 75));
        },
        '100percent': (tester, place) async {
          await place(const BatteryIndicator(percentage: 100));
        },
      },
      width: 150,
    );
  });
}
