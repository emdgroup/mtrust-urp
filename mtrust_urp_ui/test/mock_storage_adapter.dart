// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';
import 'package:mtrust_urp_ui/src/storage_adapter.dart';

class MockStorageAdapter implements StorageAdapter {
  FoundDevice? lastConnectedReader;
  FoundDevice? pairedReader;

  @override
  Future<void> clearPairedReader() async {
    pairedReader = null;
  }

  @override
  Future<void> clearPersistedReader() async {
    lastConnectedReader = null;
  }

  @override
  Future<FoundDevice?> getLastConnectedReader() {
    return Future.value(lastConnectedReader);
  }

  @override
  Future<FoundDevice?> getPairedReader() {
    return Future.value(pairedReader);
  }

  @override
  String get key => 'test';

  @override
  Future<void> persistLastConnectedReader(FoundDevice reader) async {
    lastConnectedReader = reader;
  }

  @override
  Future<void> persistPairedReader(FoundDevice reader) async {
    pairedReader = reader;
  }
}
