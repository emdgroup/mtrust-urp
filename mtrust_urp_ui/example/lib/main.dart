import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';
import 'package:mtrust_urp_ui/mtrust_urp_ui.dart';
import 'package:mtrust_urp_virtual_strategy/mtrust_urp_virtual_strategy.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final virtualStrategy = UrpVirtualStrategy((request) async {
    return UrpResponse();
  }, simulateDelays: true);

  @override
  void initState() {
    super.initState();
    virtualStrategy.setAvailability(StrategyAvailability.ready);
    _addReader();
  }

  void _addReader() {
    virtualStrategy.clearVirtualReaders();
    virtualStrategy.createVirtualReader(
      FoundDevice(
        name: 'Virtual SEC 1',
        type: UrpDeviceType.urpSec,
        address: '1234537890',
      ),
    );
    virtualStrategy.createVirtualReader(
      FoundDevice(
        name: 'Virtual SEC 2',
        type: UrpDeviceType.urpSec,
        address: '1234567891',
      ),
    );
    virtualStrategy.createVirtualReader(
      FoundDevice(
        name: 'Virtual IMP 1',
        type: UrpDeviceType.urpImp,
        address: '1234560333',
      ),
    );
  }

  bool _debugFailConnection = false;
  void _setDebugFailConnection(bool value) {
    setState(() {
      _debugFailConnection = value;
    });
    virtualStrategy.debugFailConnection = value;
  }

  StrategyAvailability _availability = StrategyAvailability.ready;

  void _setAvailability(StrategyAvailability availability) {
    setState(() {
      _availability = availability;
    });
    virtualStrategy.setAvailability(availability);
  }

  void _removeReaders() {
    virtualStrategy.clearVirtualReaders();
  }

  ReaderConnectorMode _connectorMode = ReaderConnectorMode.preferLastConnected;
  void _setConnectorMode(ReaderConnectorMode connectorMode) {
    setState(() {
      _connectorMode = connectorMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LdThemeProvider(
      child: LdThemedAppBuilder(
        appBuilder:
            (context, theme) => MaterialApp(
              localizationsDelegates: [
                UrpUiLocalizations.delegate,
                LiquidLocalizations.delegate,
              ],
              theme: theme,
              home: Scaffold(
                appBar: LdAppBar(
                  context: context,
                  title: Text("URP UI Playground"),
                ),
                body:
                    LdAutoSpace(
                      children: [
                        LdSwitch(
                          label: "Availability of the connection strategy",
                          onChanged: (value) {
                            _setAvailability(value);
                          },
                          children: {
                            StrategyAvailability.disabled: Text("Disabled "),
                            StrategyAvailability.missingPermissions: Text(
                              "Missing permissions",
                            ),
                            StrategyAvailability.unsupported: Text(
                              "Unsupported",
                            ),
                            StrategyAvailability.ready: Text("Ready"),
                          },
                          value: _availability,
                        ),

                        LdSwitch(
                          label: "Device connector mode",
                          children: {
                            ReaderConnectorMode.ephemeral: Text("Ephemeral"),
                            ReaderConnectorMode.pair: Text("Pair"),
                            ReaderConnectorMode.preferLastConnected: Text(
                              "Prefer last connected",
                            ),
                          },
                          value: _connectorMode,
                          onChanged: _setConnectorMode,
                        ),

                        LdToggle(
                          checked: _debugFailConnection,
                          onChanged: _setDebugFailConnection,
                          label: "Debug fail connection",
                        ),

                        LdButtonVague(
                          onPressed: _addReader,
                          child: Text("Add reader"),
                        ),
                        LdButtonVague(
                          onPressed: _removeReaders,
                          child: Text("Remove readers"),
                        ),
                        LdButtonVague(
                          onPressed: () {
                            virtualStrategy.disconnectDevice();
                          },
                          child: Text("Disconnect"),
                        ),

                        Builder(
                          builder: (context) {
                            return LdButton(
                              child: Text("Open device connector"),
                              onPressed: () {
                                final modal = makeDeviceConnectorModal(
                                  deviceConnector: DeviceConnector(
                                    mode: _connectorMode,
                                    connectionStrategy: virtualStrategy,
                                    connectedBuilder:
                                        (context) => const Text('Connected'),
                                    deviceTypes: {
                                      UrpDeviceType.urpSec,
                                      UrpDeviceType.urpImp,
                                    },
                                  ),
                                  context: context,
                                );

                                modal.show(context);
                              },
                            );
                          },
                        ),
                      ],
                    ).padL(),
              ),
            ),
      ),
    );
  }
}
