import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

/// Widget used inside a [DeviceCarousel] to indicate the current index
class DeviceCarouselDotIndicator extends StatelessWidget {
  final int currentIndex;
  final List<FoundDevice> devices;

  /// The index that should be marked as preferred, will use a star icon
  /// and color using the [LdTheme.warningColor]
  final int? preferredIndex;

  /// The builder for the preferred badge
  final Widget Function(BuildContext context, FoundDevice device)?
      preferredBadgeBuilder;

  const DeviceCarouselDotIndicator({
    super.key,
    required this.devices,
    required this.currentIndex,
    this.preferredIndex,
    required this.preferredBadgeBuilder,
  });

  Color _getColor(BuildContext context, int i) {
    if (preferredIndex != null && i == preferredIndex) {
      return LdTheme.of(context).primaryColor;
    }
    return i == currentIndex
        ? LdTheme.of(context).neutralShade(6)
        : LdTheme.of(context).neutralShade(3);
  }

  Widget _buildDot(BuildContext context, int index) {
    final color = _getColor(context, index);
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      height: 8,
      width: 8,
    );
  }

  Widget _buildPreffered(BuildContext context) {
    return Column(
      children: [
        _buildDot(context, preferredIndex!),
        if (preferredBadgeBuilder != null)
          LdReveal.quick(
            revealed: currentIndex == preferredIndex,
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: preferredBadgeBuilder!(context, devices[preferredIndex!]),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        for (var i = 0; i < devices.length; i++)
          if (i == preferredIndex)
            _buildPreffered(context)
          else
            _buildDot(context, i)
      ],
    );
  }
}
