import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:mtrust_urp_ui/mtrust_urp_ui.dart';

LdModal makeDeviceConnectorModal({
  required DeviceConnector deviceConnector,
  required BuildContext context,
}) =>
    LdModal(
      bottomRadius: LdTheme.of(context).screenRadius,
      topRadius: LdTheme.of(context).screenRadius,
      fixedDialogSize: const Size(400, 400),
      padding: const EdgeInsets.all(0),
      modalContent: (context) => AspectRatio(
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
                    onPressed: Navigator.of(context).pop,
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
