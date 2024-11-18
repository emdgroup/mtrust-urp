import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mtrust_urp_ui/mtrust_urp_ui.dart';
import 'package:mtrust_urp_ui/src/device_connector/strategy_status.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

import 'golden_utils.dart';
import 'test_utils.dart';

void main() {
  testGoldens('StrategyStatusGuard', (WidgetTester test) async {
    urpUiDisableAnimations = true;

    await multiGolden(
      test,
      "StrategyStatusGuard",
      Map.fromEntries(
        StrategyAvailability.values.map(
          (status) {
            return MapEntry(
              status.toString().split('.').last,
              (tester, place) async {
                final strategy = securalicVirtualStrategy();
                strategy.setAvailability(status);
                await place(
                  AspectRatio(
                    aspectRatio: 1,
                    child: StrategyAvailabilityGuard(
                      strategy: strategy,
                      readyBuilder: (context) => const Center(
                        child: Text('Ready'),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  });
}
