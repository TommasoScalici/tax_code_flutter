// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Codice Fiscale';

  @override
  String get pleaseSignIn => 'Benvenuto su Codice Fiscale, per favore accedi.';

  @override
  String get pleaseSignUp =>
      'Benvenuto su Codice Fiscale, per favore registrati.';

  @override
  String get termsAndCondition =>
      'Accedendo o registrandoti, accetti i termini e le condizioni.';

  @override
  String get showTerms => 'Mostra termini e condizioni';

  @override
  String get required => 'Obbligatorio';

  @override
  String get newItem => 'Nuovo';

  @override
  String get fillData => 'Inserisci i dati';

  @override
  String get firstName => 'Nome';

  @override
  String get lastName => 'Cognome';

  @override
  String get gender => 'Sesso';

  @override
  String get birthDate => 'Data di nascita';

  @override
  String get birthPlace => 'Luogo di nascita';

  @override
  String get confirm => 'Conferma';

  @override
  String get deleteConfirmation => 'Conferma eliminazione';

  @override
  String get delete => 'Elimina';

  @override
  String get deleteAccount => 'Elimina account';

  @override
  String get signOut => 'Esci';

  @override
  String get cancel => 'Annulla';

  @override
  String get close => 'Chiudi';

  @override
  String get info => 'Informazioni';

  @override
  String get error => 'Errore';

  @override
  String get errorLoading => 'Errore durante il caricamento dei contatti: ';

  @override
  String get search => 'Cerca...';

  @override
  String get scanCard => 'Scannerizza tessera';

  @override
  String get takePicture => 'Scatta una foto...';

  @override
  String get permissionRequired => 'Permesso richiesto';

  @override
  String get openSettings => 'Apri Impostazioni';

  @override
  String get cameraPermissionInfo =>
      'Il permesso della fotocamera è stato negato in modo permanente.\nVai nelle impostazioni dell\'app, apri la sezione Autorizzazioni e abilita il permesso della fotocamera.';

  @override
  String get appName => 'Nome app';

  @override
  String get packageName => 'Nome pacchetto';

  @override
  String get appVersion => 'Versione';

  @override
  String get buildNumber => 'Numero build';

  @override
  String get buildSignature => 'Firma build';

  @override
  String get installerStore => 'Provenienza';

  @override
  String get errorConnection => 'Errore di connessione';

  @override
  String get errorUnexpected => 'Errore imprevisto';

  @override
  String get errorOccurred => 'Si è verificato un errore, riprova più tardi.';

  @override
  String get errorNoInternet =>
      'Controlla la tua connessione internet e riprova.';

  @override
  String get noContactsFound => 'Nessun contatto trovato.';

  @override
  String get deleteAccountMessage =>
      'Sei sicuro? Tutti i tuoi dati verranno cancellati in modo permanente.';

  @override
  String deleteMessage(String taxCode) {
    return 'Sei sicuro di voler eliminare il contatto con codice fiscale: \'$taxCode\'?';
  }
}
