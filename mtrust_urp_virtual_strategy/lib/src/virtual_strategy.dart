import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:mtrust_urp_core/mtrust_urp_core.dart';

class UrpVirtualStrategy extends ConnectionStrategy {
  /// Manually set the connection status
  void debugSetConnectionStatus(ConnectionStatus status) {
    setStatus(status);
  }

  bool simulateDelays = true;

  String get name => "Virtual";

  StrategyAvailability _availability = StrategyAvailability.ready;

  @override
  Future<StrategyAvailability> get availability async {
    return _availability;
  }

  get availabilityNow => _availability;

  void setAvailability(StrategyAvailability availability) {
    _availability = availability;
  }

  Future<UrpResponse?> Function(UrpRequest request) onRequest;

  UrpVirtualStrategy(this.onRequest);

  /// List of virtual readers that can be connected to
  List<FoundDevice> _virtualReaders = [];

  /// Add a virtual reader to the list of found readers
  void createVirtualReader(FoundDevice reader) {
    _virtualReaders.add(reader);
  }

  void clearVirtualReaders() {
    _virtualReaders.clear();
  }

  List<FoundDevice> get virtualReaders => UnmodifiableListView(_virtualReaders);

  UrpDeviceType? _connectedReaderType;
  String? _connectedReaderAddress;

  bool debugFailConnection = false;

  Future<void> delay(Duration duration) {
    return simulateDelays ? Future.delayed(duration) : Future.value();
  }

  /// Returns [true] if the connection was successful, [false] otherwise.
  /// Will run [findDevices] and connect to the first reader found.
  @override
  Future<bool> findAndConnectDevice(
      {required Set<UrpDeviceType> readerTypes, String? deviceAddress}) async {
    setStatus(ConnectionStatus.searching);

    await delay(Duration(seconds: 1));

    if (debugFailConnection) {
      setStatus(ConnectionStatus.idle);
      return false;
    }

    for (var reader in _virtualReaders) {
      await delay(Duration(milliseconds: 300));
      if (readerTypes.contains(reader.type) &&
          (deviceAddress == null || deviceAddress == reader.address)) {
        _connectedReaderType = reader.type;
        _connectedReaderAddress = reader.address;
        setStatus(ConnectionStatus.connected);
        return true;
      }
    }

    await delay(Duration(seconds: 5));

    setStatus(ConnectionStatus.idle);

    return false;
  }

  @override
  void output(Uint8List bytes) async {
    final message = UrpMessage.fromBuffer(bytes.sublist(2));

    if (message.header.target.deviceClass == UrpDeviceClass.urpReader) {
      urpLogger.d("Checking if virtual device replies to message");
      final response = await onRequest(message.request);
      if (response != null) {
        urpLogger.d("Virtual device replied to message");
        replyFromVirtualDevice(message.header.seqNr, response);
      }
    }
  }

  Uint8List _int16ToBytes(int value) {
    if (value < -32768 || value > 32767) {
      throw ArgumentError('Value must be between -32768 and 32767.');
    }

    final bytes = Uint8List(2);

    // Store the two bytes in little-endian order
    bytes[0] = (value >> 8) & 0xFF; // Upper byte
    bytes[1] = value & 0xFF; // Lower byte

    return bytes;
  }

  @override
  Future<UrpResponse> addQueue(
    Uint8List command,
    UrpDeviceIdentifier target,
    UrpDeviceIdentifier origin, {
    Duration? timeout,
  }) {
    return super.addQueue(command, target, origin, timeout: timeout);
  }

  void replyFromVirtualDevice(int seqNr, UrpResponse response) {
    final message = UrpMessage(
      header: UrpMessageHeader(
        seqNr: seqNr,
        origin: UrpDeviceIdentifier(
          deviceClass: UrpDeviceClass.urpReader,
          deviceType: _connectedReaderType!,
          id: _connectedReaderAddress!,
        ),
        target: UrpDeviceIdentifier(
          deviceClass: UrpDeviceClass.urpHost,
          id: "host",
        ),
      ),
      response: response,
    );

    final bytes = message.writeToBuffer();
    final length = _int16ToBytes(bytes.length);

    onData(Uint8List.fromList(length + bytes));
  }

  /// Will return a stream of [FoundDevice]s that match the [readerTypes]
  /// provided. Will wait 1 second before starting to emit the readers.
  /// Will wait 300 milliseconds between emitting each reader.
  @override
  Stream<FoundDevice> findDevices(Set<UrpDeviceType> readerTypes) async* {
    await delay(Duration(seconds: 1));

    for (var reader in _virtualReaders) {
      if (readerTypes.contains(reader.type)) {
        await delay(Duration(milliseconds: 300));
        yield reader;
      }
    }

    await delay(Duration(seconds: 3));
  }
}
