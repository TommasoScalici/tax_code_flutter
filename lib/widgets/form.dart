import 'dart:convert';
import 'dart:math';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:reactive_date_time_picker/reactive_date_time_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_raw_autocomplete/reactive_raw_autocomplete.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tax_code_flutter/settings.dart';

import '../models/birthplace.dart';
import '../models/contact.dart';
import '../models/tax_code_response.dart';

final class FormPage extends StatefulWidget {
  final Contact? contact;
  const FormPage({super.key, required this.contact});

  @override
  State<StatefulWidget> createState() => _FormPageState();
}

final class _FormPageState extends State<FormPage> {
  final logger = Logger();
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();

  final _form = FormGroup({
    'firstName': FormControl<String>(validators: [Validators.required]),
    'lastName': FormControl<String>(validators: [Validators.required]),
    'gender': FormControl<String>(validators: [Validators.required]),
    'birthDate': FormControl<DateTime>(validators: [Validators.required]),
    'birthPlace': FormControl<Birthplace>(validators: [Validators.required]),
  });

  var contactId = '';
  var _shouldPushForm = false;
  late List<Birthplace> _birthplaces;

  String get _firstName => _form.control('firstName').value;
  String get _lastName => _form.control('lastName').value;
  String get _gender => _form.control('gender').value;
  DateTime get _birthDate => _form.control('birthDate').value;
  Birthplace get _birthPlace => _form.control('birthPlace').value;

  Future<TaxCodeResponse> _fetchTaxCode() async {
    var accessToken = await prefs.getString(Settings.apiAccessTokenKey);
    var baseUri = 'http://api.miocodicefiscale.com/calculate?';
    var params =
        'lname=${_lastName.trim()}&fname=${_firstName.trim()}&gender=$_gender'
        '&city=${_birthPlace.name}&state=${_birthPlace.state}'
        '&day=${_birthDate.day}&month=${_birthDate.month}&year=${_birthDate.year}'
        '&access_token=$accessToken';

    final response = await http.get(Uri.parse('$baseUri$params'));
    if (response.statusCode == 200) {
      return TaxCodeResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'API call to miocodicefiscale.com failed, status code: ${response.statusCode}}');
    }
  }

  Future<String> _loadAsset() async =>
      await rootBundle.loadString('assets/cities.json');

  Future<void> _loadBirthplacesData() async {
    String jsonString = await _loadAsset();
    final birthplaces = jsonDecode(jsonString)
        .map<Birthplace>((json) => Birthplace.fromJson(json))
        .toList();

    setState(() => _birthplaces = birthplaces);
  }

  Future<Contact> _onSubmit() async {
    var response = await _fetchTaxCode();

    return Contact(
      firstName: _firstName.trim(),
      lastName: _lastName.trim(),
      gender: _gender,
      taxCode: response.data.cf,
      birthPlace: _birthPlace,
      birthDate: _birthDate,
    );
  }

  void _setPreviousData() {
    if (widget.contact != null) {
      contactId = widget.contact!.id;
      _form.control('firstName').value = widget.contact?.firstName;
      _form.control('lastName').value = widget.contact?.lastName;
      _form.control('gender').value = widget.contact?.gender;
      _form.control('birthDate').value = widget.contact?.birthDate;
      _form.control('birthPlace').value = widget.contact?.birthPlace;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBirthplacesData();
    _setPreviousData();
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: ReactiveTextField(
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.firstName),
                    formControlName: 'firstName',
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
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
                            decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.birthDate,
                            ),
                            clearIcon: const Icon(Icons.clear),
                            helpText: AppLocalizations.of(context)!.birthDate,
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
                    child: ElevatedButton(
                      child: Text(AppLocalizations.of(context)!.confirm),
                      onPressed: () async {
                        _form.markAllAsTouched();
                        if (_form.valid) {
                          final contact = await _onSubmit();
                          if (context.mounted) {
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
