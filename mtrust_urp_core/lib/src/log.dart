import 'dart:convert';

import 'package:logger/logger.dart';

/// The logger used for the URP Core
final Logger urpLogger = Logger(
  printer: _SimplePrinter(
    colors: false,
    prefix: 'URP-CORE',
  ),
);

class _SimplePrinter extends LogPrinter {
  _SimplePrinter({
    this.colors = true,
    this.prefix,
  });
  static final levelPrefixes = {
    Level.trace: '[V]',
    Level.debug: '[D]',
    Level.info: '[I]',
    Level.warning: '[W]',
    Level.error: '[E]',
    Level.fatal: '[WTF]',
  };

  static final levelColors = {
    Level.trace: AnsiColor.fg(AnsiColor.grey(0.5)),
    Level.debug: const AnsiColor.none(),
    Level.info: const AnsiColor.fg(12),
    Level.warning: const AnsiColor.fg(208),
    Level.error: const AnsiColor.fg(196),
    Level.fatal: const AnsiColor.fg(199),
  };

  final bool colors;
  final String? prefix;

  @override
  List<String> log(LogEvent event) {
    final messageStr = _stringifyMessage(event.message);
    final errorStr = event.error != null ? '  ERROR: ${event.error}' : '';

    final prefixStr = prefix != null ? '[$prefix]' : '';

    return [
      '$prefixStr${_labelFor(event.level)} $messageStr$errorStr',
    ];
  }

  String _labelFor(Level level) {
    final prefix = levelPrefixes[level]!;
    final color = levelColors[level]!;

    return colors ? color(prefix) : prefix;
  }

  String _stringifyMessage(dynamic message) {
    // ignore: avoid_dynamic_calls
    final finalMessage = message is Function ? message() : message;
    if (finalMessage is Map || finalMessage is Iterable) {
      const encoder = JsonEncoder.withIndent(null);
      return encoder.convert(finalMessage);
    } else {
      return finalMessage.toString();
    }
  }
}
