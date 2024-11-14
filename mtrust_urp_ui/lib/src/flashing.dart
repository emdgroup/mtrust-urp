import 'package:flutter/widgets.dart';

bool urpUiDisableAnimations = false;

/// State the flashing widget is in
enum FlashingState {
  /// The widget is hidden
  off,

  /// The widget is visible
  on,

  /// The widget is flashing
  flashing,
}

/// Widget that flashes its child
class Flashing extends StatefulWidget {
  /// Creates a new instance of [Flashing]
  const Flashing({
    required this.state,
    required this.builder,
    super.key,
    this.duration = const Duration(milliseconds: 500),
  });

  final Function(BuildContext context, double value) builder;

  /// The duration of the flash
  final Duration duration;

  /// The state of the flashing widget
  final FlashingState state;

  @override
  State<Flashing> createState() => _FlashingState();
}

class _FlashingState extends State<Flashing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _applyAnimation();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Flashing oldWidget) {
    if (oldWidget.state == widget.state) {
      return;
    }
    _applyAnimation();
    super.didUpdateWidget(oldWidget);
  }

  void _applyAnimation() {
    // Disable animations if the flag is set, makes testing easier
    if (urpUiDisableAnimations) {
      _controller.value = switch (widget.state) {
        (FlashingState.off) => 0.0,
        (FlashingState.on) => 1.0,
        (FlashingState.flashing) => 1.0,
      };
      return;
    }
    if (widget.state == FlashingState.flashing) {
      _controller.repeat(reverse: true);
    }
    if (widget.state == FlashingState.on) {
      _controller.forward();
    }
    if (widget.state == FlashingState.off) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return widget.builder(context, _controller.value);
      },
    );
  }
}
