import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/ui_ui_localizations.dart';

class StrategyAvailabilityGuard extends StatelessWidget {
  final ConnectionStrategy strategy;

  final Function(BuildContext context) readyBuilder;

  const StrategyAvailabilityGuard({
    required this.strategy,
    required this.readyBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final strategyName = strategy.name;

    return LdSubmit<StrategyAvailability, ConnectionStrategy>(
      arg: strategy,
      config: LdSubmitConfig<StrategyAvailability, ConnectionStrategy>(
        action: (strategy) async {
          return strategy!.availability;
        },
        autoTrigger: true,
        allowResubmit: true,
      ),
      child: Builder(builder: (context) {
        final controller = context.watch<LdSubmitController<StrategyAvailability, ConnectionStrategy>>();
        final stateType = controller.state.type;
        // Helper function to build an error message
        Widget buildError(String title, String submessage, bool canRetry) {
          return Center(
            child: LdAutoSpace(
              animate: true,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LdText.hs(
                  title,
                  textAlign: TextAlign.center,
                ),
                LdText(
                  submessage,
                  textAlign: TextAlign.center,
                ),
                if (canRetry)
                  LdButton(
                    onPressed: controller.trigger,
                    child: Text(UrpUiLocalizations.of(context).retry),
                  ),
              ],
            ),
          );
        }

        final localization = UrpUiLocalizations.of(context);
        return switch (stateType) {
          LdSubmitStateType.idle => const SizedBox.shrink(),
          LdSubmitStateType.loading => const Center(child: LdLoader()),
          LdSubmitStateType.error => buildError(
              localization.error,
              localization.unableToPrepareStrategy(strategyName),
              true,
            ),
          LdSubmitStateType.result => switch (controller.state.result as StrategyAvailability) {
              (StrategyAvailability.ready) => readyBuilder(context),
              (StrategyAvailability.disabled) => buildError(
                  localization.strategyDisabled(strategyName),
                  localization.strategyDisabledDescription(strategyName),
                  true,
                ),
              (StrategyAvailability.missingPermissions) => buildError(
                  localization.strategyMissingPermissions(strategyName),
                  localization.strategyMissingPermissionsDescription(
                    strategyName,
                  ),
                  true,
                ),
              (StrategyAvailability.unsupported) => buildError(
                  localization.strategyUnsupported(strategyName),
                  localization.strategyUnsupportedDescription(strategyName),
                  true,
                ),
            }
        };
      }),
    );
  }
}
