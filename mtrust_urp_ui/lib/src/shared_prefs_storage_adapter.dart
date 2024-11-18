import 'package:mtrust_urp_ui/src/storage_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

class SharedPrefsStorageAdapter extends StorageAdapter {
  SharedPreferences? _prefs;

  SharedPrefsStorageAdapter(super.key);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> clearPersistedReader() async {
    if (_prefs == null) {
      await init();
    }
    await _prefs!.remove("${key}_last_connected");
  }

  @override
  Future<FoundDevice?> getLastConnectedReader() async {
    if (_prefs == null) {
      await init();
    }
    final stored = _prefs!.getString("${key}_last_connected");
    if (stored == null) {
      return null;
    }
    return FoundDevice.fromJson(stored);
  }

  @override
  Future<void> persistLastConnectedReader(FoundDevice reader) async {
    if (_prefs == null) {
      await init();
    }
    await _prefs!.setString("${key}_last_connected", reader.toJson());
  }

  @override
  Future<FoundDevice?> getPairedReader() async {
    if (_prefs == null) {
      await init();
    }
    final stored = _prefs!.getString(key);

    if (stored == null) {
      return null;
    }

    return FoundDevice.fromJson(stored);
  }

  @override
  Future<void> persistPairedReader(FoundDevice reader) async {
    if (_prefs == null) {
      await init();
    }
    await _prefs!.setString(key, reader.toJson());
  }

  @override
  Future<void> clearPairedReader() async {
    if (_prefs == null) {
      await init();
    }
    await _prefs!.remove(key);
  }
}
