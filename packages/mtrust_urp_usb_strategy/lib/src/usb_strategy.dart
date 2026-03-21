// This is the esp32 PID
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

int readerProductId = 4097; //32976;

class UrpUsbOpenException extends Error {}

class UrpUsbReadException extends Error {}

/// Handles connecting to the reader via usb
class UrpUsbStrategy extends ConnectionStrategy {
  ConnectionStatus _status = ConnectionStatus.idle;

  ConnectionStatus get status => _status;

  String get name => "USB";

  void _setStatus(ConnectionStatus status) {
    _status = status;
    urpLogger.t("USBStrategy status: $status");
    notifyListeners();
  }

  StreamSubscription<String>? _subscription;
  SerialPortReader? _reader;
  SerialPort? _port;

  Future<List<String>> _getPorts() async {
    _setStatus(ConnectionStatus.searching);
    var devices = SerialPort.availablePorts;

    var results = <String>[];

    for (var element in devices) {
      try {
        var port = SerialPort(element);
        urpLogger
          ..t("USBStrategy: Found device: $element")
          ..t("USBStrategy: Product ID: " + port.productId.toString())
          ..t("USBStrategy: Manufacturer: " + port.manufacturer.toString())
          ..t("USBStrategy: Product name: " + port.productName.toString());

        if (port.productId == readerProductId) {
          urpLogger.t("Correct product found: $element");
          results.add(element);
        } else {
          urpLogger.t("Wrong product, ignoring $element");
        }
      } catch (e) {
        print(e);
      }
    }

    return results;
  }

  Future<void> _connectTo(String deviceAddress) async {
    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }

    // Abandon previous connection

    disconnectDevice();

    // Create port
    _port = SerialPort(deviceAddress);
    _setStatus(ConnectionStatus.connecting);

    // Open the port

    if (!_port!.openReadWrite()) {
      urpLogger.e("Could not open port: $deviceAddress");
      throw Exception("Could not open port: $deviceAddress");
    }

    urpLogger.t("Configuring port");

    _port!.config = SerialPortConfig()
      ..baudRate = 115200
      ..bits = 8
      ..stopBits = 1
      ..parity = 0;

    urpLogger.t("USBStrategy: Baud rate: ${_port!.config.baudRate}");
    urpLogger.t("USBStrategy: Bits: ${_port!.config.bits}");
    urpLogger.t("USBStrategy: Stop bits: ${_port!.config.stopBits}");
    urpLogger.t("USBStrategy: Parity: ${_port!.config.parity}");

    _reader = SerialPortReader(_port!);

    _reader!.stream.listen((event) {
      onData(event);
    });

    _setStatus(ConnectionStatus.connected);
    onConnectCallback?.call();
  }

  @override
  void output(Uint8List bytes) {
    if (_port == null) {
      return null;
    }

    try {
      _port!.write(bytes);
    } catch (e) {
      urpLogger.e("USBStrategy: Port is closed");
      disconnectDevice();
      throw e;
    }
  }

  Stream<Uint8List>? get input {
    return _reader?.stream;
  }

  Future<void> disconnectDevice() async {
    try {
      _port?.close();
      _subscription?.cancel();
    } catch (e) {
      urpLogger.e("USBStrategy: Error disconnecting reader: $e");
    }

    super.disconnectDevice();

    _setStatus(ConnectionStatus.idle);
    onDisconnectCallback?.call();
  }

  void dispose() {
    super.dispose();
    disconnectDevice();
  }

  @override
  Future<bool> findAndConnectDevice(
      {String? deviceAddress, required Set<UrpDeviceType> readerTypes}) async {
    var readers = await _getPorts();

    if (readers.isEmpty) {
      urpLogger.e("USBStrategy: No readers found");
      throw Exception("No readers found");
    }

    await _connectTo(readers.first);
    return true;
  }

  @override
  Stream<FoundDevice> findDevices(Set<UrpDeviceType> readerTypes) {
    throw UnimplementedError();
  }

  @override
  Future<StrategyAvailability> get availability async {
    if (kIsWeb || Platform.isIOS || Platform.isAndroid) {
      return StrategyAvailability.unsupported;
    }

    return StrategyAvailability.ready;
  }
}
