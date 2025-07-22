import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:reactive_date_time_picker/reactive_date_time_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_raw_autocomplete/reactive_raw_autocomplete.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/models/tax_code_response.dart';
import 'package:shared/providers/app_state.dart';
import 'package:tax_code_flutter/i18n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import 'camera_page.dart';
import '../settings.dart';

final class FormPage extends StatefulWidget {
  final Contact? contact;
  const FormPage({super.key, required this.contact});

  @override
  State<StatefulWidget> createState() => _FormPageState();
}

final class _FormPageState extends State<FormPage> {
  final _logger = Logger();

  final _form = FormGroup({
    'firstName': FormControl<String>(validators: [Validators.required]),
    'lastName': FormControl<String>(validators: [Validators.required]),
    'gender': FormControl<String>(validators: [Validators.required]),
    'birthDate': FormControl<DateTime>(validators: [Validators.required]),
    'birthPlace': FormControl<Birthplace>(validators: [Validators.required]),
  });

  var _shouldPushForm = false;

  late List<Birthplace> _birthplaces;
  late int _contactsLength;

  String get _firstName => _form.control('firstName').value;
  String get _lastName => _form.control('lastName').value;
  String get _gender => _form.control('gender').value;
  DateTime get _birthDate => _form.control('birthDate').value;
  Birthplace get _birthPlace => _form.control('birthPlace').value;

  @override
  void initState() {
    super.initState();
    _contactsLength = context.read<AppState>().contacts.length;
    _loadBirthplacesData();
    _setPreviousData();
  }

