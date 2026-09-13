// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get accountAndSettings => 'Account & Settings';

  @override
  String appInfoSubtitle(String version) {
    return 'Version $version • Legal notes and Privacy Policy';
  }

  @override
  String get appInfoTitle => 'App Information';

  @override
  String get appName => 'Tax Code';

  @override
  String get appTitle => 'Tax Code';

  @override
  String get barcodeCode128 => 'Barcode (Code 128)';

  @override
  String get barcodeMaxBrightnessActive =>
      'Maximum brightness active for optical scanning';

  @override
  String get barcodeNotice => 'Show at pharmacy or healthcare desk';

  @override
  String get barcodeOrDivider => 'or';

  @override
  String get barcodeQrCode => 'Health QR Code';

  @override
  String get birthDate => 'Date of Birth';

  @override
  String get birthPlace => 'Place of Birth';

  @override
  String get birthdateHint => 'DD/MM/YYYY';

  @override
  String get birthplaceHelperText =>
      'Type the municipality name for quick cadastral code lookup (e.g. H501).';

  @override
  String get birthplacePlaceholder => 'Municipality or foreign country';

  @override
  String get birthplacesDownloadTitle => 'Updating Birthplaces Database';

  @override
  String get buildNumber => 'Build Number';

  @override
  String get cameraPermissionInfo =>
      'To scan cards, this app needs access to your camera. Please go to your device settings and grant camera permission.';

  @override
  String get cancel => 'Cancel';

  @override
  String get cardActionBarcode => 'Barcode';

  @override
  String get cardActionDelete => 'Delete';

  @override
  String get cardActionEdit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get cloudBackupBannerSubtitle =>
      'Sign in with Google to sync and protect your tax codes.';

  @override
  String get cloudBackupBannerTitle => 'Enable Cloud Backup';

  @override
  String get cloudSyncActive => 'Cloud sync active';

  @override
  String get cloudSyncGuestTooltip =>
      'Sign in with Google to sync your tax codes across devices';

  @override
  String get cloudSyncOff => 'Cloud sync inactive';

  @override
  String get cloudSyncOn => 'Cloud sync active';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get copyAction => 'Copy';

  @override
  String get copyTaxCode => 'Copy tax code';

  @override
  String get dashboardTitle => 'My Codes';

  @override
  String get deadlineExceeded => 'Request timed out. Please try again.';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountGdprSubtitle =>
      'Permanent deletion and right to be forgotten (GDPR)';

  @override
  String get deleteAccountMessage =>
      'Are you sure you want to delete your account? All your data will be permanently lost. This action is irreversible.';

  @override
  String get deleteConfirmation => 'Confirm Deletion';

  @override
  String deleteMessage(String taxCode) {
    return 'Are you sure you want to permanently delete the contact for \'$taxCode\'?';
  }

  @override
  String get developedBy => 'Developed by Tommaso Scalici';

  @override
  String get disclaimerBody =>
      'This app is not affiliated with, endorsed by, or representative of any government agency. It is an independent third-party tool to calculate and store the Italian Tax Code using the public algorithm.';

  @override
  String get disclaimerTitle => 'Official Disclaimer';

  @override
  String get edit => 'Edit';

  @override
  String get editTaxCodeTitle => 'Edit Tax Code';

  @override
  String get emptyDashboardAction => 'Add Code';

  @override
  String get emptyDashboardDescription =>
      'Add your first Italian Tax Code to keep it handy anytime, even offline.';

  @override
  String get emptyDashboardTitle => 'No cards saved yet';

  @override
  String get emptySearchClearAction => 'Reset search';

  @override
  String emptySearchDescription(String query) {
    return 'No card matches \'$query\'. Try searching with a different name or tax code.';
  }

  @override
  String get emptySearchTitle => 'No codes found';

  @override
  String get error => 'Error';

  @override
  String get exportDataSubtitle => 'Offline backup in JSON or CSV format';

  @override
  String get exportDataTitle => 'Export codes';

  @override
  String get featureComingSoon => 'Feature coming soon';

  @override
  String get firstName => 'First Name';

  @override
  String get firstNamePlaceholder => 'e.g. Mario';

  @override
  String get formOrManualEntry => 'Or enter manually';

  @override
  String get gender => 'Gender';

  @override
  String get genderFemale => 'Female (F)';

  @override
  String get genderMale => 'Male (M)';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get googleBadge => 'Google';

  @override
  String get guestBadge => 'Guest';

  @override
  String get info => 'Info';

  @override
  String get invalidCharacters => 'The field contains invalid characters.';

  @override
  String get lastName => 'Last Name';

  @override
  String get lastNamePlaceholder => 'e.g. Smith';

  @override
  String get networkError =>
      'No internet connection. Please check your network and try again.';

  @override
  String get newTaxCode => 'New Code';

  @override
  String get newTaxCodeTitle => 'New Tax Code';

  @override
  String get newTaxCodeTooltip => 'Create or scan a new tax code';

  @override
  String get ocrHeroButton => 'Scan';

  @override
  String get ocrHeroSubtitle =>
      'Frame Health Card or ID card to automatically fill all fields via AI.';

  @override
  String get ocrHeroTitle => 'Smart Camera Scan';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get packageName => 'Package Name';

  @override
  String get privacyDataOwnership => 'Data Ownership';

  @override
  String get privacyDataOwnershipDesc =>
      'Your codes remain your exclusive property, stored on your device or in your private encrypted cloud.';

  @override
  String get privacyGdprRights => 'Right to be Forgotten (GDPR)';

  @override
  String get privacyGdprRightsDesc =>
      'You can export or permanently delete your account and all data at any time.';

  @override
  String get privacyHighlightsTitle => 'Privacy & Data Protection';

  @override
  String get privacyNoTracking => 'Zero Tracking';

  @override
  String get privacyNoTrackingDesc =>
      'No personal data is sold or used for commercial profiling or advertising.';

  @override
  String get privacySmartOcr => 'Document Scanning';

  @override
  String get privacySmartOcrDesc =>
      'Document AI OCR operates with strict privacy standards and encryption.';

  @override
  String get profilePageTitle => 'Profile';

  @override
  String get rateAppSubtitle => 'Support app development';

  @override
  String get rateAppTitle => 'Rate on the Play Store';

  @override
  String get rateLimitExceeded =>
      'Daily limit reached. Please try again tomorrow.';

  @override
  String get readFullPrivacyPolicy => 'Read Full Privacy Policy Online';

  @override
  String get required => 'This field is required';

  @override
  String get saveCode => 'Save Code';

  @override
  String savedCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved cards',
      one: '1 saved card',
      zero: 'No saved cards',
    );
    return '$_temp0';
  }

  @override
  String get scanFailedErrorMessage =>
      'Could not read data from the picture. Please try taking a new, more focused one.';

  @override
  String get search => 'Search by name or tax code...';

  @override
  String get searchClearTooltip => 'Clear search';

  @override
  String searchNoResults(String searchText) {
    return 'No results found for \'$searchText\'';
  }

  @override
  String get sectionAccountManagement => 'Account Management';

  @override
  String get sectionDataAndUtilities => 'Data & Utilities';

  @override
  String get sectionLegalAndAppInfo => 'Legal Information';

  @override
  String get serviceUnavailable =>
      'The service is temporarily unavailable. Please try again later.';

  @override
  String get sessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get share => 'Share';

  @override
  String get showTerms => 'View Terms & Conditions';

  @override
  String get signInFailed => 'Sign-in failed. Please try again.';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutSubtitle => 'Disconnect Google profile from this device';

  @override
  String get stepBirthplacesChecking => 'Checking birthplaces database...';

  @override
  String get stepBirthplacesDownloading => 'Downloading birthplaces data...';

  @override
  String get stepBirthplacesGenerating =>
      'Generating birthplaces data. This might take a minute...';

  @override
  String get stepBirthplacesParsing => 'Reading database...';

  @override
  String get switchTheme => 'Toggle theme';

  @override
  String syncSavedCodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved codes',
      one: '1 saved code',
    );
    return '$_temp0';
  }

  @override
  String get takePicture => 'Scan Card';

  @override
  String get taxCodeCopied => 'Tax code copied to clipboard';

  @override
  String get taxCodeLivePreviewHint =>
      'Fill in all fields for automatic calculation';

  @override
  String get taxCodeLivePreviewTitle => 'Live Calculated Tax Code';

  @override
  String get termsAndCondition =>
      'By proceeding, you agree to our Terms and Conditions.';

  @override
  String get tooltipConfirmPicture => 'Confirm picture';

  @override
  String get tooltipDelete => 'Delete Contact';

  @override
  String get tooltipEdit => 'Edit Contact';

  @override
  String get tooltipRetakePicture => 'Retake picture';

  @override
  String get tooltipShare => 'Share Tax Code';

  @override
  String get tooltipShowBarcode => 'Show Barcode';

  @override
  String get tooltipTakePicture => 'Take picture';

  @override
  String get tooltipToggleFlash => 'Toggle flash';

  @override
  String get welcomeSubtitle =>
      'Save, access, and show your codes at pharmacies or offices in an instant.';

  @override
  String get welcomeTitle => 'Your Tax Codes, always with you';
}
