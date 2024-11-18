import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:mtrust_urp_ui/mtrust_urp_ui.dart';

class DeviceConnectorSheet extends StatelessWidget {
  final DeviceConnector deviceConnector;

  final bool isOpen;

  final Function() onDismiss;

  const DeviceConnectorSheet({
    super.key,
    required this.deviceConnector,
    required this.isOpen,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return LdSheet(
      customDetachedSize: const Size(450, 450),
      detachedAlignment: Alignment.bottomCenter,
      detachedSize: LdSize.s,
      minInsets: const EdgeInsets.all(32),
      initialSize: 1,
      open: isOpen,
      child: AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Stack(
            children: [
              Positioned.fill(child: deviceConnector),
              Align(
                alignment: Alignment.topRight,
                child: IntrinsicHeight(
                  child: LdButton(
                    size: LdSize.s,
                    mode: LdButtonMode.vague,
                    onPressed: onDismiss,
                    child: const Icon(
                      Icons.clear,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
