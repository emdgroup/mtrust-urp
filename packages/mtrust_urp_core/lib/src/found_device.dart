import 'dart:convert';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

/// A device that was found during scan
class FoundDevice {
  /// Creates a new [FoundDevice]
  FoundDevice({required this.address, required this.name, required this.type});

  /// Creates a [FoundDevice] from a map
  factory FoundDevice.fromMap(Map<String, dynamic> map) {
    return FoundDevice(
      address: map['address'] as String,
      name: map['name'] as String,
      type: UrpDeviceType.values.firstWhere(
        (element) => element.toString() == map['type'] as String,
      ),
    );
  }

  /// Creates a [FoundDevice] from a JSON string
  factory FoundDevice.fromJson(String source) => FoundDevice.fromMap(
        jsonDecode(source) as Map<String, dynamic>,
      );

  /// Address of the device
  final String address;

  /// Name of the device
  final String name;

  /// Type of device found
  final UrpDeviceType type;

  @override
  String toString() {
    return 'FoundDevice{address: $address, name: $name, type: $type}';
  }

  /// Converts the [FoundDevice] to a map
  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'name': name,
      'type': type.toString(),
    };
  }

  /// Converts the [FoundDevice] to a JSON string
  String toJson() {
    return jsonEncode(toMap());
  }
}
