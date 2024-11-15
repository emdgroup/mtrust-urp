import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class BatteryIndicator extends StatelessWidget {
  final int percentage;

  static int lowIndicatorPercentage = 20;

  const BatteryIndicator({
    required this.percentage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    int value = percentage;

    if (percentage < 0) {
      value = 0;
    }
    if (percentage > 100) {
      value = 100;
    }
    double innerBoxWidth = (18 * (value / 100)).clamp(0, 18);

    return LdAutoSpace(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  width: 22,
                  height: 11,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: LdTheme.of(context).neutralShade(6),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(2, 0),
                  child: AnimatedContainer(
                    curve: Curves.bounceOut,
                    duration: const Duration(milliseconds: 300),
                    width: innerBoxWidth,
                    height: 7,
                    decoration: BoxDecoration(
                      color: (value <= lowIndicatorPercentage)
                          ? LdTheme.of(context).errorColor
                          : LdTheme.of(context).neutralShade(10),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 1),
            Container(
              width: 1,
              height: 3,
              color: LdTheme.of(context).neutralShade(6),
            ),
          ],
        ),
      ],
    );
  }
}
