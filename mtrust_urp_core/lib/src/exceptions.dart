/// Thrown when a command is cancelled
class CommandCancelledException extends Error {}

/// Thrown when a command is cancelled because the device is disconnected
class DeviceDisconnectedException extends CommandCancelledException {}

/// Thrown when a command is cancelled because the connection strategy is
/// disposed
class ConnectionStrategyDisposedException extends CommandCancelledException {}
