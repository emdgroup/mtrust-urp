import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';
import 'package:async/async.dart';

import 'found_ble_device.dart';

class BleNotEnabledException implements Exception {}

class BleUnsupportedException implements Exception {}

class UrpBleStrategy extends ConnectionStrategy {
  Set<String> bleCharacteristicIds = Set();
  Set<String> bleServiceIds = Set();

  String get name => "Bluetooth";

  static String _batteryServiceUUID = '0000180F-0000-1000-8000-00805F9B34FB';
  static String _batteryCharacteristicUUI =
      '00002A19-0000-1000-8000-00805F9B34FB';

  // Ble
  BluetoothDevice? _device;
  BluetoothCharacteristic? _characteristic;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _deviceSubscription;
  StreamSubscription<List<int>>? _characteristicSubscription;
  StreamSubscription<List<int>>? _batteryCharacteristicSubscription;

  bool initialized = false;

  Timer? _queueTimer;

  List<Uint8List> _cmdQueue = [];

  Set<BluetoothDevice> foundDevices = {};

  UrpBleStrategy() {
    if (Platform.isIOS || Platform.isAndroid) {
      FlutterBluePlus.setLogLevel(LogLevel.warning);
    }
  }

  @protected
  BluetoothDevice? get device => _device;

  @override
  Future<void> disconnectDevice() async {
    _scanSubscription?.cancel();
    _deviceSubscription?.cancel();
    _characteristicSubscription?.cancel();
    _batteryCharacteristicSubscription?.cancel();
    _characteristic = null;

    _device?.disconnect();
    _cmdQueue = [];
    _device = null;
    setStatus(ConnectionStatus.idle);

    super.disconnectDevice();
  }

  @override
  dispose() {
    _queueTimer?.cancel();
    disconnectDevice();
    super.dispose();
  }

  @override

  /// Will try to find a reader of the given type. If a deviceAddress is given, it will try to connect to that device.
  /// If no deviceAddress is given, it will scan for devices and connect to the first one found.
  /// Returns [true] if the connection was successful, [false] otherwise.
  Future<bool> findAndConnectDevice(
      {String? deviceAddress, required Set<UrpDeviceType> readerTypes}) async {
    _applyIds(readerTypes);

    if (!await FlutterBluePlus.isSupported) {
      throw BleUnsupportedException();
    }

    if ((await FlutterBluePlus.adapterState.first) !=
        BluetoothAdapterState.on) {
      throw BleNotEnabledException();
    }

    FoundBleDevice? device;

    await for (final item in _scanForDevices()) {
      if (deviceAddress == null || item.address == deviceAddress) {
        device = item;
        break;
      }
    }

    if (device == null) {
      return false;
    }

    if (device.connected) {
      urpLogger.d("Device was already connected");
      await device.bleDevice.disconnect();
      await disconnectDevice();
    } else {
      await disconnectDevice();
      await _connectToDevice(device.bleDevice);
    }

    if (status == ConnectionStatus.connected) {
      return true;
    }
    setStatus(ConnectionStatus.idle);
    return false;
  }

  /// Returns a list of all available devices that are found when scanning
  /// if [continueImmediately] is true, the scanning will be stopped after
  /// the first device is found
  Stream<FoundDevice> findDevices(
    Set<UrpDeviceType> readerTypes,
  ) {
    _applyIds(readerTypes);

    return _scanForDevices();
  }

  @override
  void output(Uint8List bytes) {
    writeValue(bytes);
  }

  UrpDeviceType readerTypeFromServiceId(String serviceId) {
    return BleServiceUUIDs.entries
        .firstWhere((element) => element.value == serviceId)
        .key;
  }

  Future<bool> writeValue(Uint8List value) async {
    _cmdQueue.add(value);
    _queueNextCmd();

    return true;
  }

  void _applyIds(Set<UrpDeviceType> readerTypes) {
    assert(readerTypes.isNotEmpty, "Reader types cannot be empty");

    bleServiceIds =
        readerTypes.map((e) => BleServiceUUIDs[e]!.toLowerCase()).toSet();
    bleCharacteristicIds =
        readerTypes.map((e) => (BleTXCharacteristicUUIDs[e]!)).toSet();
  }

