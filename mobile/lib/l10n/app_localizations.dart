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
/// import 'l10n/app_localizations.dart';
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
    Locale('it'),
  ];

  /// Header title for profile and settings bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Account & Settings'**
  String get accountAndSettings;

  /// Subtitle for app information item with dynamic version.
  ///
  /// In en, this message translates to:
  /// **'Version {version} • Legal notes and Privacy Policy'**
  String appInfoSubtitle(String version);

  /// Title for the app information item and sub-view.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get appInfoTitle;

  /// Application name shown in legal details and app info.
  ///
  /// In en, this message translates to:
  /// **'Tax Code'**
  String get appName;

  /// The title of the application, often shown in the app bar.
  ///
  /// In en, this message translates to:
  /// **'Tax Code'**
  String get appTitle;

  /// Label for the 1D Code 128 barcode in the bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Barcode (Code 128)'**
  String get barcodeCode128;

  /// Notice indicating screen brightness is set to maximum for easy optical scanning.
  ///
  /// In en, this message translates to:
  /// **'Maximum brightness active for optical scanning'**
  String get barcodeMaxBrightnessActive;

  /// Informational hint displayed under the barcode and QR code for use at service desks.
  ///
  /// In en, this message translates to:
  /// **'Show at pharmacy or healthcare desk'**
  String get barcodeNotice;

  /// Text divider between the 1D barcode and the 2D QR code.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get barcodeOrDivider;

  /// Label for the 2D health QR code in the bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Health QR Code'**
  String get barcodeQrCode;

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

  /// Placeholder format for the birth date input field.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY'**
  String get birthdateHint;

  /// Helper text below the birthplace input field.
  ///
  /// In en, this message translates to:
  /// **'Start typing the municipality or country of birth and select it from the menu.'**
  String get birthplaceHelperText;

  /// Placeholder for the place or foreign country of birth field.
  ///
  /// In en, this message translates to:
  /// **'Municipality or foreign country'**
  String get birthplacePlaceholder;

  /// Title for the modal showing the birthplaces database download progress.
  ///
  /// In en, this message translates to:
  /// **'Updating Birthplaces Database'**
  String get birthplacesDownloadTitle;

  /// Label for the build number field in an info screen.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get buildNumber;

  /// Instructional text displayed above the camera card framing guide.
  ///
  /// In en, this message translates to:
  /// **'Align your health card or tax code within the frame'**
  String get cameraCardGuideHint;

  /// An informational message explaining how to grant camera permission.
  ///
  /// In en, this message translates to:
  /// **'To scan cards, this app needs access to your camera. Please go to your device settings and grant camera permission.'**
  String get cameraPermissionInfo;

  /// Label for a button to cancel an action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label for the button showing the optical barcode of the tax code.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get cardActionBarcode;

  /// Label for the button deleting the contact.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get cardActionDelete;

  /// Label for the button editing the contact details.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get cardActionEdit;

  /// Label for a button to close a screen or dialog.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Description of promotional banner for guest users to enable cloud backup.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google to sync and protect your tax codes.'**
  String get cloudBackupBannerSubtitle;

  /// Title of promotional banner for guest users to enable cloud backup.
  ///
  /// In en, this message translates to:
  /// **'Enable Cloud Backup'**
  String get cloudBackupBannerTitle;

  /// Tooltip indicating active cloud synchronization on the user avatar.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync active'**
  String get cloudSyncActive;

  /// Tooltip and message explaining that Google sign-in is required for cloud synchronization.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google to sync your tax codes across devices'**
  String get cloudSyncGuestTooltip;

  /// Tooltip and message when cloud synchronization is disabled.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync inactive'**
  String get cloudSyncOff;

  /// Tooltip and message when cloud synchronization is enabled.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync active'**
  String get cloudSyncOn;

  /// Label for the secondary button to access and use the app in guest mode without signing in.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// Label for the primary Google single sign-on authentication button.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Label for the quick copy to clipboard button.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyAction;

  /// Tooltip for the button or box to copy the tax code to clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy tax code'**
  String get copyTaxCode;

  /// Title of the main dashboard screen listing saved tax codes.
  ///
  /// In en, this message translates to:
  /// **'My Codes'**
  String get dashboardTitle;

  /// Error message when a backend or API request times out.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get deadlineExceeded;

  /// Label for a delete button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Label for a button to delete the user's account.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Subtitle for account deletion action according to GDPR compliance.
  ///
  /// In en, this message translates to:
  /// **'Permanent deletion and right to be forgotten (GDPR)'**
  String get deleteAccountGdprSubtitle;

  /// A confirmation message shown to the user before deleting their account.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? All your data will be permanently lost. This action is irreversible.'**
  String get deleteAccountMessage;

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

  /// Developer attribution in app information.
  ///
  /// In en, this message translates to:
  /// **'Developed by Tommaso Scalici'**
  String get developedBy;

  /// Body text explaining independent third-party status.
  ///
  /// In en, this message translates to:
  /// **'This app is not affiliated with, endorsed by, or representative of any government agency. It is an independent third-party tool to calculate and store the Italian Tax Code using the public algorithm.'**
  String get disclaimerBody;

  /// Title for official disclaimer card in legal information.
  ///
  /// In en, this message translates to:
  /// **'Official Disclaimer'**
  String get disclaimerTitle;

  /// Label for an edit button.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// App bar title in the edit tax code screen.
  ///
  /// In en, this message translates to:
  /// **'Edit Tax Code'**
  String get editTaxCodeTitle;

  /// Button label to add or create a new tax code.
  ///
  /// In en, this message translates to:
  /// **'Add Code'**
  String get addCode;

  /// Description shown in the empty dashboard when no cards are saved yet.
  ///
  /// In en, this message translates to:
  /// **'Add your first Italian Tax Code to keep it handy anytime, even offline.'**
  String get emptyDashboardDescription;

  /// Title shown in the empty dashboard when no cards are saved yet.
  ///
  /// In en, this message translates to:
  /// **'No cards saved yet'**
  String get emptyDashboardTitle;

  /// Action button label to reset the search filter in the empty search state.
  ///
  /// In en, this message translates to:
  /// **'Reset search'**
  String get emptySearchClearAction;

  /// Explanation shown when a search filter yields no results.
  ///
  /// In en, this message translates to:
  /// **'No card matches \'{query}\'. Try searching with a different name or tax code.'**
  String emptySearchDescription(String query);

  /// Title shown when a search filter yields no results.
  ///
  /// In en, this message translates to:
  /// **'No codes found'**
  String get emptySearchTitle;

  /// A generic title for an error dialog.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Subtitle for the export saved codes item.
  ///
  /// In en, this message translates to:
  /// **'Offline backup in JSON or CSV format'**
  String get exportDataSubtitle;

  /// Title for the export saved codes item.
  ///
  /// In en, this message translates to:
  /// **'Export codes'**
  String get exportDataTitle;

  /// Informational message for upcoming features.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon'**
  String get featureComingSoon;

  /// Label for the first name input field.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// Example placeholder text for the First Name input field.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mario'**
  String get firstNamePlaceholder;

  /// Divider text separating smart OCR scan hero and manual form input fields.
  ///
  /// In en, this message translates to:
  /// **'Or enter manually'**
  String get formOrManualEntry;

  /// Label for the gender input field.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Gender selection option for female.
  ///
  /// In en, this message translates to:
  /// **'Female (F)'**
  String get genderFemale;

  /// Gender selection option for male.
  ///
  /// In en, this message translates to:
  /// **'Male (M)'**
  String get genderMale;

  /// A user-friendly message for a generic error, asking them to retry.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// Badge for user authenticated with Google account.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get googleBadge;

  /// Badge for user in guest mode.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestBadge;

  /// A generic title for an informational dialog or screen.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// Error message shown when a form field contains disallowed characters (like numbers or symbols).
  ///
  /// In en, this message translates to:
  /// **'The field contains invalid characters.'**
  String get invalidCharacters;

  /// Label for the last name input field.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// Example placeholder text for the Last Name input field.
  ///
  /// In en, this message translates to:
  /// **'e.g. Smith'**
  String get lastNamePlaceholder;

  /// Error message when there is no internet connectivity.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network and try again.'**
  String get networkError;

  /// App bar title in the new tax code creation screen.
  ///
  /// In en, this message translates to:
  /// **'New Tax Code'**
  String get newTaxCodeTitle;

  /// Tooltip for the dashboard floating action button.
  ///
  /// In en, this message translates to:
  /// **'Create or scan a new tax code'**
  String get newTaxCodeTooltip;

  /// Label del pulsante pill nella card hero per avviare la scansione della tessera con fotocamera.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get ocrHeroButton;

  /// Descrizione della card hero che spiega la compilazione automatica tramite scansione AI.
  ///
  /// In en, this message translates to:
  /// **'Frame Health Card or ID card to automatically fill all fields via AI.'**
  String get ocrHeroSubtitle;

  /// Titolo della card hero nel form per la scansione smart con fotocamera.
  ///
  /// In en, this message translates to:
  /// **'Smart Camera Scan'**
  String get ocrHeroTitle;

  /// Label for a button that navigates the user to the app's settings page.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Label for the package name field in an info screen.
  ///
  /// In en, this message translates to:
  /// **'Package Name'**
  String get packageName;

  /// Title for data ownership highlight.
  ///
  /// In en, this message translates to:
  /// **'Data Ownership'**
  String get privacyDataOwnership;

  /// Description for data ownership highlight.
  ///
  /// In en, this message translates to:
  /// **'Your codes remain your exclusive property, stored on your device or in your private encrypted cloud.'**
  String get privacyDataOwnershipDesc;

  /// Title for GDPR user rights highlight.
  ///
  /// In en, this message translates to:
  /// **'Right to be Forgotten (GDPR)'**
  String get privacyGdprRights;

  /// Description for GDPR user rights highlight.
  ///
  /// In en, this message translates to:
  /// **'You can export or permanently delete your account and all data at any time.'**
  String get privacyGdprRightsDesc;

  /// Title for privacy highlights section.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data Protection'**
  String get privacyHighlightsTitle;

  /// Title for zero tracking highlight.
  ///
  /// In en, this message translates to:
  /// **'Zero Tracking'**
  String get privacyNoTracking;

  /// Description for zero tracking highlight.
  ///
  /// In en, this message translates to:
  /// **'No personal data is sold or used for commercial profiling or advertising.'**
  String get privacyNoTrackingDesc;

  /// Title for smart OCR document scanning highlight.
  ///
  /// In en, this message translates to:
  /// **'Document Scanning'**
  String get privacySmartOcr;

  /// Description for smart OCR document scanning highlight.
  ///
  /// In en, this message translates to:
  /// **'Document AI OCR operates with strict privacy standards and encryption.'**
  String get privacySmartOcrDesc;

  /// Title for the user profile screen.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profilePageTitle;

  /// Subtitle for rating app in store item.
  ///
  /// In en, this message translates to:
  /// **'Support app development'**
  String get rateAppSubtitle;

  /// Title for rating app in store item.
  ///
  /// In en, this message translates to:
  /// **'Rate on the Play Store'**
  String get rateAppTitle;

  /// Error message when the user has exceeded their daily limit of tax code calculations.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached. Please try again tomorrow.'**
  String get rateLimitExceeded;

  /// Label for button opening full online privacy policy on website.
  ///
  /// In en, this message translates to:
  /// **'Read Full Privacy Policy Online'**
  String get readFullPrivacyPolicy;

  /// A validation error message for a required form field.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get required;

  /// Primary button to save the calculated tax code in the form.
  ///
  /// In en, this message translates to:
  /// **'Save Code'**
  String get saveCode;

  /// Badge label showing the number of saved tax code cards.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No saved cards} =1{1 saved card} other{{count} saved cards}}'**
  String savedCardsCount(int count);

  /// Error message shown when the scan fails to extract data from a document photo. It prompts the user to retry with a better picture.
  ///
  /// In en, this message translates to:
  /// **'Could not read data from the picture. Please try taking a new, more focused one.'**
  String get scanFailedErrorMessage;

  /// Placeholder text inside a search bar.
  ///
  /// In en, this message translates to:
  /// **'Search by name or tax code...'**
  String get search;

  /// Tooltip for the clear button inside the dashboard search bar.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get searchClearTooltip;

  /// Message displayed when a search yields no results.
  ///
  /// In en, this message translates to:
  /// **'No results found for \'{searchText}\''**
  String searchNoResults(String searchText);

  /// Header for account management section in profile bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Account Management'**
  String get sectionAccountManagement;

  /// Header for data and utilities section in profile bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Data & Utilities'**
  String get sectionDataAndUtilities;

  /// Header for legal information section in profile bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Legal Information'**
  String get sectionLegalAndAppInfo;

  /// Error message when the backend service is down or returning an error.
  ///
  /// In en, this message translates to:
  /// **'The service is temporarily unavailable. Please try again later.'**
  String get serviceUnavailable;

  /// Error message when the user's authentication token is invalid or expired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get sessionExpired;

  /// Label for a share button.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Label for a button to display the terms and conditions.
  ///
  /// In en, this message translates to:
  /// **'View Terms & Conditions'**
  String get showTerms;

  /// Error message displayed when an authentication attempt encounters an error.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get signInFailed;

  /// Error message displayed when Google re-authentication fails or is cancelled during sensitive operations like account deletion.
  ///
  /// In en, this message translates to:
  /// **'Re-authentication failed. Please try again.'**
  String get reauthFailed;

  /// Label for a button to sign out of the application.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Subtitle for sign out action.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Google profile from this device'**
  String get signOutSubtitle;

  /// Initial step indicating the service is checking whether birthplace data needs to be downloaded.
  ///
  /// In en, this message translates to:
  /// **'Checking birthplaces database...'**
  String get stepBirthplacesChecking;

  /// Progress step indicating birthplace data is being downloaded from storage.
  ///
  /// In en, this message translates to:
  /// **'Downloading birthplaces data...'**
  String get stepBirthplacesDownloading;

  /// Progress step indicating birthplace data is being generated on the server for the first time.
  ///
  /// In en, this message translates to:
  /// **'Generating birthplaces data. This might take a minute...'**
  String get stepBirthplacesGenerating;

  /// Progress step indicating birthplace data is being parsed from the local JSON file.
  ///
  /// In en, this message translates to:
  /// **'Reading database...'**
  String get stepBirthplacesParsing;

  /// Tooltip for the theme mode toggle button.
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get switchTheme;

  /// Count of saved tax codes for sync status pill.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 saved code} other{{count} saved codes}}'**
  String syncSavedCodesCount(int count);

  /// Title for the camera screen.
  ///
  /// In en, this message translates to:
  /// **'Scan Card'**
  String get takePicture;

  /// Snackbar confirmation shown when the tax code is copied to clipboard.
  ///
  /// In en, this message translates to:
  /// **'Tax code copied to clipboard'**
  String get taxCodeCopied;

  /// Hint shown when the preview tax code is not yet complete.
  ///
  /// In en, this message translates to:
  /// **'Fill in all fields for automatic calculation'**
  String get taxCodeLivePreviewHint;

  /// Title of the live tax code preview card in the form.
  ///
  /// In en, this message translates to:
  /// **'Live Calculated Tax Code'**
  String get taxCodeLivePreviewTitle;

  /// A notice about agreeing to terms and conditions.
  ///
  /// In en, this message translates to:
  /// **'By proceeding, you agree to our Terms and Conditions.'**
  String get termsAndCondition;

  /// Tooltip for the button to confirm the captured picture and proceed.
  ///
  /// In en, this message translates to:
  /// **'Confirm picture'**
  String get tooltipConfirmPicture;

  /// Tooltip for the delete button on a contact card.
  ///
  /// In en, this message translates to:
  /// **'Delete Contact'**
  String get tooltipDelete;

  /// Tooltip for the edit button on a contact card.
  ///
  /// In en, this message translates to:
  /// **'Edit Contact'**
  String get tooltipEdit;

  /// Tooltip for the button to discard the current picture and take a new one.
  ///
  /// In en, this message translates to:
  /// **'Retake picture'**
  String get tooltipRetakePicture;

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

  /// Tooltip for the button to capture a picture.
  ///
  /// In en, this message translates to:
  /// **'Take picture'**
  String get tooltipTakePicture;

  /// Tooltip for the button that toggles the camera flash on and off.
  ///
  /// In en, this message translates to:
  /// **'Toggle flash'**
  String get tooltipToggleFlash;

  /// Subtitle displayed on the welcome and authentication screen explaining core app utility.
  ///
  /// In en, this message translates to:
  /// **'Save, access, and show your codes at pharmacies or offices in an instant.'**
  String get welcomeSubtitle;

  /// Main headline displayed on the welcome and authentication screen.
  ///
  /// In en, this message translates to:
  /// **'Your Tax Codes, always with you'**
  String get welcomeTitle;
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
    'that was used.',
  );
}
