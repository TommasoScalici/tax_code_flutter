import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'i18n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it')
  ];

  /// The title of the application, often shown in the app bar.
  ///
  /// In en, this message translates to:
  /// **'Tax Code'**
  String get appTitle;

  /// A welcome message on the login screen.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Tax Code, please sign in.'**
  String get pleaseSignIn;

  /// A welcome message on the registration screen.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Tax Code, please sign up.'**
  String get pleaseSignUp;

  /// A notice informing the user that they agree to the terms by signing in or up.
  ///
  /// In en, this message translates to:
  /// **'By signing in/up, you agree to our terms and conditions.'**
  String get termsAndCondition;

  /// Label for a button or link to display the terms and conditions.
  ///
  /// In en, this message translates to:
  /// **'Show terms and conditions'**
  String get showTerms;

  /// A validation error message for a required form field.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// Label for a button to create a new item, like a new contact.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newItem;

  /// Label for a button or section to fill in data.
  ///
  /// In en, this message translates to:
  /// **'Fill data'**
  String get fillData;

  /// Label for the first name input field.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// Label for the last name input field.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// Label for the gender input field or selector.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Label for the birth date input field.
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get birthDate;

  /// Label for the birth place input field.
  ///
  /// In en, this message translates to:
  /// **'Birth place'**
  String get birthPlace;

  /// Label for a confirmation button, typically in a dialog.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// The title for a dialog asking the user to confirm a delete action.
  ///
  /// In en, this message translates to:
  /// **'Delete confirmation'**
  String get deleteConfirmation;

  /// Label for a delete button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Label for a button or menu item to delete the user's account.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// Label for a button to sign out of the application.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get signOut;

  /// Label for a button to cancel an action, typically in a dialog.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label for a button to close a screen or dialog.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// A generic title for an informational dialog or screen.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// A generic title for an error dialog.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// An error message shown when loading data fails. An error code or message might be appended.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while loading contacts: '**
  String get errorLoading;

  /// Placeholder text inside a search bar.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// Label for a button that initiates scanning a card.
  ///
  /// In en, this message translates to:
  /// **'Scan card'**
  String get scanCard;

  /// Label for a button that opens the camera to take a picture.
  ///
  /// In en, this message translates to:
  /// **'Take a picture...'**
  String get takePicture;

  /// Title for a dialog informing the user that a permission is required.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// Label for a button that navigates the user to the app's settings on their device.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// An informational message explaining how to grant camera permission after it has been permanently denied.
  ///
  /// In en, this message translates to:
  /// **'The camera permission has been permanently denied.\nGo to the app settings, open the Permissions section, and enable the camera permission.'**
  String get cameraPermissionInfo;

  /// Label for the app name field in an info screen.
  ///
  /// In en, this message translates to:
  /// **'App name'**
  String get appName;

  /// Label for the package name field in an info screen.
  ///
  /// In en, this message translates to:
  /// **'Package name'**
  String get packageName;

  /// Label for the app version field in an info screen.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// Label for the build number field in an info screen.
  ///
  /// In en, this message translates to:
  /// **'Build number'**
  String get buildNumber;

  /// Label for the build signature field in an info screen.
  ///
  /// In en, this message translates to:
  /// **'Build signature'**
  String get buildSignature;

  /// Label for the installer store field in an info screen.
  ///
  /// In en, this message translates to:
  /// **'Installer store'**
  String get installerStore;

  /// A generic error message for network connection issues.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get errorConnection;

  /// A generic error message for unexpected or unknown errors.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error'**
  String get errorUnexpected;

  /// A user-friendly message for a generic error, asking them to retry.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, please try again later.'**
  String get errorOccurred;

  /// An error message indicating that there is no internet connection.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get errorNoInternet;

  /// A message displayed when a list of contacts is empty or a search returns no results.
  ///
  /// In en, this message translates to:
  /// **'No contacts found.'**
  String get noContactsFound;

  /// A confirmation message shown to the user before deleting their account.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? All your data will be permanently loss.'**
  String get deleteAccountMessage;

  /// A confirmation message for deleting a specific contact, which includes their tax code.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the contact with tax code \'{taxCode}\'?'**
  String deleteMessage(String taxCode);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