  Future<List<FoundBleDevice>> _checkAlreadyConnectedDevices() async {
    var alreadyConnected = await FlutterBluePlus.connectedDevices;

    List<FoundBleDevice> connectedDevices = [];

    for (var device in alreadyConnected) {
      if (await device.connectionState.first ==
          BluetoothConnectionState.connected) {
        try {
          var services = await device.discoverServices();

          for (var service in services) {
            final serviceId = service.uuid.toString().toLowerCase();
            if (bleServiceIds.contains(serviceId)) {
              urpLogger.d(
                  "Found a matching device ${device.platformName} already connected");
              connectedDevices.add(
                FoundBleDevice(
                  address: device.remoteId.str,
                  connected: true,
                  name: device.platformName,
                  type: readerTypeFromServiceId(serviceId),
                  bleDevice: device,
                ),
              );
              break;
            }
          }
        } catch (e) {
          urpLogger.e("Error while checking connected devices: $e");
          try {
            device.disconnect();
          } catch (e) {
            urpLogger.e("Error while disconnecting device: $e");
          }
        }
      }
    }

    return connectedDevices;
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (_device != null) {
      return;
    }

    urpLogger.d("Connecting to device");

    setStatus(ConnectionStatus.connecting);
    _device = device;

    _deviceSubscription?.cancel();

    var state = await device.connectionState.first;

    if (state == BluetoothConnectionState.connected) {
      return;
    }

    try {
      urpLogger.d("Trying to connect to device...");

      await device.connect(
          timeout: const Duration(seconds: 5), autoConnect: false);

      if (Platform.isAndroid) {
        await _device?.requestMtu(512);
      }

      _deviceSubscription = device.connectionState.listen(_deviceStateChanged);

      urpLogger.d("Connected to device.. Discovering services..");

      await _discoverCharacteristic(device);
    } catch (e) {
      print(e);
      disconnectDevice();
    }
  }

  void _deviceStateChanged(BluetoothConnectionState event) async {
    if (event == BluetoothConnectionState.connected) {
      if (_device == null) {
        disconnectDevice();
      }
    }

    if (event == BluetoothConnectionState.disconnected) {
      disconnectDevice();
    }
  }

  // Discovering characteristics
  Future<void> _discoverCharacteristic(BluetoothDevice device) async {
    var services = await device.discoverServices();

    urpLogger.d("_discoverCharacteristic");

    // Find the matching service

    final service = services.firstWhereOrNull(
      (element) => bleServiceIds.contains(
        element.uuid.toString().toLowerCase(),
      ),
    );

    if (service == null) {
      urpLogger.w("No matching service found for device");
      return;
    }
    urpLogger.d("Found service");

    _characteristic = service.characteristics.firstWhereOrNull(
      (element) => bleCharacteristicIds.contains(element.uuid.toString()),
    );

    if (_characteristic != null) {
      await _characteristic?.setNotifyValue(true);
      _characteristicSubscription = _characteristic!.lastValueStream.listen(
        _onCharacteristicUpdate,
      );

      setStatus(ConnectionStatus.connected);
      onConnectCallback?.call();
    } else {
      urpLogger.w("Characteristic was null");
      disconnectDevice();
    }
    _getBatteryCharacteristic();
  }

  /// called when batteryCharacteristic value changes.
  int _parseBatteryCharacteristicUpdate(List<int> data) {
    int batteryLevel = data.first;
    urpLogger.d('Battery level: ${batteryLevel}%');
    return batteryLevel;
  }

  /// called when the characteristic value changes.
  _onCharacteristicUpdate(List<int> data) async {
    onData(Uint8List.fromList(data));
  }

