import 'dart:io';
import 'dart:typed_data';

import 'package:mtrust_urp_core/mtrust_urp_core.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Handles connecting to the reader via websockets
class UrpWifiStrategy extends ConnectionStrategy {
  ConnectionStatus _status = ConnectionStatus.idle;

  WebSocket? _socket;
  ConnectionStatus get status => _status;

  String get name => "WiFi";

  void _setStatus(ConnectionStatus status) {
    _status = status;
    urpLogger.d("WS Service status: $status");
    notifyListeners();
  }

  WebSocketChannel? _channel;

  @override
  output(Uint8List bytes) {
    if (_channel == null) {
      return null;
    }
    _channel!.sink.add(bytes);
  }

  Future<void> disconnectDevice() async {
    _socket?.close();
    _channel?.sink.close();
    _channel = null;

    _setStatus(ConnectionStatus.idle);
    super.disconnectDevice();
  }

  void dispose() {
    super.dispose();
    disconnectDevice();
  }

  @override
  Future<bool> findAndConnectDevice(
      {String? deviceAddress, Set<UrpDeviceType>? readerTypes}) async {
    _socket = await WebSocket.connect('ws://$deviceAddress/ws');

    _channel = IOWebSocketChannel(_socket!);
    _channel!.stream.listen(
        (data) => onData(Uint8List.fromList((data as String).codeUnits)));
    _setStatus(ConnectionStatus.connected);
    return true;
  }

  @override
  Stream<FoundDevice> findDevices(Set<UrpDeviceType> readerTypes) {
    return Stream.empty();
  }

  @override
  Future<StrategyAvailability> get availability {
    return Future.value(StrategyAvailability.ready);
  }
}
