import 'package:flutter/material.dart';
import 'package:mtrust_urp_ui/mtrust_urp_ui.dart';

/// A widget that shows an M-Trust P-Reader
/// you can provide the [ledColor] and the [ledFlashingState]
class IMPReaderVisualization extends StatelessWidget {
  /// The color of the LED
  final Color ledColor;

  /// The state of the LED
  final FlashingState ledFlashingState;

  /// Creates a new instance of [IMPReaderVisualization]
  const IMPReaderVisualization({
    required this.ledColor,
    this.ledFlashingState = FlashingState.on,
    super.key,
  });

  /// Creates a new instance of [IMPReaderVisualization] with the LED off
  factory IMPReaderVisualization.off() {
    return const IMPReaderVisualization(
      ledColor: Colors.black,
      ledFlashingState: FlashingState.off,
    );
  }

  /// Creates a new instance of [IMPReaderVisualization] with the LED flashing
  factory IMPReaderVisualization.waitingForConnection() {
    return const IMPReaderVisualization(
      ledColor: Colors.blue,
      ledFlashingState: FlashingState.flashing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Stack(
        children: [
          // The reader image
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 50,
              minHeight: 50,
            ),
            child: Image.asset(
              "assets/imp_reader.png",
              package: "mtrust_urp_ui",
            ),
          ),

          // The LED
          Positioned.fill(
            child: FractionallySizedBox(
              alignment: const FractionalOffset(0.7015, 0.047),
              heightFactor: 0.03,
              widthFactor: 0.005,
              child: Transform.rotate(
                angle: -0.50,
                child: Flashing(
                  state: ledFlashingState,
                  builder: (_, value) => Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: ledColor.withAlpha((255 * value).toInt()),
                          blurRadius: 32,
                          spreadRadius: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
