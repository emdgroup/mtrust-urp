import 'package:flutter/material.dart';
import 'package:mtrust_urp_ui/src/flashing.dart';

/// A widget that shows an M-Trust SEC-Reader
/// you can provide the [ledColor] and the [ledFlashingState]
/// and place widgets on the screen with [screenContent]
class SecReaderVisualization extends StatelessWidget {
  /// The color of the LED
  final Color ledColor;

  /// The state of the LED
  final FlashingState ledFlashingState;

  /// The color of the button
  final Color buttonColor;

  /// The state of the button
  final FlashingState buttonFlashingState;

  /// The content of the screen
  final Widget screenContent;

  /// Creates a new instance of [SecReaderVisualization]
  const SecReaderVisualization({
    required this.ledColor,
    this.ledFlashingState = FlashingState.on,
    this.buttonColor = Colors.black,
    this.buttonFlashingState = FlashingState.off,
    required this.screenContent,
    super.key,
  });

  /// Creates a new instance of [SecReaderVisualization] with the LED off and no screen
  /// content
  factory SecReaderVisualization.off() {
    return const SecReaderVisualization(
      ledColor: Colors.black,
      ledFlashingState: FlashingState.off,
      buttonColor: Colors.blue,
      buttonFlashingState: FlashingState.flashing,
      screenContent: Text(""),
    );
  }

  /// Creates a new instance of [SecReaderVisualization] with the LED flashing and the
  /// screen content set to "Connecting..."
  factory SecReaderVisualization.waitingForConnection({
    Color cutoffGradientColor = Colors.transparent,
  }) {
    return const SecReaderVisualization(
      ledColor: Colors.blue,
      ledFlashingState: FlashingState.flashing,
      screenContent: Center(child: Text("Connecting...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.hardEdge,
          fit: BoxFit.contain,
          child: Stack(
            children: [
              // The reader image
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 1,
                  minHeight: 1,
                ),
                child: Image.asset(
                  "assets/sec_reader.png",
                  package: "mtrust_urp_ui",
                ),
              ),
              Positioned.fill(
                  child: FractionallySizedBox(
                alignment: const FractionalOffset(0.5, 0.18),
                heightFactor: 0.14 * 1 * 0.12466124661246612,
                widthFactor: 0.39 * 1,
                child: Flashing(
                  state: ledFlashingState,
                  builder: (_, value) => CustomPaint(
                    painter: RPSCustomPainter(
                      color: ledColor.withAlpha((255 * value).toInt()),
                    ),
                  ),
                ),
              )),

              // The screen content
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: const FractionalOffset(0.5, 0.33),
                  heightFactor: 0.08,
                  widthFactor: 0.5,
                  child: DefaultTextStyle(
                    style: const TextStyle(fontSize: 72, color: Colors.white),
                    textAlign: TextAlign.center,
                    child: screenContent,
                  ),
                ),
              ),
              // Button overlay
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: const FractionalOffset(0.5, 0.66),
                  heightFactor: 0.51,
                  widthFactor: 0.51,
                  child: Flashing(
                    duration: const Duration(seconds: 2),
                    state: buttonFlashingState,
                    builder: (context, value) => Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  buttonColor.withAlpha((255 * value).toInt()),
                              width: 8,
                            ),
                            gradient: RadialGradient(colors: [
                              buttonColor
                                  .withAlpha((value * 0.5 * 255).toInt()),
                              buttonColor
                                  .withAlpha((value * 0.2 * 255).toInt()),
                            ]),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Transform.scale(
                          scale: (value * 0.1 + 1),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: buttonColor.withAlpha(
                                  (255 * value * 0.5).toInt(),
                                ),
                                width: 8,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: (value * 0.2 + 1),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: buttonColor.withAlpha(
                                  (value * 0.2 * 255).toInt(),
                                ),
                                width: 8,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RPSCustomPainter extends CustomPainter {
  final Color color;

  RPSCustomPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.4993794, size.height * 0.005493826);
    path_0.cubicTo(
        size.width * 0.3182195,
        size.height * 0.01321091,
        size.width * 0.1444539,
        size.height * 0.1557309,
        0,
        size.height * 0.3264913);
    path_0.cubicTo(
        0,
        size.height * 0.3264913,
        size.width * 0.03658537,
        size.height * 0.7011457,
        size.width * 0.06368564,
        size.height * 0.9059304);
    path_0.cubicTo(
        size.width * 0.07046070,
        size.height * 0.9571261,
        size.width * 0.08672087,
        size.height * 1.019828,
        size.width * 0.1372507,
        size.height * 0.9707217);
    path_0.cubicTo(
        size.width * 0.2262873,
        size.height * 0.8841913,
        size.width * 0.3639648,
        size.height * 0.8098413,
        size.width * 0.4993794,
        size.height * 0.8098413);
    path_0.cubicTo(
        size.width * 0.5929621,
        size.height * 0.8098413,
        size.width * 0.7615176,
        size.height * 0.8924652,
        size.width * 0.8598672,
        size.height * 0.9707217);
    path_0.cubicTo(
        size.width * 0.9159892,
        size.height * 1.015376,
        size.width * 0.9295393,
        size.height * 0.9669457,
        size.width * 0.9376694,
        size.height * 0.9059304);
    path_0.cubicTo(size.width * 0.9620596, size.height * 0.7228848, size.width,
        size.height * 0.3248500, size.width, size.height * 0.3248500);
    path_0.cubicTo(
        size.width * 0.8558482,
        size.height * 0.1547457,
        size.width * 0.6799377,
        size.height * 0.01321091,
        size.width * 0.4993794,
        size.height * 0.005493826);
    path_0.close();

    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = color;
    canvas.drawPath(path_0, paint0Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
