import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

/// Reports the availability of a strategy, e.g. if it is supported by the
/// platform or if the user has disabled it (BLE or WiFi disabled)
enum StrategyAvailability {
  /// The strategy is not supported by the platform
  unsupported,

  /// The strategy is disabled
  disabled,

  /// The strategy is ready
  ready,

  /// The strategy is missing permissions
  missingPermissions,
}

/// The connection status
enum ConnectionStatus {
  /// App is idle
  idle,

  /// Searching for a device
  searching,

  /// Connecting to device
  connecting,

  /// Connected to the device
  connected,
}

/// Connection Strategy is the base class for different strategy types
abstract class ConnectionStrategy extends ChangeNotifier {
  /// Output bytes to the deivce
  void output(Uint8List bytes);

  /// The power state of a device
  UrpPowerState? powerState;

  /// Get the availability of the strategy
  Future<StrategyAvailability> get availability;

  /// The name of the strategy, e.g. 'Bluetooth', 'WiFi'
  String get name;

  /// Callback when the device is disconnected
  void Function()? onDisconnectCallback;

  /// Callback when the device is connected
  void Function()? onConnectCallback;

  /// Callback when the device is pinged
  void Function()? pingDeviceCallback;

  /// Set callback when the device is connected
  void onConnect(void Function() callback) {
    _setupTimers();
    onConnectCallback = callback;
  }

  /// Set callback when the device is disconnected
  void onDisconnect(void Function() callback) {
    onDisconnectCallback = () {
      _pingTimer?.cancel();
      _powerTimer?.cancel();
      callback();
    };
  }

  /// Set callback when the device is pinged
  // ignore: use_setters_to_change_properties
  void onPing(void Function() callback) {
    pingDeviceCallback = callback;
  }

  Timer? _pingTimer;
  Timer? _powerTimer;

  final _statusController = StreamController<ConnectionStatus>.broadcast();

  ConnectionStatus _status = ConnectionStatus.idle;

  /// Set the current connection status
  @protected
  void setStatus(ConnectionStatus status) {
    _status = status;
    _statusController.add(status);
    notifyListeners();
  }

  /// The current connection status
  ConnectionStatus get status => _status;

  /// The current status as stream
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  /// Connect to a [FoundDevice] that was previously found during a search
  Future<bool> connectToFoundDevice(
    FoundDevice reader,
  ) {
    return findAndConnectDevice(
      readerTypes: {reader.type},
      deviceAddress: reader.address,
    );
  }

  /// Find readers of a specific type
  Stream<FoundDevice> findDevices(Set<UrpDeviceType> deviceTypes);

  /// Connect to a reader of a specific type and optionally address
  Future<bool> findAndConnectDevice({
    required Set<UrpDeviceType> readerTypes,
    String? deviceAddress,
  });

  @mustCallSuper

  /// Disconnect the reader, cancels all pending commands
  /// with a [DeviceDisconnectedException]
  Future<void> disconnectDevice() async {
    _remainingBytes = -1;
    _buffer.clear();
    _cmdQueue
      ..forEach((key, value) {
        if (value.completer.isCompleted) {
          return;
        }
        value.completer.completeError(
          DeviceDisconnectedException(),
        );
      })
      ..clear();
    onDisconnectCallback?.call();
    setStatus(ConnectionStatus.idle);
  }

  @mustCallSuper
  @override
  void dispose() {
    onConnectCallback = null;
    onDisconnectCallback = null;
    _cmdQueue
      ..forEach((key, value) {
        if (value.completer.isCompleted) {
          return;
        }
        value.completer.completeError(
          ConnectionStrategyDisposedException(),
        );
      })
      ..clear();
    _pingTimer?.cancel();
    _powerTimer?.cancel();
    super.dispose();
  }

  Future<void> _ping() async {
    try {
      if (status != ConnectionStatus.connected) {
        _pingTimer?.cancel();
        return;
      }
      pingDeviceCallback?.call();
    } catch (e) {
      urpLogger.e('Ping failed: $e');
      _pingTimer?.cancel();
    }
  }

