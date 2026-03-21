import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:mtrust_urp_core/mtrust_urp_core.dart';

class UrpVirtualStrategy extends ConnectionStrategy {
  bool simulateDelays;

  StrategyAvailability _availability = StrategyAvailability.ready;

  Future<UrpResponse?> Function(UrpRequest request) onRequest;

  /// List of virtual readers that can be connected to
  List<FoundDevice> _virtualReaders;

  UrpDeviceType? connectedReaderType;

  String? connectedReaderAddress;

  Stream<FoundDevice>? virtualReadersStream;

  bool debugFailConnection = false;

  UrpVirtualStrategy(
    this.onRequest, {
    this.simulateDelays = false,
    this.debugFailConnection = false,
    List<FoundDevice>? virtualReaders,
    Stream<FoundDevice>? this.virtualReadersStream,
  }) : _virtualReaders = virtualReaders ?? [];

  @override
  Future<StrategyAvailability> get availability async {
    return _availability;
  }

  get availabilityNow => _availability;

  String get name => "Virtual";

  List<FoundDevice> get virtualReaders => UnmodifiableListView(_virtualReaders);

  @override
  Future<UrpResponse> addQueue(
    Uint8List command,
    UrpDeviceIdentifier target,
    UrpDeviceIdentifier origin, {
    Duration? timeout,
  }) {
    return super.addQueue(command, target, origin, timeout: timeout);
  }

  void clearVirtualReaders() {
    _virtualReaders.clear();
  }

  /// Add a virtual reader to the list of found readers
  void createVirtualReader(FoundDevice reader) {
    _virtualReaders.add(reader);
  }

  /// Manually set the connection status
  void debugSetConnectionStatus(ConnectionStatus status) {
    setStatus(status);
  }

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

    final stream = virtualReadersStream ?? Stream.fromIterable(_virtualReaders);

    await for (var reader in stream) {
      await delay(Duration(milliseconds: 300));
      if (readerTypes.contains(reader.type) &&
          (deviceAddress == null || deviceAddress == reader.address)) {
        urpLogger.d("Found device: ${reader.name}");
        connectedReaderType = reader.type;
        connectedReaderAddress = reader.address;
        setStatus(ConnectionStatus.connected);
        return true;
      }
    }

    await delay(Duration(seconds: 3));

    setStatus(ConnectionStatus.idle);

    return false;
  }

  /// Will return a stream of [FoundDevice]s that match the [readerTypes]
  /// provided. Will wait 1 second before starting to emit the readers.
  /// Will wait 300 milliseconds between emitting each reader.
  @override
  Stream<FoundDevice> findDevices(Set<UrpDeviceType> readerTypes) async* {
    final stream = virtualReadersStream ?? Stream.fromIterable(_virtualReaders);

    await for (var reader in stream) {
      await delay(Duration(milliseconds: 300));
      if (readerTypes.contains(reader.type)) {
        yield reader;
      }
    }

    await delay(Duration(seconds: 3));
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

  void replyFromVirtualDevice(int seqNr, UrpResponse response) {
    final message = UrpMessage(
      header: UrpMessageHeader(
        seqNr: seqNr,
        origin: UrpDeviceIdentifier(
          deviceClass: UrpDeviceClass.urpReader,
          deviceType: connectedReaderType!,
          id: connectedReaderAddress!,
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

  void setAvailability(StrategyAvailability availability) {
    _availability = availability;
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
}
