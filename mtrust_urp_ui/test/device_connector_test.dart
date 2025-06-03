import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';
import 'package:mtrust_urp_ui/mtrust_urp_ui.dart';
import 'package:mtrust_urp_virtual_strategy/mtrust_urp_virtual_strategy.dart';

import 'mock_storage_adapter.dart';
import 'test_utils.dart';

Widget testHarness(Widget child) {
  return SizedBox(
    width: 300,
    height: 400,
    child: LdThemeProvider(
      child: LdThemedAppBuilder(
        appBuilder: (context, theme) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          localizationsDelegates: const [
            ...UrpUiLocalizations.localizationsDelegates,
            ...LiquidLocalizations.localizationsDelegates
          ],
          home: Scaffold(
            body: child,
          ),
        ),
      ),
    ),
  );
}

class DeviceConnectorTestHarness {
  late UrpVirtualStrategy virtualStrategy;
  late DeviceConnector deviceConnector;
  late StorageAdapter storageAdapter;

  Set<UrpDeviceType> deviceTypes;
  ReaderConnectorMode mode;

  DeviceConnectorTestHarness({
    this.deviceTypes = const {UrpDeviceType.urpSec},
    this.mode = ReaderConnectorMode.ephemeral,
    MockStorageAdapter? storageAdapter,
    List<FoundDevice> virtualReaders = const [],
  }) {
    virtualStrategy = UrpVirtualStrategy((request) async {
      return UrpResponse();
    });

    if (virtualReaders.isNotEmpty) {
      virtualStrategy.virtualReaders.addAll(virtualReaders);
    }

    this.storageAdapter = storageAdapter ?? MockStorageAdapter();
  }

  StreamController<FoundDevice> withReaderStream() {
    final streamController = StreamController<FoundDevice>.broadcast();
    virtualStrategy.virtualReadersStream = streamController.stream;
    return streamController;
  }

  FoundDevice withReader() {
    final reader = FoundDevice(
      name: 'Test Reader',
      type: UrpDeviceType.urpSec,
      address: '00:00:00:00:00:00',
    );

    virtualStrategy.virtualReadersStream = null;
    virtualStrategy.debugFailConnection = false;
    virtualStrategy.createVirtualReader(reader);

    return reader;
  }

  FoundDevice withPairedReader() {
    final reader = withReader();
    storageAdapter.persistPairedReader(reader);
    return reader;
  }

  FoundDevice withFlakyReader() {
    final reader = withReader();
    virtualStrategy.debugFailConnection = true;
    return reader;
  }

  FoundDevice withLastConnectedReader() {
    final readers = List.generate(
      3,
      (i) => FoundDevice(
        address: "00:00:00:00:00:0$i",
        name: "Test Reader $i",
        type: UrpDeviceType.urpSec,
      ),
    );

    for (final reader in readers) {
      virtualStrategy.createVirtualReader(reader);
    }

    storageAdapter.persistLastConnectedReader(readers[1]);
    return readers[1];
  }

  Widget build() {
    return testHarness(DeviceConnector(
      storageAdapter: storageAdapter,
      mode: mode,
      connectionStrategy: virtualStrategy,
      deviceTypes: deviceTypes,
      connectedBuilder: (context) => const Text('Connected'),
    ));
  }
}

