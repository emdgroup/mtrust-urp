import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

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

    return LdSubmit<StrategyAvailability>(
      config: LdSubmitConfig<StrategyAvailability>(
        action: () => strategy.availability,
        autoTrigger: true,
        allowResubmit: true,
      ),
      builder: LdSubmitCustomBuilder<StrategyAvailability>(
          builder: (context, controller, stateType) {
        // Helper function to build an error message
        Widget buildError(String title, String submessage, bool canRetry) {
          return Center(
            child: LdAutoSpace(
              animate: true,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LdTextHs(
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

        final retry = LdButton(
          onPressed: controller.trigger,
          child: Text(UrpUiLocalizations.of(context).retry),
        );

        final localization = UrpUiLocalizations.of(context);
        return switch (stateType) {
          LdSubmitStateType.idle => retry,
          LdSubmitStateType.loading => const LdLoader(),
          LdSubmitStateType.error => buildError(
              localization.error,
              localization.unableToPrepareStrategy(strategyName),
              true,
            ),
          LdSubmitStateType.result => switch (
                controller.state.result as StrategyAvailability) {
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
