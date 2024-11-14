import 'package:mtrust_urp_core/mtrust_urp_core.dart';

abstract class StorageAdapter {
  final String key;

  StorageAdapter(this.key);

  Future<void> persistLastConnectedReader(FoundDevice reader);
  Future<FoundDevice?> getLastConnectedReader();

  Future<void> persistPairedReader(FoundDevice reader);
  Future<FoundDevice?> getPairedReader();

  Future<void> clearPersistedReader();
  Future<void> clearPairedReader();
}
