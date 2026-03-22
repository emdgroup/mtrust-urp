import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

/// A device found by the BLE scan
/// adds additional information about the connection status and a reference
/// to the [BluetoothDevice]
class FoundBleDevice extends FoundDevice {
  final BluetoothDevice bleDevice;
  bool connected = false;

  FoundBleDevice({
    required super.address,
    required super.name,
    required super.type,
    required this.connected,
    required this.bleDevice,
  });

  @override
  bool operator ==(Object other) {
    if (other is FoundBleDevice) {
      return other.address == address && other.connected == connected;
    }
    return false;
  }
}
