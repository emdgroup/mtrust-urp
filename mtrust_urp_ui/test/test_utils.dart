// ignore_for_file: avoid_print

import 'package:flutter/material.dart' hide Image;
import 'package:mtrust_urp_core/mtrust_urp_core.dart';
import 'package:mtrust_urp_virtual_strategy/mtrust_urp_virtual_strategy.dart';

import 'package:mtrust_urp_types/sec.pb.dart';
import 'package:flutter_test/flutter_test.dart';

UrpVirtualStrategy securalicVirtualStrategy({bool withReaders = false}) {
  final strategy = UrpVirtualStrategy((UrpRequest request) async {
    final payload = UrpSecCommandWrapper.fromBuffer(request.payload);
    return switch (payload.deviceCommand.command) {
      (UrpSecCommand.urpSecPrime) => UrpResponse(),
      (UrpSecCommand.urpSecStartMeasurement) => UrpResponse(),
      _ => null,
    };
  });

  strategy.simulateDelays = false;

  if (withReaders) {
    strategy.createVirtualReader(FoundDevice(
      name: "SEC-000123",
      type: UrpDeviceType.urpSec,
      address: "00:00:00:00:00:00",
    ));

    strategy.createVirtualReader(FoundDevice(
      name: "SEC-000124",
      type: UrpDeviceType.urpSec,
      address: "00:00:00:00:00:02",
    ));

    strategy.createVirtualReader(FoundDevice(
      name: "IMP-000123",
      type: UrpDeviceType.urpImp,
      address: "00:00:00:00:00:01",
    ));
  }

  return strategy;
}

void expectRichText(WidgetTester tester, String text) {
  expect(
    find.byWidgetPredicate(
      (widget) =>
          widget is RichText && widget.text.toPlainText().contains(text),
    ),
    findsOneWidget,
  );
}