  void _setupTimers() {
    _ping();

    _pingTimer?.cancel();
    _powerTimer?.cancel();

    _pingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _ping();
    });
  }

  final Map<int, _Cmd> _cmdQueue = {};

  int _seqNr = 0;

  final List<int> _buffer = [];
  int _remainingBytes = -1;

  Uint8List _stash = Uint8List(0);

  /// called by the strategy when raw data is received
  void onData(Uint8List input) {
    var data = input;
    if (_stash.isNotEmpty) {
      data = Uint8List.fromList(_stash + data);
      _stash = Uint8List(0);
    }

    var byteOffset = 0;

    if (data.isEmpty) {
      return;
    }

    var cycles = 0;

    while (byteOffset < data.length && cycles < 100) {
      if (_remainingBytes < 0) {
        if (data.length - byteOffset < 2) {
          _stash = Uint8List.fromList(data.sublist(byteOffset));

          return;
        }

        _remainingBytes = (data[byteOffset] << 8) | data[byteOffset + 1];
        byteOffset += 2;
      }

      cycles++;

      final leftInBuffer = data.length - byteOffset;

      final int bytesToRead = min(_remainingBytes, leftInBuffer);

      _buffer.addAll(data.sublist(byteOffset, byteOffset + bytesToRead));

      _remainingBytes -= bytesToRead;

      byteOffset += bytesToRead;

      if (_remainingBytes == 0) {
        _remainingBytes = -1;

        _processBuffer(_buffer);
        _buffer.clear();
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

  /// Adds a command to the queue.
  Future<UrpResponse> addQueue(
    Uint8List command,
    UrpDeviceIdentifier target,
    UrpDeviceIdentifier origin, {
    Duration? timeout,
  }) {
    final completer = Completer<UrpResponse>();

    _seqNr++;

    final message = UrpMessage(
      header: UrpMessageHeader(
        target: target,
        origin: origin,
        seqNr: _seqNr,
      ),
      request: UrpRequest(
        payload: command,
      ),
    );

    final cmd = _Cmd(
      request: message,
      completer: completer,
      seqNr: _seqNr,
    );
    _cmdQueue[_seqNr] = cmd;

    // urpLogger.d(
    //   'Adding ${message.request} ($command) to queue '
    //   '(current length:  ${_cmdQueue.length})',
    // );

    final bytes = message.writeToBuffer();
    final length = _int16ToBytes(bytes.length);

    // urpLogger.d('Length $length (${length.length})');

    try {
      output(Uint8List.fromList(length + bytes));
    } catch (e) {
      urpLogger.e(e.toString());
      rethrow;
    }

    return completer.future;
  }

  // Handles the input from the device
  void _processBuffer(List<int> buffer) {
    try {
      final message = UrpMessage.fromBuffer(buffer);

      if (message.whichPayload() == UrpMessage_Payload.response) {
        //securalicLogger.i(message.toDebugString());
        final seq = message.header.seqNr;

        final cmd = _cmdQueue[seq];

        if (cmd == null) {
          urpLogger.e('Unknown seq from reader $seq');
          return;
        }

        if (message.header.error.isNotEmpty) {
          urpLogger.e(
            'Reader returned error for ${cmd.request}: '
            '${message.header.error}\n'
            'Error Code: ${message.header.errorCode.value}',
          );
          if (cmd.completer.isCompleted) {
            _cmdQueue.remove(seq);
            return;
          }
          final deviceError = DeviceError(
            errorCode: message.header.errorCode.value, 
            errorMessage: message.header.error,
          );
          cmd.completer.completeError(deviceError);
        } else {
          // final duration = DateTime.now().difference(cmd.created);
          // urpLogger
          //   ..d('Processing response for ${cmd.request}')
          //   ..d(
          //     'Command took ${duration.inMilliseconds}ms',
          //   );

          if (cmd.completer.isCompleted) {
            urpLogger.d('Completer already completed');
            _cmdQueue.remove(seq);
            return;
          }

          cmd.completer.complete(message.response);
        }
        _cmdQueue.remove(seq);
      } else if (message.whichPayload() == UrpMessage_Payload.notSet) {
        urpLogger.log(
          Level.warning,
          'No Payload set in message $message',
        );
      }
    } catch (e) {
      urpLogger.e('FATAL Error processing buffer: $e');
      disconnectDevice();
    }
  }
}

/// Internal class to handle a single command
class _Cmd {
  _Cmd({required this.request, required this.completer, required this.seqNr}) {
    created = DateTime.now();
  }
  UrpMessage request;

  Completer<dynamic> completer;
  late DateTime created;
  DateTime? processing;

  int seqNr;
}
