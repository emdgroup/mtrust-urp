import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:mtrust_urp_ui/mtrust_urp_ui.dart';

class ScanningHeader extends StatelessWidget {
  final int nReadersFound;
  final LdSubmitStateType state;
  final bool isScanning;

  const ScanningHeader({
    required this.nReadersFound,
    required this.isScanning,
    required this.state,
    super.key,
  });

  @override
  build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Loader if still scanning
        Flexible(
          child: LdTextHs(
            switch (state) {
              LdSubmitStateType.loading =>
                UrpUiLocalizations.of(context).connecting,
              LdSubmitStateType.error =>
                UrpUiLocalizations.of(context).connectionFailed,
              _ => UrpUiLocalizations.of(context).nReadersFound(nReadersFound),
            },
            lineHeight: 1,
          ),
        ),
        LdReveal(
          revealed: state == LdSubmitStateType.loading || isScanning,
          child: const Row(
            children: [
              ldSpacerS,
              LdLoader(
                size: 16,
              ),
            ],
          ),
        )
      ],
    );
  }
}
