import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:mtrust_urp_ui/mtrust_urp_ui.dart';
import 'package:mtrust_urp_ui/src/device_connector/dot_indicator.dart';
import 'package:mtrust_urp_ui/src/device_connector/reader_thumbnail.dart';
import 'package:mtrust_urp_ui/src/device_connector/scanning_header.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';

class ReaderCarousel extends StatefulWidget {
  /// A stream of found readers
  final Stream<FoundDevice> readers;

  /// The address of the preferred reader
  final String? preferredReaderAddress;

  /// A function to tell the [ConnectionStrategy] to restart scanning
  final Future<void> Function()? restartScanning;

  /// A function to build a badge for the preferred reader
  final Widget Function(BuildContext context, FoundDevice reader)?
      prefferedBadgeBuilder;

  /// A function to build the action widget below the selected reader
  final Future<bool> Function(FoundDevice reader) onConnect;

  /// The types of devices to show
  final Set<UrpDeviceType> types;

  /// Creates a new instance of [ReaderCarousel]
  const ReaderCarousel({
    required this.readers,
    required this.onConnect,
    this.restartScanning,
    this.preferredReaderAddress,
    this.prefferedBadgeBuilder,
    required this.types,
    super.key,
  });

  @override
  State<ReaderCarousel> createState() => _ReaderCarouselState();
}

class _ReaderCarouselState extends State<ReaderCarousel> {
  double _page = 1;
  int _lastPage = 1;
  bool _isDone = false;

  final PageController _pageController = PageController(
    initialPage: 1,
    viewportFraction: 0.4,
  );

  StreamSubscription<FoundDevice>? _readerSubscription;

