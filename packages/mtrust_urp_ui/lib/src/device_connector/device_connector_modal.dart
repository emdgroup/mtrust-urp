import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:mtrust_urp_ui/mtrust_urp_ui.dart';

LdModalRoute makeDeviceConnectorModal({
  required DeviceConnector deviceConnector,
  required BuildContext context,
}) =>
    LdModalRoute(
      context: context,
      sheetAspectRatio: 1,
      sheetBorderRadius: BorderRadius.circular(LdTheme.of(context).screenRadius),
      fixedDialogSize: const Size(400, 400),
      pageBuilder: (context) => LdScaffold(body: deviceConnector.padL()),
    );
