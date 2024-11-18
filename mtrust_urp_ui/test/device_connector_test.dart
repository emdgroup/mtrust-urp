import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mtrust_urp_ui/mtrust_urp_ui.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

import 'golden_utils.dart';
import 'test_utils.dart';

void main() {
  testGoldens('DeviceConnector', (WidgetTester test) async {
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
      "DeviceConnector",
      {
        'Idle': (tester, place) async {
          final connectionStrategy = securalicVirtualStrategy();
          await place(
            AspectRatio(
              aspectRatio: 1,
              child: DeviceConnector(
                storageAdapter: storageAdapter,
                mode: ReaderConnectorMode.ephemeral,
                connectionStrategy: connectionStrategy,
                connectedBuilder: (context) => const Text('Connected'),
                deviceTypes: const {UrpDeviceType.urpSec},
              ),
            ),
          );
        },
        'Connect to device': (tester, place) async {
          final connectionStrategy = securalicVirtualStrategy(
            withReaders: true,
          );
          await place(
            AspectRatio(
              aspectRatio: 1,
              child: DeviceConnector(
                storageAdapter: storageAdapter,
                mode: ReaderConnectorMode.ephemeral,
                connectionStrategy: connectionStrategy,
                connectedBuilder: (context) => const Text('Connected'),
                deviceTypes: const {UrpDeviceType.urpSec},
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key("connect_button")));
        },
        'Failed Connection': (tester, place) async {
          final connectionStrategy = securalicVirtualStrategy(
            withReaders: true,
          );
          connectionStrategy.debugFailConnection = true;
          await place(
            AspectRatio(
              aspectRatio: 1,
              child: DeviceConnector(
                storageAdapter: storageAdapter,
                mode: ReaderConnectorMode.ephemeral,
                connectionStrategy: connectionStrategy,
                connectedBuilder: (context) => const Text('Connected'),
                deviceTypes: const {UrpDeviceType.urpSec},
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key("connect_button")));
          await tester.pumpAndSettle();
        }
      },
      width: 500,
    );
  });
}
