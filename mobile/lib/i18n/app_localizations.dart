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

  /// Label for a confirmation button.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Label for a button to cancel an action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label for a button to close a screen or dialog.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Label for a delete button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Label for an edit button.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Label for a share button.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// A generic title for an informational dialog or screen.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// A welcome message on the login screen.
  ///
  /// In en, this message translates to:
  /// **'Welcome, please sign in to continue.'**
  String get pleaseSignIn;

  /// A welcome message on the registration screen.
  ///
  /// In en, this message translates to:
  /// **'Welcome, please create an account to continue.'**
  String get pleaseSignUp;

  /// Label for a button to sign out of the application.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Label for a button to delete the user's account.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// A confirmation message shown to the user before deleting their account.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? All your data will be permanently lost. This action is irreversible.'**
  String get deleteAccountMessage;

  /// Title for the main home page.
  ///
  /// In en, this message translates to:
  /// **'My Contacts'**
  String get homePageTitle;

  /// Title for the user profile screen.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profilePageTitle;

  /// Title for the page where user enters contact details.
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get formPageTitle;

  /// Title for the page displaying the barcode.
  ///
  /// In en, this message translates to:
  /// **'Tax Code Barcode'**
  String get barcodePageTitle;

  /// Title for the camera screen.
  ///
  /// In en, this message translates to:
  /// **'Scan Card'**
  String get takePicture;

  /// Tooltip for the FloatingActionButton to create a new contact.
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get newItem;

  /// Placeholder text inside a search bar.
  ///
  /// In en, this message translates to:
  /// **'Search by name or tax code...'**
  String get search;

  /// Message displayed when the contact list is empty.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet.\nTap the \'+\' button to add your first one!'**
  String get contactsListEmpty;

  /// Message displayed when a search yields no results.
  ///
  /// In en, this message translates to:
  /// **'No results found for \'{searchText}\''**
  String searchNoResults(String searchText);

  /// Tooltip for the share button on a contact card.
  ///
  /// In en, this message translates to:
  /// **'Share Tax Code'**
  String get tooltipShare;

  /// Tooltip for the barcode button on a contact card.
  ///
  /// In en, this message translates to:
  /// **'Show Barcode'**
  String get tooltipShowBarcode;

  /// Tooltip for the edit button on a contact card.
  ///
  /// In en, this message translates to:
  /// **'Edit Contact'**
  String get tooltipEdit;

  /// Tooltip for the delete button on a contact card.
  ///
  /// In en, this message translates to:
  /// **'Delete Contact'**
  String get tooltipDelete;

  /// Label for a button that initiates scanning a card.
  ///
  /// In en, this message translates to:
  /// **'Scan from Health Card'**
  String get scanCard;

  /// Label for the first name input field.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// Label for the last name input field.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// Label for the gender input field.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Label for the birth date input field.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get birthDate;

  /// Label for the birth place input field.
  ///
  /// In en, this message translates to:
  /// **'Place of Birth'**
  String get birthPlace;

  /// A validation error message for a required form field.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get required;

  /// The title for a dialog asking the user to confirm a delete action.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get deleteConfirmation;

  /// A confirmation message for deleting a specific contact.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete the contact for \'{taxCode}\'?'**
  String deleteMessage(String taxCode);

  /// Title for a dialog informing the user that a permission is required.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// An informational message explaining how to grant camera permission.
  ///
  /// In en, this message translates to:
  /// **'To scan cards, this app needs access to your camera. Please go to your device settings and grant camera permission.'**
  String get cameraPermissionInfo;

  /// Label for a button that navigates the user to the app's settings page.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// A generic title for an error dialog.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// A user-friendly message for a generic error, asking them to retry.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// Tooltip for the button that toggles the camera flash on and off.
  ///
  /// In en, this message translates to:
  /// **'Toggle flash'**
  String get tooltipToggleFlash;

  /// Tooltip for the button to capture a picture.
  ///
  /// In en, this message translates to:
  /// **'Take picture'**
  String get tooltipTakePicture;

  /// Tooltip for the button to confirm the captured picture and proceed.
  ///
  /// In en, this message translates to:
  /// **'Confirm picture'**
  String get tooltipConfirmPicture;

  /// Tooltip for the button to discard the current picture and take a new one.
  ///
  /// In en, this message translates to:
  /// **'Retake picture'**
  String get tooltipRetakePicture;

  /// A notice about agreeing to terms and conditions.
  ///
  /// In en, this message translates to:
  /// **'By proceeding, you agree to our Terms and Conditions.'**
  String get termsAndCondition;

  /// Label for a button to display the terms and conditions.
  ///
  /// In en, this message translates to:
  /// **'View Terms & Conditions'**
  String get showTerms;

  /// Label for the app name field in an info screen.
  ///
  /// In en, this message translates to:
  /// **'App Name'**
  String get appName;

  /// Label for the package name field in an info screen.
  ///
  /// In en, this message translates to:
  /// **'Package Name'**
  String get packageName;

  /// Label for the app version field in an info screen.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get appVersion;

  /// Label for the build number field in an info screen.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get buildNumber;

  /// Label for the build signature field in an info screen.
  ///
  /// In en, this message translates to:
  /// **'Build Signature'**
  String get buildSignature;

  /// Label for the installer store field in an info screen.
  ///
  /// In en, this message translates to:
  /// **'Installer Store'**
  String get installerStore;
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
