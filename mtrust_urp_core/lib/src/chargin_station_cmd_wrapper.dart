import 'dart:io';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

/// Wrapper for the charging station commands
class CharginStationCmdWrapper extends CmdWrapper {
  /// Creates a new instance of [CharginStationCmdWrapper]
  CharginStationCmdWrapper({
    required ConnectionStrategy connectionStrategy,
    UrpDeviceIdentifier? target,
    UrpDeviceIdentifier? origin,
  }) : super(
          strategy: connectionStrategy,
          target: target ??
              UrpDeviceIdentifier(
                deviceClass: UrpDeviceClass.urpStation,
                deviceType: UrpDeviceType.urpPsu,
              ),
          origin: origin ??
              UrpDeviceIdentifier(
                deviceClass: UrpDeviceClass.urpHost,
                deviceType: (Platform.isAndroid || Platform.isIOS)
                    ? UrpDeviceType.urpMobile
                    : UrpDeviceType.urpDesktop,
              ),
        );

  // TODO(JoshuaWellbrock): IMPLEMENT
}
