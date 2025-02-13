/// Thrown when a command is cancelled
class CommandCancelledException extends Error {}

/// Thrown when a command is cancelled because the device is disconnected
class DeviceDisconnectedException extends CommandCancelledException {}

/// Thrown when a command is cancelled because the connection strategy is
/// disposed
class ConnectionStrategyDisposedException extends CommandCancelledException {}

/// Thrown when the device returns an error for a command
class DeviceError extends Error {

  /// Creates a new instance of [DeviceError]
  DeviceError({
    required this.errorCode,
    required this.errorMessage,
  });

  /// The error code returned by the device
  final int errorCode;
  /// The error message returned by the device
  final String errorMessage;

  @override
  String toString() {
    return errorMessage;
  }
}
