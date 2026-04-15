import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:reactive_date_time_picker/reactive_date_time_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_raw_autocomplete/reactive_raw_autocomplete.dart';
import 'package:shared/models/birthplace.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:tax_code_flutter/controllers/form_page_controller.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/models/scanned_data.dart';
import 'package:tax_code_flutter/routes.dart';
import 'package:tax_code_flutter/services/birthplace_service.dart';
import 'package:tax_code_flutter/services/tax_code_service.dart';

class FormPage extends StatelessWidget {
  final Contact? contact;
  const FormPage({super.key, this.contact});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FormPageController(
        taxCodeService: context.read<TaxCodeServiceAbstract>(),
        birthplaceService: context.read<BirthplaceServiceAbstract>(),
        contactRepository: context.read<ContactRepository>(),
        logger: context.read<Logger>(),
        initialContact: contact,
      ),
      child: const _FormView(),
    );
  }
}

class _FormView extends StatefulWidget {
  const _FormView();

  @override
  State<_FormView> createState() => _FormViewState();
}

class _FormViewState extends State<_FormView> {
  final _birthplaceFocusNode = FocusNode();
  bool _shouldPushForm = false;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    final controller = context.read<FormPageController>();

    _birthplaceFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _shouldPushForm = _birthplaceFocusNode.hasFocus;
        });
      }
    });

    _initFuture = controller.initialize();

    controller.addListener(() {
      if (controller.errorKey != null && mounted) {
        _showErrorKey(context, controller.errorKey!);
        controller.clearError();
      }
    });
  }

  @override
  void dispose() {
    _birthplaceFocusNode.dispose();
    super.dispose();
  }

  void _showErrorKey(BuildContext context, String errorKey) {
    final l10n = AppLocalizations.of(context)!;
    String message;

    switch (errorKey) {
      case 'rateLimitExceeded':
        message = l10n.rateLimitExceeded;
        break;
      case 'serviceUnavailable':
        message = l10n.serviceUnavailable;
        break;
      case 'networkError':
        message = l10n.networkError;
        break;
      case 'sessionExpired':
        message = l10n.sessionExpired;
        break;
      case 'genericError':
      default:
        message = l10n.genericError;
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.error),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openCameraPage(FormPageController controller) async {
    final scannedData = await Navigator.pushNamed<ScannedData?>(
      context,
      Routes.camera,
    );

    if (scannedData != null) {
      controller.populateFormFromScannedData(scannedData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FormPageController>();
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text(l10n.formPageTitle),
            ),
            body: Center(
              child: _SyncProgressOverlay(
                controller: controller,
                l10n: l10n,
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(l10n.formPageTitle),
          ),
          body: Stack(
            children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: _shouldPushForm
                    ? MediaQuery.of(context).viewInsets.bottom * 0.5
                    : 0,
              ),
              child: SingleChildScrollView(
                child: ReactiveForm(
                  formGroup: controller.form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          child: FilledButton.tonalIcon(
                            onPressed: () => _openCameraPage(controller),
                            icon: const Icon(Symbols.id_card),
                            label: Text(l10n.scanCard),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        child: ReactiveTextField(
                          decoration: InputDecoration(
                            labelText: l10n.firstName,
                          ),
                          formControlName: 'firstName',
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                          textInputAction: TextInputAction.next,
                          validationMessages: {
                            ValidationMessage.required: (error) =>
                                l10n.required,
                            'invalidCharacters': (error) =>
                                l10n.invalidCharacters,
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        child: ReactiveTextField(
                          decoration: InputDecoration(labelText: l10n.lastName),
                          formControlName: 'lastName',
                          onTapOutside: (event) =>
                              FocusScope.of(context).unfocus(),
                          textInputAction: TextInputAction.next,
                          validationMessages: {
                            ValidationMessage.required: (error) =>
                                l10n.required,
                            'invalidCharacters': (error) =>
                                l10n.invalidCharacters,
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: ReactiveDropdownField<String>(
                                formControlName: 'gender',
                                decoration: InputDecoration(
                                  labelText: l10n.gender,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'M',
                                    child: Text('M'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'F',
                                    child: Text('F'),
                                  ),
                                ],
                                validationMessages: {
                                  ValidationMessage.required: (error) =>
                                      l10n.required,
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 7,
                              child: ReactiveDateTimePicker(
                                formControlName: 'birthDate',
                                dateFormat: DateFormat.yMMMMd(
                                  Localizations.localeOf(context).toString(),
                                ),
                                locale: Localizations.localeOf(context),
                                decoration: InputDecoration(
                                  labelText: l10n.birthDate,
                                ),
                                showClearIcon: true,
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                type: ReactiveDatePickerFieldType.date,
                                validationMessages: {
                                  ValidationMessage.required: (error) =>
                                      l10n.required,
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        child: ReactiveRawAutocomplete<Birthplace, Birthplace>(
                          formControlName: 'birthPlace',
                          focusNode: _birthplaceFocusNode,
                          validationMessages: {
                            ValidationMessage.required: (error) =>
                                l10n.required,
                          },
                          optionsBuilder: (value) {
                            if (value.text.length < 2) {
                              return const Iterable<Birthplace>.empty();
                            }
                            return controller.birthplaces
                                .where(
                                  (b) => b.name.toLowerCase().contains(
                                    value.text.toLowerCase(),
                                  ),
                                )
                                .take(20)
                                .toList();
                          },
                          fieldViewBuilder:
                              (
                                BuildContext context,
                                TextEditingController textEditingController,
                                FocusNode focusNode,
                                VoidCallback onFieldSubmitted,
                              ) {
                                final control =
                                    context
                                            .read<FormPageController>()
                                            .form
                                            .control('birthPlace')
                                        as FormControl;

                                return ReactiveValueListenableBuilder(
                                  formControl: control,
                                  builder: (context, control, child) {
                                    final errorText =
                                        control.invalid && control.touched
                                        ? l10n.required
                                        : null;

                                    return TextField(
                                      controller: textEditingController,
                                      focusNode: focusNode,
                                      decoration: InputDecoration(
                                        labelText: l10n.birthPlace,
                                        errorText: errorText,
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            final control = context
                                                .read<FormPageController>()
                                                .form
                                                .control('birthPlace');
                                            textEditingController.clear();
                                            control.value = null;
                                            control.markAsTouched();
                                            FocusScope.of(context).unfocus();
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                          optionsViewBuilder:
                              (
                                BuildContext context,
                                void Function(Birthplace) onSelected,
                                Iterable<Birthplace> options,
                              ) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    elevation: 4.0,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxHeight: 240,
                                      ),
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount: options.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                              final birthplace = options
                                                  .elementAt(index);
                                              return InkWell(
                                                onTap: () {
                                                  onSelected(birthplace);
                                                  FocusScope.of(
                                                    context,
                                                  ).unfocus();
                                                },
                                                child: ListTile(
                                                  title: Text(
                                                    '${birthplace.name} (${birthplace.state})',
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                );
                              },
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          child: FilledButton(
                            onPressed:
                                (controller.form.valid && !controller.isLoading)
                                ? () async {
                                    final contact = await controller
                                        .submitForm();
                                    if (context.mounted && contact != null) {
                                      Navigator.pop<Contact>(context, contact);
                                    }
                                  }
                                : null,
                            child: Text(l10n.confirm),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (controller.isLoading ||
              (controller.downloadStep != null &&
                  _birthplaceFocusNode.hasFocus))
            Container(
              color: Colors.black54,
              child: Center(
                child: _SyncProgressOverlay(
                  controller: controller,
                  l10n: l10n,
                ),
              ),
            ),
        ],
          ),
        );
      },
    );
  }
}
class _SyncProgressOverlay extends StatelessWidget {
  final FormPageController controller;
  final AppLocalizations l10n;

  const _SyncProgressOverlay({
    required this.controller,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingBirthplaces) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.birthplacesDownloadTitle,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                controller.downloadStep == 'checking'
                    ? l10n.stepBirthplacesChecking
                    : controller.downloadStep == 'downloading'
                    ? l10n.stepBirthplacesDownloading
                    : controller.downloadStep == 'generating'
                    ? l10n.stepBirthplacesGenerating
                    : controller.downloadStep == 'parsing'
                    ? l10n.stepBirthplacesParsing
                    : l10n.stepBirthplacesChecking,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (controller.downloadProgress != null)
                LinearProgressIndicator(value: controller.downloadProgress)
              else
                const LinearProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return const CircularProgressIndicator();
  }
}