  void _queueNextCmd() async {
    if (_cmdQueue.isNotEmpty && _characteristic != null) {
      final value = _cmdQueue[0];
      _cmdQueue.removeAt(0);
      try {
        // Chunk the data into max 512 byte chunks
        for (var i = 0; i < value.length; i += 512) {
          final chunk = value.sublist(i, i + 512 > value.length ? value.length : i + 512);
          await _characteristic?.write(chunk).timeout(Duration(seconds: 5));
        }
      } catch (e) {
        urpLogger.e("Write to characteristic failed: $e");
        _cmdQueue.insert(0, value);
      }
    }
    if (_cmdQueue.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 100), _queueNextCmd);
    }
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  // if continueImmediately is true, the scanning will be stopped
  // after the first reader is found
  Stream<FoundBleDevice> _scanForDevices() async* {
    List<FoundBleDevice> foundDevices = [];
    setStatus(ConnectionStatus.searching);

    var connectedDevices = await _checkAlreadyConnectedDevices();

    if (connectedDevices.isNotEmpty) {
      urpLogger.d("Found some connected devices ($connectedDevices)");
      for (final item in connectedDevices) {
        if (!foundDevices.contains(item)) {
          foundDevices.add(item);
          yield item;
        }
      }
    }

    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }

    final timeout = Duration(seconds: 10);

    urpLogger.d("Starting scan");

    await FlutterBluePlus.startScan(
      timeout: timeout,
      androidScanMode: AndroidScanMode.lowLatency,
    );

    final group = StreamGroup.merge<dynamic>(
      [FlutterBluePlus.scanResults, FlutterBluePlus.isScanning],
    );

    await for (var results in group) {
      if (results is bool) {
        if (!results) {
          break;
        }
        continue;
      }

      for (ScanResult r in results) {
        final deviceServiceUuids = r.advertisementData.serviceUuids.map(
          (e) => e.toString().toLowerCase(),
        );

        // Check if the services advertised by the device contains
        // one of the bleServiceIds

        for (final uuid in deviceServiceUuids) {
          if (bleServiceIds.contains(uuid.toString().toLowerCase())) {
            urpLogger.d(
              "Found a matching device ${r.device.platformName} ${r.device.remoteId.str}",
            );

            final found = FoundBleDevice(
              address: r.device.remoteId.str,
              name: r.device.platformName,
              connected: false,
              type: readerTypeFromServiceId(uuid),
              bleDevice: r.device,
            );

            if (!foundDevices.contains(found)) {
              foundDevices.add(found);
              yield found;
            }
          }
        }
      }
    }

    setStatus(ConnectionStatus.idle);

    urpLogger.d("Stop scanning");

    // Stop an existing scan if its running
    await FlutterBluePlus.stopScan();
  }

  @override
  Future<StrategyAvailability> get availability async {
    final supported = await FlutterBluePlus.isSupported;

    if (!supported) {
      return StrategyAvailability.unsupported;
    }

    Set<BluetoothAdapterState> inProgress = {
      BluetoothAdapterState.unknown,
      BluetoothAdapterState.turningOn,
    };

    late final BluetoothAdapterState adapterState;

    try {
      adapterState = await FlutterBluePlus.adapterState
          .where((v) => !inProgress.contains(v))
          .first
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      return StrategyAvailability.unsupported;
    }

    return switch (adapterState) {
      (BluetoothAdapterState.on) => StrategyAvailability.ready,
      (BluetoothAdapterState.off) => StrategyAvailability.disabled,
      (BluetoothAdapterState.turningOn) => StrategyAvailability.disabled,
      (BluetoothAdapterState.turningOff) => StrategyAvailability.disabled,
      (BluetoothAdapterState.unknown) => StrategyAvailability.disabled,
      (BluetoothAdapterState.unavailable) => StrategyAvailability.unsupported,
      (BluetoothAdapterState.unauthorized) =>
        StrategyAvailability.missingPermissions,
    };
  }

  // Get Battery Characteristic
  Future<BluetoothCharacteristic> _getBatteryCharacteristic() async {
    try {
      final services = await _device?.discoverServices();
      final batteryService = services
          ?.where(
            (s) => s.uuid == Guid(_batteryServiceUUID),
          )
          .first;
      final characteristic = batteryService?.characteristics
          .where(
            (c) => c.uuid == Guid(_batteryCharacteristicUUI),
          )
          .first;

      if (characteristic == null) {
        throw UnsupportedError("Battery characteristic not supported!");
      }

      return characteristic;
    } catch (e) {
      urpLogger.e('Error obtaining Battery characteristic: $e');
      rethrow;
    }
  }

  /// Streams the current battery state by subscribing to the battery
  /// characteristic [_batteryCharacteristicUUI]. Emits the current value after calling and emits new values
  /// whenever the [device] updates.
  Stream<int> getBatteryLevel() async* {
    final characteristic = await _getBatteryCharacteristic();

    await characteristic.setNotifyValue(true);

    yield _parseBatteryCharacteristicUpdate(await characteristic.read());

    await for (final event in characteristic.lastValueStream) {
      yield _parseBatteryCharacteristicUpdate(event);
    }

    await characteristic.setNotifyValue(false);
  }
}
