import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Widget used inside a [DeviceCarousel] to indicate the current index
class DeviceCarouselDotIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  /// The index that should be marked as preferred, will use a star icon
  /// and color using the [LdTheme.warningColor]
  final int? preferredIndex;

  const DeviceCarouselDotIndicator({super.key, 
    required this.count,
    required this.currentIndex,
    this.preferredIndex,
  });

  Color _getColor(BuildContext context, int i) {
    if (preferredIndex != null && i == preferredIndex) {
      return LdTheme.of(context)
          .warningColor
          .withOpacity(i == currentIndex ? 1 : 0.5);
    }
    return i == currentIndex
        ? LdTheme.of(context).neutralShade(6)
        : LdTheme.of(context).neutralShade(3);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          if (i == preferredIndex)
            Icon(
              Icons.star,
              color: _getColor(context, i),
              size: 14,
            )
          else
            Container(
              height: 8,
              width: 8,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _getColor(context, i),
                shape: BoxShape.circle,
              ),
            )
      ],
    );
  }
}
