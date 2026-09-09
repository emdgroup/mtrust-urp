import 'package:mtrust_urp_types/wrapper.pb.dart';

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
  final UrpErrorCode errorCode;

  /// The error message returned by the device
  final String errorMessage;

  @override
  String toString() {
    return errorMessage;
  }
}

/// Thrown when an API call fails
class ApiException extends Error {
  /// Creates a new instance of [ApiException]
  ApiException({
    required this.errorCode,
    required this.errorMessage,
  });

  /// The error code returned by the API
  final int errorCode;

  /// The error message returned by the API
  final String errorMessage;

  @override
  String toString() {
    return errorMessage;
  }
}

/// Thrown when the backend rejects a device config due to a guardrail
/// violation (HTTP 422 from `POST /device/config/sign`).
///
/// Mirrors the Python SDK's `ConfigValidationError` — carries the backend's
/// stable machine-readable [code] (e.g. `CFG_ERR_SCAN_TIMEOUT_RANGE`) so
/// callers can branch on it without parsing [message].
class ConfigValidationException extends Error {
  /// Creates a new instance of [ConfigValidationException]
  ConfigValidationException({
    required this.code,
    required this.message,
  });

  /// Stable machine-readable error code returned by the backend.
  final String code;

  /// Human-readable error message returned by the backend.
  final String message;

  @override
  String toString() {
    return '$code: $message';
  }
}
