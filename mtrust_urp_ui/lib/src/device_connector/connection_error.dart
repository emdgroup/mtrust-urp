import 'dart:async';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:mtrust_urp_ui/mtrust_urp_ui.dart';
import 'package:mtrust_urp_ui/src/device_connector/reader_thumbnail.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

class ConnectionError extends StatelessWidget {
  final Function() connectDifferentReader;
  final Future<void> Function() retry;
  final FoundDevice reader;

  const ConnectionError({
    required this.connectDifferentReader,
    required this.retry,
    required this.reader,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LdAutoSpace(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LdTextHs(UrpUiLocalizations.of(context).connectionFailed),
        LdTextP(
          UrpUiLocalizations.of(context).ensureTurnedOn,
          textAlign: TextAlign.center,
        ),
        // Greyed out reader
        Expanded(
          child: Opacity(
            opacity: 0.6,
            child: ReaderThumbnail(
              reader: reader,
              onTap: () {},
              distanceFromCenter: 0,
              mode: ReaderThumbnailMode.highlight,
            ),
          ),
        ),
      ],
    );
  }
}
