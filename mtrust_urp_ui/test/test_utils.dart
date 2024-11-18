import 'package:mocktail/mocktail.dart';
import 'package:mtrust_urp_ui/src/storage_adapter.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';
import 'package:mtrust_urp_virtual_strategy/mtrust_urp_virtual_strategy.dart';

import 'package:mtrust_urp_types/sec.pb.dart';

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

class MockStorageAdapter extends Mock implements StorageAdapter {}
