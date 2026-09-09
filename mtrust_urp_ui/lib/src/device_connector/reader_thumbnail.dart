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

  final double distanceFromCenter;

  const ReaderThumbnail({
    required this.reader,
    this.mode = ReaderThumbnailMode.carousel,
    required this.onTap,
    required this.distanceFromCenter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return LdTouchableSurface(
      onTap: onTap,
      color: theme.palette.primary,
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
                                  SecReaderVisualization.waitingForConnection(
                                    cutoffGradientColor: theme.surface,
                                  ),
                                (UrpDeviceType.urpImp) =>
                                  IMPReaderVisualization.waitingForConnection(),
                                // Device types without a bespoke
                                // visualization (urpImz, urpPsu, urpTsc, ...)
                                // fall back to a generic placeholder. This
                                // used to `throw UnimplementedError()`, which
                                // surfaced as Flutter's red error box in the
                                // reader carousel.
                                _ => _GenericReaderVisualization(
                                  theme: theme,
                                ),
                              },
                            ),
                          );
                        }),
                  ),
                ),
                // Preferred badge
              ],
            );
          },
        );
      },
    );
  }
}

/// Neutral stand-in artwork for reader types that don't (yet) have their own
/// visualization widget, so the carousel can still render them.
///
/// Deliberately generic: a rounded "device" body with a small indicator dot,
/// tinted from the active [LdTheme] so it sits alongside the real reader
/// visualizations without looking broken.
class _GenericReaderVisualization extends StatelessWidget {
  const _GenericReaderVisualization({required this.theme});

  final LdTheme theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 0.62,
        child: Container(
          decoration: BoxDecoration(
            color: theme.neutralShade(2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.neutralShade(5), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sensors,
                size: 48,
                color: theme.neutralShade(8),
              ),
              const SizedBox(height: 12),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: theme.neutralShade(6),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
