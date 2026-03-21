import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'ui_ui_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of UrpUiLocalizations
/// returned by `UrpUiLocalizations.of(context)`.
///
/// Applications need to include `UrpUiLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/ui_ui_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: UrpUiLocalizations.localizationsDelegates,
///   supportedLocales: UrpUiLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the UrpUiLocalizations.supportedLocales
/// property.
abstract class UrpUiLocalizations {
  UrpUiLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static UrpUiLocalizations of(BuildContext context) {
    return Localizations.of<UrpUiLocalizations>(context, UrpUiLocalizations)!;
  }

  static const LocalizationsDelegate<UrpUiLocalizations> delegate = _UrpUiLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// No description provided for @nReadersFound.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =0{No readers found} =1{1 reader found} other{{n} readers found}}'**
  String nReadersFound(int n);

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect to {name}'**
  String connect(String name);

  /// No description provided for @retryConnect.
  ///
  /// In en, this message translates to:
  /// **'Retry connection to {name}'**
  String retryConnect(String name);

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to reader'**
  String get connectionFailed;

  /// No description provided for @waitingForReader.
  ///
  /// In en, this message translates to:
  /// **'Looking for {name}'**
  String waitingForReader(String name);

  /// No description provided for @connectDifferentReader.
  ///
  /// In en, this message translates to:
  /// **'Connect different reader'**
  String get connectDifferentReader;

  /// No description provided for @ensureTurnedOn.
  ///
  /// In en, this message translates to:
  /// **'Please make sure the reader is turned on and in range'**
  String get ensureTurnedOn;

  /// No description provided for @turnOnInstructions.
  ///
  /// In en, this message translates to:
  /// **'Press the button on your reader to turn it on and make sure the indicator light is flashing blue'**
  String get turnOnInstructions;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @paired.
  ///
  /// In en, this message translates to:
  /// **'Paired'**
  String get paired;

  /// No description provided for @pair.
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get pair;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @searchAgain.
  ///
  /// In en, this message translates to:
  /// **'Search again'**
  String get searchAgain;

  /// No description provided for @lastUsed.
  ///
  /// In en, this message translates to:
  /// **'Last used'**
  String get lastUsed;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @strategyDisabled.
  ///
  /// In en, this message translates to:
  /// **'{name} is disabled'**
  String strategyDisabled(String name);

  /// No description provided for @strategyDisabledDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enable {name} in the settings of your device'**
  String strategyDisabledDescription(String name);

  /// No description provided for @strategyMissingPermissions.
  ///
  /// In en, this message translates to:
  /// **'Missing {name} permissions'**
  String strategyMissingPermissions(String name);

  /// No description provided for @strategyMissingPermissionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Permission for {name} is required to connect to the device'**
  String strategyMissingPermissionsDescription(String name);

  /// No description provided for @strategyRequestPermissions.
  ///
  /// In en, this message translates to:
  /// **'Request permission'**
  String get strategyRequestPermissions;

  /// No description provided for @strategyUnsupported.
  ///
  /// In en, this message translates to:
  /// **'{name} is not supported'**
  String strategyUnsupported(String name);

  /// No description provided for @strategyUnsupportedDescription.
  ///
  /// In en, this message translates to:
  /// **'{name} is not available on this device'**
  String strategyUnsupportedDescription(String name);

  /// No description provided for @unableToPrepareStrategy.
  ///
  /// In en, this message translates to:
  /// **'Unable to prepare {name}'**
  String unableToPrepareStrategy(String name);
}

class _UrpUiLocalizationsDelegate extends LocalizationsDelegate<UrpUiLocalizations> {
  const _UrpUiLocalizationsDelegate();

  @override
  Future<UrpUiLocalizations> load(Locale locale) {
    return SynchronousFuture<UrpUiLocalizations>(lookupUrpUiLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_UrpUiLocalizationsDelegate old) => false;
}

UrpUiLocalizations lookupUrpUiLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return UrpUiLocalizationsEn();
  }

  throw FlutterError(
    'UrpUiLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