  Future<TaxCodeResponse?> _fetchTaxCode() async {
    var accessToken = await _getAccessToken();
    var baseUri = 'http://api.miocodicefiscale.com/calculate?';
    var params =
        'lname=${_lastName.trim()}&fname=${_firstName.trim()}&gender=$_gender'
        '&city=${_birthPlace.name}&state=${_birthPlace.state}'
        '&day=${_birthDate.day}&month=${_birthDate.month}&year=${_birthDate.year}'
        '&access_token=$accessToken';

    try {
      final response = await http
          .get(Uri.parse('$baseUri$params'))
          .timeout(const Duration(seconds: 10));
      final decodedResponse =
          TaxCodeResponse.fromJson(jsonDecode(response.body));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decodedResponse;
      } else {
        throw http.ClientException(
          'Server returned status ${response.statusCode}',
          response.request?.url,
        );
      }
    } on SocketException catch (error, stacktrace) {
      FirebaseCrashlytics.instance.recordError(error, stacktrace,
          reason: 'Tax code fetch failed due to a network error');

      if (mounted) {
        _showErrorDialog(
          context,
          AppLocalizations.of(context)!.errorConnection,
          AppLocalizations.of(context)!.errorNoInternet,
        );
      }

      return null;
    } catch (error, stacktrace) {
      FirebaseCrashlytics.instance.recordError(error, stacktrace,
          reason: 'An unexpected error occurred during tax code fetch');

      if (mounted) {
        _showErrorDialog(
          context,
          AppLocalizations.of(context)!.errorUnexpected,
          AppLocalizations.of(context)!.errorOccurred,
        );
      }

      return null;
    }
  }

  Future<String> _getAccessToken() async {
    if (Platform.isAndroid) {
      try {
        final remoteConfig = FirebaseRemoteConfig.instance;
        return remoteConfig.getString(Settings.mioCodiceFiscaleApiKey);
      } on Exception catch (e) {
        if (mounted) {
          _logger
              .e('Error while retrieving access token from remote config: $e');
        }
      }
    }
    return '';
  }

  Future<String> _loadAsset() async =>
      await rootBundle.loadString('assets/json/cities.json');

  Future<void> _loadBirthplacesData() async {
    String jsonString = await _loadAsset();
    final birthplaces = jsonDecode(jsonString)
        .map<Birthplace>((json) => Birthplace.fromJson(json))
        .toList();

    setState(() => _birthplaces = birthplaces);
  }

  void _openCameraPage(BuildContext context) async {
    final contact = await Navigator.push<Contact?>(
      context,
      MaterialPageRoute(builder: (context) => const CameraPage()),
    );

    _setFromOCR(contact);
  }

  Future<Contact?> _onSubmit() async {
    var response = await _fetchTaxCode();

    if (response == null) {
      return null;
    }

    final oldContact = widget.contact;

    return response.status
        ? Contact(
            id: oldContact?.id ?? Uuid().v4(),
            firstName: _firstName.trim(),
            lastName: _lastName.trim(),
            gender: _gender,
            taxCode: response.data.cf,
            birthPlace: _birthPlace,
            birthDate: _birthDate,
            listIndex: oldContact?.listIndex ?? _contactsLength + 1,
          )
        : null;
  }

  void _setFromOCR(Contact? contact) {
    if (contact != null) {
      _form.control('firstName').value = contact.firstName;
      _form.control('lastName').value = contact.lastName;
      _form.control('gender').value = contact.gender;
      _form.control('birthDate').value = contact.birthDate;
      _form.control('birthPlace').value = contact.birthPlace;
    }
  }

  void _setPreviousData() {
    final oldContact = widget.contact;

    if (oldContact != null) {
      _form.control('firstName').value = widget.contact?.firstName;
      _form.control('lastName').value = widget.contact?.lastName;
      _form.control('gender').value = widget.contact?.gender;
      _form.control('birthDate').value = widget.contact?.birthDate;
      _form.control('birthPlace').value = widget.contact?.birthPlace;
    }
  }

  void _showErrorDialog(
      BuildContext context, String errorMessage, String internalErrorMessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.error),
            content: Column(
              children: [Text(errorMessage), Text(internalErrorMessage)],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.close))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.fillData),
      ),
      body: Padding(
        padding: EdgeInsets.only(
            bottom:
                _shouldPushForm ? MediaQuery.of(context).viewInsets.bottom : 0),
        child: SingleChildScrollView(
          child: ReactiveForm(
            formGroup: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    child: FilledButton.tonalIcon(
                        onPressed: () => _openCameraPage(context),
                        icon: Icon(Symbols.id_card),
                        label: Text(AppLocalizations.of(context)!.scanCard)),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: ReactiveTextField(
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.firstName),
                    formControlName: 'firstName',
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                    textInputAction: TextInputAction.next,
                    validationMessages: {
                      ValidationMessage.required: (error) =>
                          AppLocalizations.of(context)!.required,
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: ReactiveTextField(
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.lastName),
                    formControlName: 'lastName',
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                    textInputAction: TextInputAction.next,
                    validationMessages: {
                      ValidationMessage.required: (error) =>
                          AppLocalizations.of(context)!.required,
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: ReactiveDropdownField<String>(
                          formControlName: 'gender',
                          decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.gender),
                          items: const [
                            DropdownMenuItem(value: 'M', child: Text('M')),
                            DropdownMenuItem(value: 'F', child: Text('F')),
                          ],
                          validationMessages: {
                            ValidationMessage.required: (error) =>
                                AppLocalizations.of(context)!.required,
                          },
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 40,
                          ),
                          child: ReactiveDateTimePicker(
                            formControlName: 'birthDate',
                            dateFormat: DateFormat.yMMMMd(
                              Localizations.localeOf(context).toString(),
                            ),
                            locale: Localizations.localeOf(context),
                            decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.birthDate,
                            ),
                            helpText: AppLocalizations.of(context)!.birthDate,
                            showClearIcon: true,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            type: ReactiveDatePickerFieldType.date,
                            validationMessages: {
                              ValidationMessage.required: (error) =>
                                  AppLocalizations.of(context)!.required,
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: ReactiveRawAutocomplete<Birthplace, Birthplace>(
                    formControlName: 'birthPlace',
                    validationMessages: {
                      ValidationMessage.required: (error) =>
                          AppLocalizations.of(context)!.required,
                    },
                    fieldViewBuilder: (BuildContext context,
                            TextEditingController controller,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted) =>
                        TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        errorText: (_form.control('birthPlace').touched &&
                                    _form.control('birthPlace').invalid &&
                                    _form.control('birthPlace').dirty) ||
                                _form.control('birthPlace').hasErrors &&
                                    _form.control('birthPlace').touched
                            ? AppLocalizations.of(context)!.required
                            : null,
                        labelText: AppLocalizations.of(context)!.birthPlace,
                        suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _form.control('birthPlace').value = null;
                              controller.value = TextEditingValue.empty;
                              focusNode.unfocus();
                              setState(() => _shouldPushForm = false);
                            }),
                      ),
                      focusNode: focusNode,
                      onSubmitted: (value) => onFieldSubmitted(),
                      onTap: () => setState(() => _shouldPushForm = true),
                      onTapOutside: (event) {
                        FocusScope.of(context).unfocus();
                        setState(() => _shouldPushForm = false);
                      },
                    ),
                    optionsBuilder: (TextEditingValue textEditingValue) =>
                        textEditingValue.text.isEmpty
                            ? _birthplaces
                            : _birthplaces
                                .where((birthplace) => birthplace.name
                                    .toLowerCase()
                                    .startsWith(
                                        textEditingValue.text.toLowerCase()))
                                .toList(),
                    optionsViewBuilder: (BuildContext context,
                            void Function(Birthplace) onSelected,
                            Iterable<Birthplace> options) =>
                        Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        child: SizedBox(
                          height: min(options.length, 5) * 60,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: min(options.length, 5),
                            itemBuilder: (context, index) {
                              final birthplace = options.elementAt(index);
                              return ListTile(
                                title: Text(
                                    '${birthplace.name} (${birthplace.state})'),
                                onTap: () {
                                  onSelected(birthplace);
                                  FocusScope.of(context).unfocus();
                                  setState(() => _shouldPushForm = false);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    child: FilledButton(
                      child: Text(AppLocalizations.of(context)!.confirm),
                      onPressed: () async {
                        _form.markAllAsTouched();
                        if (_form.valid) {
                          final contact = await _onSubmit();
                          if (context.mounted && contact != null) {
                            Navigator.pop<Contact>(context, contact);
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
