// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Nome App';

  @override
  String get appTitle => 'Codice Fiscale';

  @override
  String get appVersion => 'Versione';

  @override
  String get barcodePageTitle => 'Codice a Barre';

  @override
  String get birthDate => 'Data di Nascita';

  @override
  String get birthPlace => 'Luogo di Nascita';

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
  String get close => 'Chiudi';

  @override
  String get confirm => 'Conferma';

  @override
  String get contactsListEmpty =>
      'Nessun contatto presente.\nTocca il pulsante \'+\' per aggiungere il primo!';

  @override
  String get delete => 'Elimina';

  @override
  String get deleteAccount => 'Elimina Account';

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
  String get edit => 'Modifica';

  @override
  String get error => 'Errore';

  @override
  String get firstName => 'Nome';

  @override
  String get formPageTitle => 'Dettagli Contatto';

  @override
  String get gender => 'Sesso';

  @override
  String get genericError => 'Qualcosa è andato storto. Riprova.';

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
  String get networkError =>
      'Nessuna connessione internet. Controlla la tua rete e riprova.';

  @override
  String get newItem => 'Aggiungi Contatto';

  @override
  String get openSettings => 'Apri Impostazioni';

  @override
  String get packageName => 'Nome Pacchetto';

  @override
  String get pleaseSignIn => 'Benvenuto, accedi per continuare.';

  @override
  String get pleaseSignUp => 'Benvenuto, crea un account per continuare.';

  @override
  String get profilePageTitle => 'Profilo';

  @override
  String get rateLimitExceeded =>
      'Limite giornaliero raggiunto. Riprova domani.';

  @override
  String get rateThisApp => 'Valuta l\'App';

  @override
  String get required => 'Questo campo è obbligatorio';

  @override
  String get scanCard => 'Scansiona da CIE / TS';

  @override
  String get scanFailedErrorMessage =>
      'Impossibile leggere i dati dalla foto. Prova a scattarne una nuova più a fuoco.';

  @override
  String get search => 'Cerca per nome o codice fiscale...';

  @override
  String searchNoResults(String searchText) {
    return 'Nessun risultato trovato per \'$searchText\'';
  }

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
  String get signOut => 'Esci';

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
  String get takePicture => 'Scansiona Tessera';

  @override
  String get termsAndCondition =>
      'Procedendo, accetti i nostri Termini e Condizioni.';

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
}
