import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:mtrust_urp_ui/mtrust_urp_ui.dart';

typedef WidgetBuilder = Future<void> Function(
  WidgetTester tester,
  Future<void> Function(Widget widget) placeWidget,
);

Widget liquidFrame(Key key, Widget child, bool dark, LdThemeSize size) {
  final theme = LdTheme();
  theme.setThemeSize(size);
  return Localizations(
    delegates: const [
      GlobalWidgetsLocalizations.delegate,
      LiquidLocalizations.delegate,
      UrpUiLocalizations.delegate,
    ],
    locale: const Locale('en'),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: LdThemeProvider(
        theme: theme,
        autoSize: false,
        brightnessMode:
            dark ? LdThemeBrightnessMode.dark : LdThemeBrightnessMode.light,
        child: Builder(builder: (context) {
          return Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: theme.radius(LdSize.m),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Builder(builder: (context) {
                return SingleChildScrollView(
                  child: Center(key: key, child: child),
                );
              }),
            ),
          );
        }),
      ),
    ),
  );
}

Future<void> multiGolden(
  WidgetTester tester,
  String name,
  Map<String, WidgetBuilder> widgets, {
  int width = 900,
}) async {
  ldDisableAnimations = true;
  await loadAppFonts();

  for (final entry in widgets.entries) {
    for (final themeSize in LdThemeSize.values) {
      for (final brightness in Brightness.values) {
        final slug = "${entry.key}/"
            "${themeSize.toString().split(".").last}"
            "-${brightness.toString().split(".").last}";
        await tester.binding.setSurfaceSize(
          Size(width.toDouble(), 1000),
        );

        await entry.value(tester, (widget) async {
          await tester.pumpWidget(
            liquidFrame(
              ValueKey(slug),
              widget,
              brightness == Brightness.dark,
              themeSize,
            ),
          );
        });

        final size =
            find.byKey(ValueKey(slug)).evaluate().single.size ?? Size.zero;

        await tester.pumpAndSettle();

        await tester.binding.setSurfaceSize(
          Size(width.toDouble(), size.height + 64),
        );

        await tester.pumpAndSettle();

        await screenMatchesGolden(tester, "$name/$slug");
      }
    }
  }
}