  @override
  void initState() {
    // Listen for new readers
    _listenToStream();
    _pageController.addListener(_onPageChanged);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ReaderCarousel oldWidget) {
    if (oldWidget.readers != widget.readers) {
      _readerSubscription?.cancel();
      _listenToStream();
      setState(() {
        _readers.clear();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  void _listenToStream() {
    _isDone = false;
    _readerSubscription = widget.readers.listen((reader) {
      HapticFeedback.heavyImpact();
      setState(() {
        _readers.add(reader);
        if (reader.address == widget.preferredReaderAddress) {
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              _readers.indexOf(reader),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
      });
    }, onDone: () {
      setState(() {
        _isDone = true;
      });
    });
  }

  void _onPageChanged() {
    final current = _pageController.page ?? 1.0;

    // When the user moves a full page, vibrate and update the state
    if (current.round() != _lastPage) {
      HapticFeedback.selectionClick();
      _lastPage = current.round();
    }

    setState(() {
      _page = current;
    });
  }

  FoundDevice? get _selectedReader {
    if (_readers.isEmpty) {
      return null;
    }

    final currentIndex = _page.round().clamp(0, _readers.length - 1);
    return _readers[currentIndex];
  }

  @override
  dispose() {
    _pageController.dispose();
    _readerSubscription?.cancel();
    super.dispose();
  }

  final List<FoundDevice> _readers = [];

  Widget _buildReaderPreview(FoundDevice reader, LdSubmitStateType type) {
    final i = _readers.indexOf(reader);
    final distance = (i - _page).abs();

    final isSelectedReader = distance < 0.5;

    var mode = ReaderThumbnailMode.carousel;

    if (type == LdSubmitStateType.loading) {
      if (isSelectedReader) {
        mode = ReaderThumbnailMode.highlight;
      } else {
        mode = ReaderThumbnailMode.hidden;
      }
    }

    if (type == LdSubmitStateType.error) {
      if (isSelectedReader) {
        mode = ReaderThumbnailMode.highlightGrayed;
      } else {
        mode = ReaderThumbnailMode.hidden;
      }
    }

    return ReaderThumbnail(
      reader: reader,
      mode: mode,
      onTap: () {
        _pageController.animateToPage(
          _readers.indexOf(reader),
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 200),
        );
      },
      distanceFromCenter: distance,
    );
  }

  /// Build a row of images for each reader type passed [types]
  Widget _buildReaderTypes(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...widget.types.map((type) {
            return Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                      child: switch (type) {
                    (UrpDeviceType.urpSec) => SecReaderVisualization.off(),
                    (UrpDeviceType.urpImp) => IMPReaderVisualization.off(),
                    _ => throw UnimplementedError(),
                  }),
                ).padS(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return LdReveal(
      revealed: true,
      initialRevealed: false,
      child: LdAutoSpace(children: [
        // Nothing was found show instructions and a button to search again
        _buildReaderTypes(context),

        LdTextP(
          UrpUiLocalizations.of(context).turnOnInstructions,
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LdSubmit<bool>(
      config: LdSubmitConfig<bool>(
        action: () async {
          final connected = await widget.onConnect(_selectedReader!);

          if (!connected) {
            throw Exception("Failed to connect");
          }
          return connected;
        },
      ),
      builder: LdSubmitCustomBuilder<bool>(
        builder: (context, submit, type) {
          return LdAutoSpace(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ldSpacerS,
              ScanningHeader(
                nReadersFound: _readers.length,
                isScanning: !_isDone,
                state: type,
              ),

              if (_readers.isEmpty) Expanded(child: _buildEmptyState()),
              LdReveal.quick(
                revealed: _isDone && type == LdSubmitStateType.idle,
                child: LdButton(
                  mode: _readers.isNotEmpty
                      ? LdButtonMode.ghost
                      : LdButtonMode.vague,
                  size: _readers.isNotEmpty ? LdSize.s : LdSize.m,
                  onPressed: widget.restartScanning!,
                  child: Text(UrpUiLocalizations.of(context).searchAgain),
                ),
              ),
              ldSpacerL,

              if (_readers.isNotEmpty)
                // Show the readers found
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: type != LdSubmitStateType.idle
                        ? const NeverScrollableScrollPhysics()
                        : const PageScrollPhysics(),
                    children: [
                      for (var reader in _readers)
                        _buildReaderPreview(
                          reader,
                          type,
                        ),
                    ],
                  ),
                ),

              // Page indicator only if more than one reader
              LdReveal.quick(
                revealed: _readers.isNotEmpty && type == LdSubmitStateType.idle,
                child: DeviceCarouselDotIndicator(
                  devices: _readers,
                  currentIndex: _page.round(),
                  preferredIndex: _readers.indexWhere(
                    (reader) => reader.address == widget.preferredReaderAddress,
                  ),
                  preferredBadgeBuilder: widget.prefferedBadgeBuilder,
                ),
              ),

              ldSpacerL,

              // Connect button
              _buildConnectButton(context, submit),

              LdReveal.quick(
                revealed: type == LdSubmitStateType.error,
                child: LdAutoSpace(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LdTextP(
                      UrpUiLocalizations.of(context).ensureTurnedOn,
                      textAlign: TextAlign.center,
                    ),
                    // Connect to a different reader
                    LdButtonGhost(
                      child: Text(
                        UrpUiLocalizations.of(context).connectDifferentReader,
                      ),
                      onPressed: () {
                        submit.reset();
                        widget.restartScanning?.call();
                      },
                    ),
                    // Retry the same connection
                    LdButton(
                      onPressed: submit.trigger,
                      child: Text(
                        UrpUiLocalizations.of(context)
                            .retryConnect(_selectedReader?.name ?? ""),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildConnectButton(
    BuildContext context,
    LdSubmitController<dynamic> submit,
  ) {
    return LdReveal.quick(
      revealed:
          _readers.isNotEmpty && submit.state.type != LdSubmitStateType.error,
      child: LdButton(
        key: const Key("connect_button"),
        mode: LdButtonMode.vague,
        loading: submit.state.type == LdSubmitStateType.loading,
        loadingText: UrpUiLocalizations.of(context).connecting,
        onPressed: submit.trigger,
        child: Text(
          UrpUiLocalizations.of(context).connect(_selectedReader?.name ?? ""),
        ),
      ),
    );
  }
}
