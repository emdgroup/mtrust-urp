import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:mtrust_urp_ui/mtrust_urp_ui.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

enum ReaderThumbnailMode {
  carousel,
  highlight,
  hidden,
  highlightGrayed,
}

/// Renders a thumbnail of a reader. Can be used in a carousel or as a highlight.
class ReaderThumbnail extends StatelessWidget {
  final FoundDevice reader;

  final ReaderThumbnailMode mode;

  final Function() onTap;

  final Widget? badge;

  final double distanceFromCenter;

  const ReaderThumbnail({
    required this.reader,
    this.mode = ReaderThumbnailMode.carousel,
    required this.onTap,
    required this.distanceFromCenter,
    this.badge,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LdTouchableSurface(
      onTap: onTap,
      color: LdTheme.of(context).palette.primary,
      builder: (context, colors, touchState) {
        return LdSpring(
          initialPosition: 0,
          position: switch (mode) {
            (ReaderThumbnailMode.carousel) => 0,
            (ReaderThumbnailMode.highlight) => 1,
            (ReaderThumbnailMode.highlightGrayed) => 1,
            (ReaderThumbnailMode.hidden) => 0,
          },
          builder: (context, state) {
            double scale = switch (mode) {
              (ReaderThumbnailMode.carousel) =>
                (1 - distanceFromCenter).clamp(0.5, 1),
              (ReaderThumbnailMode.highlight) => 1,
              (ReaderThumbnailMode.highlightGrayed) => 1,
              (ReaderThumbnailMode.hidden) => 0,
            };

            double opacity = switch (mode) {
              (ReaderThumbnailMode.carousel) =>
                (1 - distanceFromCenter).clamp(0.3, 1),
              (ReaderThumbnailMode.highlight) => 1,
              (ReaderThumbnailMode.highlightGrayed) => 0.6,
              (ReaderThumbnailMode.hidden) => 0,
            };

            return LdAutoSpace(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Reader image
                Expanded(
                  child: Opacity(
                    opacity: opacity,
                    child: LdSpring(
                        initialPosition: 0,
                        position: scale + (touchState.active ? 0.1 : 0),
                        builder: (context, scrollState) {
                          return Transform.scale(
                            scale: scrollState.position * 0.9,
                            child: SizedBox(
                              height: 200,
                              child: switch (reader.type) {
                                (UrpDeviceType.urpSec) =>
                                  SecReaderVisualization.waitingForConnection(),
                                (UrpDeviceType.urpImp) =>
                                  IMPReaderVisualization.waitingForConnection(),
                                _ => throw UnimplementedError(),
                              },
                            ),
                          );
                        }),
                  ),
                ),
                // Preferred badge

                // Badge is revealed seperately to make sure the readers
                // align when scrolled away from center
                if (badge != null)
                  LdReveal.quick(
                    revealed: mode == ReaderThumbnailMode.carousel &&
                        distanceFromCenter < 0.5,
                    child: Opacity(
                      opacity: (1 - distanceFromCenter).clamp(0.0, 1),
                      child: badge,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