void main() {
  group('DeviceConnector', () {
    setUpAll(() {
      urpUiDisableAnimations = true;
      ldDisableAnimations = true;
    });

    testWidgets('Strategy status guard', (WidgetTester tester) async {
      // Checks for the error messages different strategy statuses to be present

      for (final strategyStatus in StrategyAvailability.values) {
        final harness = DeviceConnectorTestHarness();

        harness.virtualStrategy.setAvailability(strategyStatus);

        await tester.pumpWidget(harness.build());
        await tester.pumpAndSettle();

        switch (strategyStatus) {
          case StrategyAvailability.unsupported:
            expectRichText(
              tester,
              'not available',
            );
          case StrategyAvailability.ready:
            expectRichText(
              tester,
              'No readers found',
            );
          case StrategyAvailability.disabled:
            expectRichText(
              tester,
              'disabled',
            );
          case StrategyAvailability.missingPermissions:
            expectRichText(
              tester,
              'Missing Virtual permissions',
            );
        }

        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('Ephemeral mode', (WidgetTester tester) async {
      final harness = DeviceConnectorTestHarness();

      await tester.pumpWidget(harness.build());

      await tester.pumpAndSettle();

      expectRichText(tester, 'No readers found');

      harness.withFlakyReader();

      await tester.tap(find.text('Search again'));
      await tester.pumpAndSettle();

      expectRichText(tester, 'Connect to Test Reader');

      await tester.tap(find.text('Connect to Test Reader'));

      await tester.pumpAndSettle();

      expectRichText(tester, 'Failed to connect');
      expectRichText(tester, 'Retry connection to Test Reader');

      /// Now try but we succeed

      harness.withReader();

      await tester.tap(find.text('Retry connection to Test Reader'));
      await tester.pumpAndSettle();
      expectRichText(tester, 'Connected');

      // Necessary because the last scan will time out.
      await tester.pump(const Duration(seconds: 10));

      return;
    });

    group('Prefer last mode', () {
      testWidgets('Selects correct reader from multiple',
          (WidgetTester tester) async {
        final harness = DeviceConnectorTestHarness(
          mode: ReaderConnectorMode.preferLastConnected,
        );

        harness.withLastConnectedReader();

        await tester.pumpWidget(harness.build());

        await tester.pumpAndSettle();

        expectRichText(tester, 'Connect to Test Reader 1');
        expectRichText(tester, 'Last used');
      });

      testWidgets('Flaky reader connection and retry',
          (WidgetTester tester) async {
        final harness = DeviceConnectorTestHarness(
          mode: ReaderConnectorMode.preferLastConnected,
        );

        // Add a flaky last connected reader
        harness.withLastConnectedReader();
        harness.virtualStrategy.debugFailConnection = true;

        await tester.pumpWidget(harness.build());
        await tester.pumpAndSettle();

        expectRichText(tester, 'Connect to Test Reader 1');

        await tester.tap(find.text('Connect to Test Reader 1'));
        await tester.pumpAndSettle();

        expectRichText(tester, 'Failed to connect');
        expectRichText(tester, 'Retry connection to Test Reader 1');

        // Now make the reader non-flaky and retry
        harness.virtualStrategy.debugFailConnection = false;
        await tester.tap(find.text('Retry connection to Test Reader 1'));
        await tester.pumpAndSettle();

        expectRichText(tester, 'Connected');

        // Necessary because the last scan will time out.
        await tester.pump(const Duration(seconds: 10));
      });

      testWidgets('Flaky reader, user chooses different reader',
          (WidgetTester tester) async {
        final harness = DeviceConnectorTestHarness(
          mode: ReaderConnectorMode.preferLastConnected,
        );

        // Add a flaky last connected reader
        harness.withLastConnectedReader();
        harness.virtualStrategy.debugFailConnection = true;

        await tester.pumpWidget(harness.build());
        await tester.pumpAndSettle();

        expectRichText(tester, 'Connect to Test Reader 1');

        await tester.tap(find.text('Connect to Test Reader 1'));
        await tester.pumpAndSettle();

        expectRichText(tester, 'Failed to connect');
        expectRichText(tester, 'Retry connection to Test Reader 1');

        expect(find.text('Connect different reader'), findsOneWidget);

        // User chooses to connect to a different reader
        await tester.tap(find.text('Connect different reader'));
        await tester.pumpAndSettle();

        // Should now show the picker again

        expectRichText(tester, '3 readers found');
      });
    });

    group('Paired mode', () {
      testWidgets('No paired reader with multiple readers',
          (WidgetTester tester) async {
        final harness = DeviceConnectorTestHarness(
          mode: ReaderConnectorMode.pair,
        );

        harness.virtualStrategy.createVirtualReader(
          FoundDevice(
            name: 'Test Reader',
            type: UrpDeviceType.urpSec,
            address: '00:00:00:00:00:00',
          ),
        );

        harness.virtualStrategy.createVirtualReader(
          FoundDevice(
            name: 'Test Reader 2',
            type: UrpDeviceType.urpSec,
            address: '00:00:00:00:00:01',
          ),
        );

        harness.virtualStrategy.createVirtualReader(
          FoundDevice(
            name: 'Test Reader 3',
            type: UrpDeviceType.urpImp,
            address: '00:00:00:00:00:02',
          ),
        );

        await tester.pumpWidget(harness.build());

        await tester.pumpAndSettle();

        expectRichText(tester, 'Connect to Test Reader 2');
        expectRichText(tester, '2 readers found');

        await tester.tap(find.text('Connect to Test Reader 2'));

        final pairedReader = await harness.storageAdapter.getPairedReader();
        expect(pairedReader, isNotNull);
        expect(pairedReader?.name, 'Test Reader 2');

        await tester.pump(const Duration(seconds: 10));
      });

      testWidgets('Paired reader not found', (WidgetTester tester) async {
        final harness = DeviceConnectorTestHarness(
          mode: ReaderConnectorMode.pair,
        );

        harness.withPairedReader();

        final streamController = harness.withReaderStream();

        await tester.pumpWidget(harness.build());
        await tester.pumpAndSettle();

        // Should show waiting for paired device
        expectRichText(tester, 'Looking for Test Reader');

        streamController.close();
        await tester.pumpAndSettle();

        expectRichText(tester, 'Failed to connect to reader');
        expectRichText(tester, 'Retry connection to Test Reader');
      });

      testWidgets('Paired reader found', (WidgetTester tester) async {
        final harness = DeviceConnectorTestHarness(
          mode: ReaderConnectorMode.pair,
        );

        harness.withPairedReader();

        await tester.pumpWidget(harness.build());
        await tester.pumpAndSettle();

        expectRichText(tester, 'Connected');

        // Necessary because the last scan will time out.
        await tester.pump(const Duration(seconds: 10));
      });

      testWidgets('Paired mode - paired flaky reader',
          (WidgetTester tester) async {
        final harness = DeviceConnectorTestHarness(
          mode: ReaderConnectorMode.pair,
        );

        harness.withPairedReader();
        harness.virtualStrategy.debugFailConnection = true;

        await tester.pumpWidget(harness.build());
        await tester.pumpAndSettle();

        expectRichText(tester, 'Failed to connect to reader');
        expectRichText(tester, 'Retry connection to Test Reader');

        harness.virtualStrategy.debugFailConnection = false;

        await tester.tap(find.text('Retry connection to Test Reader'));
        await tester.pumpAndSettle();

        expectRichText(tester, 'Connected');

        // Necessary because the last scan will time out.
        await tester.pump(const Duration(seconds: 10));
      });
    });
  });
}
