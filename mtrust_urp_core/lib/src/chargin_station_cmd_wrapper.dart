import 'dart:io';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

/// Wrapper for the charging station commands
class CharginStationCmdWrapper extends CmdWrapper {
  /// Creates a new instance of [CharginStationCmdWrapper]
  CharginStationCmdWrapper({
    required this.connectionStrategy,
    UrpDeviceIdentifier? target,
    UrpDeviceIdentifier? origin,
  }) : target = target ?? UrpDeviceIdentifier(
          deviceClass: UrpDeviceClass.urpStation,
          deviceType: UrpDeviceType.urpPsu,
        ),
        origin = origin ?? UrpDeviceIdentifier(
          deviceClass: UrpDeviceClass.urpHost,
          deviceType: (Platform.isAndroid || Platform.isIOS)
              ? UrpDeviceType.urpMobile
              : UrpDeviceType.urpDesktop,
        );
    
    /// The connection strategy to be used.
    final ConnectionStrategy connectionStrategy;
    /// The identifier of the target device.
    final UrpDeviceIdentifier target;
    /// The identifier of the origin device.
    final UrpDeviceIdentifier origin;

  // TODO(JoshuaWellbrock): IMPLEMENT
}
