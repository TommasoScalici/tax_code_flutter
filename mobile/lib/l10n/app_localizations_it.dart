// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get accountAndSettings => 'Account & Impostazioni';

  @override
  String appInfoSubtitle(String version) {
    return 'Versione $version • Note legali e Privacy Policy';
  }

  @override
  String get appInfoTitle => 'Informazioni sull\'app';

  @override
  String get appName => 'Codice Fiscale';

  @override
  String get appTitle => 'Codice Fiscale';

  @override
  String get appVersion => 'Versione';

  @override
  String get barcodeCode128 => 'Codice a Barre (Code 128)';

  @override
  String get barcodeMaxBrightnessActive =>
      'Luminosità massima attiva per lettura ottica';

  @override
  String get barcodeNotice => 'Mostra allo sportello farmaceutico o sanitario';

  @override
  String get barcodeOrDivider => 'oppure';

  @override
  String get barcodePageTitle => 'Codice a Barre';

  @override
  String get barcodeQrCode => 'QR Code Sanitario';

  @override
  String get birthDate => 'Data di Nascita';

  @override
  String get birthPlace => 'Luogo di Nascita';

  @override
  String get birthdateHint => 'GG/MM/AAAA';

  @override
  String get birthplaceHelperText =>
      'Digita il nome del comune per la ricerca rapida del codice catastale (es. H501).';

  @override
  String get birthplacePlaceholder => 'Comune o Stato estero';

  @override
  String get birthplacesDownloadTitle =>
      'Aggiornamento Database Luoghi di Nascita';

  @override
  String get buildNumber => 'Numero Build';

  @override
  String get buildSignature => 'Firma Build';

  @override
  String get cameraPermissionInfo =>
      'Per scansionare le tessere, l\'app necessita dell\'accesso alla fotocamera. Vai alle impostazioni del dispositivo e concedi il permesso.';

  @override
  String get cancel => 'Annulla';

  @override
  String get cardActionBarcode => 'Barcode';

  @override
  String get cardActionDelete => 'Elimina';

  @override
  String get cardActionEdit => 'Modifica';

  @override
  String get close => 'Chiudi';

  @override
  String get cloudBackupBannerSubtitle =>
      'Accedi con Google per sincronizzare e proteggere i tuoi codici fiscali.';

  @override
  String get cloudBackupBannerTitle => 'Attiva il Backup Cloud';

  @override
  String get cloudSyncActive => 'Sincronizzazione attiva';

  @override
  String get cloudSyncGuestTooltip =>
      'Accedi con Google per sincronizzare i tuoi codici tra dispositivi';

  @override
  String get cloudSyncOff => 'Sincronizzazione cloud non attiva';

  @override
  String get cloudSyncOn => 'Sincronizzazione cloud attiva';

  @override
  String get confirm => 'Conferma';

  @override
  String get contactsListEmpty =>
      'Nessun contatto presente.\nTocca il pulsante \'+\' per aggiungere il primo!';

  @override
  String get continueAsGuest => 'Continua come ospite';

  @override
  String get continueWithGoogle => 'Continua con Google';

  @override
  String get copyAction => 'Copia';

  @override
  String get copyTaxCode => 'Copia codice fiscale';

  @override
  String get dashboardTitle => 'I Miei Codici';

  @override
  String get deadlineExceeded => 'Richiesta scaduta. Riprova.';

  @override
  String get delete => 'Elimina';

  @override
  String get deleteAccount => 'Elimina Account';

  @override
  String get deleteAccountGdprSubtitle =>
      'Cancellazione definitiva e diritto all\'oblio (GDPR)';

  @override
  String get deleteAccountMessage =>
      'Sei sicuro di voler eliminare il tuo account? Tutti i tuoi dati verranno persi permanentemente. Questa azione è irreversibile.';

  @override
  String get deleteConfirmation => 'Conferma Eliminazione';

  @override
  String deleteMessage(String taxCode) {
    return 'Sei sicuro di voler eliminare permanentemente il contatto per \'$taxCode\'?';
  }

  @override
  String get developedBy => 'Sviluppata da Tommaso Scalici';

  @override
  String get disclaimerBody =>
      'Questa applicazione non rappresenta né è affiliata ad alcuna agenzia governativa. È uno strumento di terze parti per calcolare e memorizzare il Codice Fiscale tramite l\'algoritmo pubblico.';

  @override
  String get disclaimerTitle => 'Disclaimer Istituzionale';

  @override
  String get edit => 'Modifica';

  @override
  String get editTaxCodeTitle => 'Modifica Codice Fiscale';

  @override
  String get emptyDashboardAction => 'Aggiungi Codice';

  @override
  String get emptyDashboardDescription =>
      'Aggiungi il tuo primo Codice Fiscale per averlo sempre a portata di mano anche offline.';

  @override
  String get emptyDashboardTitle => 'Nessuna tessera salvata';

  @override
  String get emptySearchClearAction => 'Reimposta ricerca';

  @override
  String emptySearchDescription(String query) {
    return 'Nessuna tessera corrisponde a \'$query\'. Prova a cercare con un altro nome o codice fiscale.';
  }

  @override
  String get emptySearchTitle => 'Nessun codice trovato';

  @override
  String get error => 'Errore';

  @override
  String get exportDataSubtitle => 'Backup offline in formato JSON o CSV';

  @override
  String get exportDataTitle => 'Esporta codici';

  @override
  String get featureComingSoon => 'Funzionalità in arrivo';

  @override
  String get firstName => 'Nome';

  @override
  String get firstNamePlaceholder => 'es. Mario';

  @override
  String get formOrManualEntry => 'Oppure inserisci manualmente';

  @override
  String get formPageTitle => 'Dettagli Contatto';

  @override
  String get gender => 'Sesso';

  @override
  String get genderFemale => 'Femminile (F)';

  @override
  String get genderMale => 'Maschile (M)';

  @override
  String get genericError => 'Qualcosa è andato storto. Riprova.';

  @override
  String get googleBadge => 'Google';

  @override
  String get guestBadge => 'Ospite';

  @override
  String get guestMode => 'Ospite';

  @override
  String get homePageTitle => 'I Miei Contatti';

  @override
  String get info => 'Informazioni';

  @override
  String get installerStore => 'Store di Installazione';

  @override
  String get invalidCharacters => 'Il campo contiene caratteri non ammessi.';

  @override
  String get lastName => 'Cognome';

  @override
  String get lastNamePlaceholder => 'es. Rossi';

  @override
  String get networkError =>
      'Nessuna connessione internet. Controlla la tua rete e riprova.';

  @override
  String get newItem => 'Aggiungi Contatto';

  @override
  String get newTaxCode => 'Nuovo Codice';

  @override
  String get newTaxCodeTitle => 'Nuovo Codice Fiscale';

  @override
  String get newTaxCodeTooltip => 'Crea o scansiona un nuovo Codice Fiscale';

  @override
  String get ocrHeroButton => 'Scansiona';

  @override
  String get ocrHeroSubtitle =>
      'Inquadra Tessera Sanitaria o CIE per compilare tutti i campi in automatico tramite AI.';

  @override
  String get ocrHeroTitle => 'Scansione Smart con Fotocamera';

  @override
  String get openSettings => 'Apri Impostazioni';

  @override
  String get packageName => 'Nome Pacchetto';

  @override
  String get pleaseSignIn => 'Benvenuto, accedi per continuare.';

  @override
  String get pleaseSignUp => 'Benvenuto, crea un account per continuare.';

  @override
  String get privacyDataOwnership => 'Dati e Proprietà';

  @override
  String get privacyDataOwnershipDesc =>
      'I tuoi codici rimangono di tua proprietà, salvati sul dispositivo o nel tuo cloud cifrato.';

  @override
  String get privacyGdprRights => 'Diritto all\'Oblio (GDPR)';

  @override
  String get privacyGdprRightsDesc =>
      'Puoi esportare o eliminare definitivamente il tuo account e i dati in qualsiasi momento.';

  @override
  String get privacyHighlightsTitle => 'Privacy & Protezione Dati';

  @override
  String get privacyNoTracking => 'Zero Tracciamento';

  @override
  String get privacyNoTrackingDesc =>
      'Nessun dato personale viene venduto o utilizzato per profilazione commerciale.';

  @override
  String get privacySmartOcr => 'Scansione Documenti';

  @override
  String get privacySmartOcrDesc =>
      'L\'OCR AI per la lettura delle tessere opera con standard elevati di sicurezza.';

  @override
  String get profilePageTitle => 'Profilo';

  @override
  String get rateAppSubtitle => 'Supporta lo sviluppo dell\'app';

  @override
  String get rateAppTitle => 'Valuta sul Play Store';

  @override
  String get rateLimitExceeded =>
      'Limite giornaliero raggiunto. Riprova domani.';

  @override
  String get rateThisApp => 'Valuta l\'App';

  @override
  String get readFullPrivacyPolicy => 'Leggi l\'Informativa Completa Online';

  @override
  String get required => 'Questo campo è obbligatorio';

  @override
  String get saveCode => 'Salva Codice';

  @override
  String savedCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tessere salvate',
      one: '1 tessera salvata',
      zero: 'Nessuna tessera salvata',
    );
    return '$_temp0';
  }

  @override
  String get scanCard => 'Scansiona da CIE / TS';

  @override
  String get scanFailedErrorMessage =>
      'Impossibile leggere i dati dalla foto. Prova a scattarne una nuova più a fuoco.';

  @override
  String get search => 'Cerca per nome o codice fiscale...';

  @override
  String get searchClearTooltip => 'Cancella ricerca';

  @override
  String searchNoResults(String searchText) {
    return 'Nessun risultato trovato per \'$searchText\'';
  }

  @override
  String get sectionAccountManagement => 'Gestione Account';

  @override
  String get sectionDataAndUtilities => 'Dati e Funzioni';

  @override
  String get sectionLegalAndAppInfo => 'Informazioni Legali';

  @override
  String get serviceUnavailable =>
      'Il servizio è temporaneamente non disponibile. Riprova più tardi.';

  @override
  String get sessionExpired =>
      'La tua sessione è scaduta. Effettua nuovamente l\'accesso.';

  @override
  String get share => 'Condividi';

  @override
  String get showTerms => 'Visualizza Termini e Condizioni';

  @override
  String get signInFailed => 'Accesso non riuscito. Riprova.';

  @override
  String get signOut => 'Esci';

  @override
  String get signOutSubtitle =>
      'Scollega il profilo Google da questo dispositivo';

  @override
  String get stepBirthplacesChecking =>
      'Controllo del database dei luoghi di nascita...';

  @override
  String get stepBirthplacesDownloading =>
      'Download dei luoghi di nascita in corso...';

  @override
  String get stepBirthplacesGenerating =>
      'Generazione dei luoghi di nascita in corso. Potrebbe volerci qualche minuto...';

  @override
  String get stepBirthplacesParsing => 'Lettura del database in corso...';

  @override
  String get switchTheme => 'Cambia tema';

  @override
  String syncSavedCodesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count codici salvati',
      one: '1 codice salvato',
    );
    return '$_temp0';
  }

  @override
  String get takePicture => 'Scansiona Tessera';

  @override
  String get taxCodeCopied => 'Codice Fiscale copiato negli appunti';

  @override
  String get taxCodeLivePreviewHint =>
      'Compila tutti i campi per il calcolo automatico';

  @override
  String get taxCodeLivePreviewTitle => 'Codice Calcolato in Anteprima';

  @override
  String get termsAndCondition =>
      'Procedendo, accetti i nostri Termini e Condizioni.';

  @override
  String get termsAndPrivacyTitle => 'Termini e Privacy';

  @override
  String get tooltipConfirmPicture => 'Conferma foto';

  @override
  String get tooltipDelete => 'Elimina Contatto';

  @override
  String get tooltipEdit => 'Modifica Contatto';

  @override
  String get tooltipRetakePicture => 'Scatta di nuovo';

  @override
  String get tooltipShare => 'Condividi Codice Fiscale';

  @override
  String get tooltipShowBarcode => 'Mostra Codice a Barre';

  @override
  String get tooltipTakePicture => 'Scatta foto';

  @override
  String get tooltipToggleFlash => 'Attiva/Disattiva flash';

  @override
  String get welcomeSubtitle =>
      'Salva, consulta e mostra i tuoi codici in farmacia o negli uffici in un istante.';

  @override
  String get welcomeTitle => 'I tuoi Codici Fiscali, sempre con te';
}
