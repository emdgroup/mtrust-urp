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
      contentPadding: const EdgeInsets.all(32),
      headerPadding: const EdgeInsets.all(16),
      modalContent: (context) => AspectRatio(
        aspectRatio: 1,
        child: deviceConnector,
      ),
    );
