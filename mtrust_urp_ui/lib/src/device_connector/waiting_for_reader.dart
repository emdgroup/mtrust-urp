import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:mtrust_urp_ui/mtrust_urp_ui.dart';
import 'package:mtrust_urp_ui/src/device_connector/reader_thumbnail.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

class WaitingForDevice extends StatelessWidget {
  final ConnectionStrategy strategy;
  final FoundDevice expectedReader;
  final Function() onConnectToDifferentReader;

  const WaitingForDevice({
    required this.strategy,
    required this.expectedReader,
    required this.onConnectToDifferentReader,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LdSubmit<bool>(
      config: LdSubmitConfig<bool>(
        autoTrigger: true,
        action: () async {
          final connected = await strategy.connectToFoundDevice(expectedReader);

          if (!connected) {
            throw Exception('Could not connect to reader');
          }
          return true;
        },
      ),
      builder: LdSubmitCustomBuilder<bool>(
        builder: (context, controller, type) {
          return LdAutoSpace(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              switch (type) {
                (LdSubmitStateType.error) => LdTextHs(
                    UrpUiLocalizations.of(context).connectionFailed,
                  ),
                (_) => LdTextHs(
                    UrpUiLocalizations.of(context).waitingForReader(
                      expectedReader.name,
                    ),
                    textAlign: TextAlign.center,
                  ),
              },
              LdTextP(
                UrpUiLocalizations.of(context).ensureTurnedOn,
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: ReaderThumbnail(
                  reader: expectedReader,
                  onTap: () {},
                  distanceFromCenter: 0,
                  mode: switch (type) {
                    (LdSubmitStateType.error) =>
                      ReaderThumbnailMode.highlightGrayed,
                    (_) => ReaderThumbnailMode.highlight,
                  },
                ),
              ),
              LdReveal.quick(
                revealed: controller.state.type == LdSubmitStateType.error,
                child: LdButton(
                  onPressed: controller.trigger,
                  child: Text(
                    UrpUiLocalizations.of(context)
                        .retryConnect(expectedReader.name),
                  ),
                ),
              ),
              LdReveal(
                revealed: controller.state.type == LdSubmitStateType.error,
                child: LdButtonGhost(
                  onPressed: onConnectToDifferentReader,
                  child: Text(
                    UrpUiLocalizations.of(context).connectDifferentReader,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
