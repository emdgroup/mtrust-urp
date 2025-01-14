import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:mtrust_urp_ui/src/device_connector/reader_carousel.dart';
import 'package:mtrust_urp_ui/src/device_connector/strategy_status.dart';
import 'package:mtrust_urp_ui/src/l10n/generated/ui_ui_localizations.dart';
import 'package:mtrust_urp_ui/src/shared_prefs_storage_adapter.dart';
import 'package:mtrust_urp_ui/src/storage_adapter.dart';
import 'package:mtrust_urp_ui/src/device_connector/waiting_for_reader.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

enum ReaderConnectorMode {
  ephemeral,
  pair,
  preferLastConnected,
}

class DeviceConnector extends StatelessWidget {
  /// The connection strategy to use when connecting to a device.
  final ConnectionStrategy connectionStrategy;

  /// The mode to use when connecting to a device.
  final ReaderConnectorMode mode;

  final Function()? onDismiss;

  final Widget Function(BuildContext context) connectedBuilder;

  final Set<UrpDeviceType> deviceTypes;

  final StorageAdapter storageAdapter;

  DeviceConnector({
    super.key,
    required this.connectionStrategy,
    this.mode = ReaderConnectorMode.preferLastConnected,
    StorageAdapter? storageAdapter,
    required this.connectedBuilder,
    required this.deviceTypes,
    this.onDismiss,
  }) : storageAdapter = storageAdapter ??
            SharedPrefsStorageAdapter(
              deviceTypes.toString(),
            );

  Future<FoundDevice?> _getPreferredReader() async {
    switch (mode) {
      case ReaderConnectorMode.ephemeral:
        return null;
      case ReaderConnectorMode.pair:
        final paired = await storageAdapter.getPairedReader();
        return paired;
      case ReaderConnectorMode.preferLastConnected:
        final lastConnected = await storageAdapter.getLastConnectedReader();
        return lastConnected;
    }
  }

  Future<void> _storeConnectedReader(FoundDevice reader) async {
    switch (mode) {
      case ReaderConnectorMode.ephemeral:
        break;
      case ReaderConnectorMode.pair:
        await storageAdapter.persistPairedReader(reader);
        break;
      case ReaderConnectorMode.preferLastConnected:
        await storageAdapter.persistLastConnectedReader(reader);
        break;
    }
  }

  Widget _buildPreferredReaderBadge(BuildContext context, FoundDevice reader) {
    final locales = UrpUiLocalizations.of(context);
    return LdBadge(
      color: shadZinc,
      size: LdSize.s,
      child: Text(switch (mode) {
        (ReaderConnectorMode.ephemeral) => "",
        (ReaderConnectorMode.pair) => locales.pair,
        (ReaderConnectorMode.preferLastConnected) => locales.lastUsed,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StrategyAvailabilityGuard(
      strategy: connectionStrategy,
      readyBuilder: (context) => StreamBuilder<ConnectionStatus>(
        stream: connectionStrategy.statusStream,
        builder: (context, snapshot) {
          return switch (snapshot.data ?? connectionStrategy.status) {
            (ConnectionStatus.connected) => connectedBuilder(context),
            _ => LdSubmit(
                config: LdSubmitConfig<FoundDevice?>(
                  autoTrigger: true,
                  allowResubmit: true,
                  action: () async {
                    return _getPreferredReader();
                  },
                ),
                builder: LdSubmitCustomBuilder<FoundDevice?>(
                  builder: (context, preferredController, prefferedState) {
                    if (prefferedState != LdSubmitStateType.result) {
                      return const LdLoader();
                    }

                    final preferredReader = preferredController.state.result;

                    // LdSubmit that handles triggering the scanning for readers
                    return LdSubmit<Stream<FoundDevice>>(
                      config: LdSubmitConfig(
                        autoTrigger: true,
                        allowResubmit: true,
                        action: () async {
                          return connectionStrategy.findDevices(deviceTypes);
                        },
                      ),
                      builder: LdSubmitCenteredBuilder<Stream<FoundDevice>>(
                        resultBuilder: (context, result, controller) {
                          switch (mode) {
                            case ReaderConnectorMode.ephemeral:
                              return ReaderCarousel(
                                readers: result,
                                types: deviceTypes,
                                restartScanning: controller.trigger,
                                onConnect: (FoundDevice reader) async {
                                  await _storeConnectedReader(reader);
                                  return await connectionStrategy
                                      .connectToFoundDevice(reader);
                                },
                              );
                            case ReaderConnectorMode.pair:
                              if (preferredReader == null) {
                                return ReaderCarousel(
                                  readers: result,
                                  types: deviceTypes,
                                  restartScanning: controller.trigger,
                                  onConnect: (FoundDevice reader) async {
                                    await _storeConnectedReader(reader);

                                    return await connectionStrategy
                                        .connectToFoundDevice(
                                      reader,
                                    );
                                  },
                                );
                              } else {
                                return WaitingForDevice(
                                  strategy: connectionStrategy,
                                  expectedReader: preferredReader,
                                  onConnectToDifferentReader: () async {
                                    await storageAdapter.clearPairedReader();
                                    preferredController.reset();
                                    preferredController.trigger();
                                  },
                                );
                              }

                            case ReaderConnectorMode.preferLastConnected:
                              return ReaderCarousel(
                                readers: result,
                                types: deviceTypes,
                                restartScanning: controller.trigger,
                                preferredReaderAddress:
                                    preferredReader?.address,
                                prefferedBadgeBuilder:
                                    _buildPreferredReaderBadge,
                                onConnect: (FoundDevice reader) async {
                                  await _storeConnectedReader(reader);

                                  return await connectionStrategy
                                      .connectToFoundDevice(
                                    reader,
                                  );
                                },
                              );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
          };
        },
      ),
    );
  }
}
