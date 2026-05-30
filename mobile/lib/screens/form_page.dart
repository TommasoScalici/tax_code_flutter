import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:reactive_date_time_picker/reactive_date_time_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/models/scanned_data.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/birthplace_service.dart';
import 'package:shared/services/tax_code_service.dart';

import 'package:tax_code_flutter/controllers/form_page_controller.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';
import 'package:tax_code_flutter/routes.dart';
import 'package:tax_code_flutter/utils/error_dialog_helper.dart';
import 'package:tax_code_flutter/widgets/form/birthplace_autocomplete.dart';
import 'package:tax_code_flutter/widgets/form/custom_text_field.dart';
import 'package:tax_code_flutter/widgets/form/gender_dropdown.dart';

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
        ErrorDialogHelper.showErrorDialog(context, controller.errorKey!);
        controller.clearError();
      }
    });
  }

  @override
  void dispose() {
    _birthplaceFocusNode.dispose();
    super.dispose();
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
                        child: CustomTextField(
                          formControlName: 'firstName',
                          labelText: l10n.firstName,
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
                        child: CustomTextField(
                          formControlName: 'lastName',
                          labelText: l10n.lastName,
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
                              child: GenderDropdown(
                                formControlName: 'gender',
                                labelText: l10n.gender,
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
                        child: BirthplaceAutocomplete(
                          formControlName: 'birthPlace',
                          focusNode: _birthplaceFocusNode,
                          labelText: l10n.birthPlace,
                          requiredMessage: l10n.required,
                          birthplaces: controller.birthplaces,
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
