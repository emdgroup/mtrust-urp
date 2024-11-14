import 'package:intl/intl.dart' as intl;

import 'ui_ui_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class UrpUiLocalizationsEn extends UrpUiLocalizations {
  UrpUiLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String nReadersFound(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n readers found',
      one: '1 reader found',
      zero: 'No readers found',
    );
    return '$_temp0';
  }

  @override
  String connect(String name) {
    return 'Connect to $name';
  }

  @override
  String retryConnect(String name) {
    return 'Retry connection to $name';
  }

  @override
  String get connectionFailed => 'Failed to connect to reader';

  @override
  String waitingForReader(String name) {
    return 'Looking for $name';
  }

  @override
  String get connectDifferentReader => 'Connect different reader';

  @override
  String get ensureTurnedOn => 'Please make sure the reader is turned on and in range';

  @override
  String get turnOnInstructions => 'Press the button on your reader to turn it on and make sure the indicator light is flashing blue';

  @override
  String get connecting => 'Connecting...';

  @override
  String get paired => 'Paired';

  @override
  String get pair => 'Pair';

  @override
  String get retry => 'Retry';

  @override
  String get searchAgain => 'Search again';

  @override
  String get lastUsed => 'Last used';

  @override
  String get error => 'Error';

  @override
  String strategyDisabled(String name) {
    return '$name is disabled';
  }

  @override
  String strategyDisabledDescription(String name) {
    return 'Please enable $name in the settings of your device';
  }

  @override
  String strategyMissingPermissions(String name) {
    return 'Missing $name permissions';
  }

  @override
  String strategyMissingPermissionsDescription(String name) {
    return 'Permission for $name is required to connect to the device';
  }

  @override
  String get strategyRequestPermissions => 'Request permission';

  @override
  String strategyUnsupported(String name) {
    return '$name is not supported';
  }

  @override
  String strategyUnsupportedDescription(String name) {
    return '$name is not available on this device';
  }

  @override
  String unableToPrepareStrategy(String name) {
    return 'Unable to prepare $name';
  }
}
