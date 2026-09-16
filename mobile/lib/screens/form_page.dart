import 'package:logger/logger.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/models/scanned_data.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:shared/services/birthplace_service.dart';
import 'package:shared/services/tax_code_service.dart';
import 'package:tax_code_flutter/controllers/form_page_controller.dart';
import 'package:tax_code_flutter/l10n/l10n.dart';
import 'package:tax_code_flutter/routes.dart';
import 'package:tax_code_flutter/utils/error_dialog_helper.dart';
import 'package:tax_code_flutter/widgets/form/birthdate_picker_field.dart';
import 'package:tax_code_flutter/widgets/form/birthplace_autocomplete_field.dart';
import 'package:tax_code_flutter/widgets/form/custom_text_field.dart';
import 'package:tax_code_flutter/widgets/form/form_section_divider.dart';
import 'package:tax_code_flutter/widgets/form/form_sticky_bottom_bar.dart';
import 'package:tax_code_flutter/widgets/form/gender_segmented_button.dart';
import 'package:tax_code_flutter/widgets/form/ocr_ai_hero_banner.dart';
import 'package:tax_code_flutter/widgets/form/tax_code_live_preview_card.dart';
import 'package:tax_code_flutter/widgets/responsive_layout.dart';

/// Screen for creating a new Italian Tax Code or editing an existing contact.
///
/// Fully modernized with OCR AI scanner hero banner, segmented gender selector,
/// formatted date picker, reactive birthplace autocomplete, real-time live preview
/// calculation card, and sticky bottom action bar.
class FormPage extends StatelessWidget {
  /// The contact to edit, or null when creating a new tax code.
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

    _initFuture = controller.initializationFuture;

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
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final title = controller.isEditing
        ? l10n.editTaxCodeTitle
        : l10n.newTaxCodeTitle;

    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevation: 0,
              scrolledUnderElevation: 0,
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => Navigator.maybePop(context),
            ),
            title: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          bottomNavigationBar: FormStickyBottomBar(
            labelText: l10n.saveCode,
            isEnabled: controller.form.valid && !controller.isLoading,
            isLoading: controller.isLoading,
            onPressed: (controller.form.valid && !controller.isLoading)
                ? () async {
                    final contact = await controller.submitForm();
                    if (context.mounted && contact != null) {
                      Navigator.pop<Contact>(context, contact);
                    }
                  }
                : null,
          ),
          body: Stack(
            children: [
              ResponsiveLayout(
                maxWidth: 520.0,
                padding: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: _shouldPushForm
                        ? MediaQuery.of(context).viewInsets.bottom * 0.5
                        : 0,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: ReactiveForm(
                      formGroup: controller.form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Smart OCR AI Scanner Hero Banner (only on creation)
                          if (!controller.isEditing) ...[
                            OcrAiHeroBanner(
                              onScanPressed: () => _openCameraPage(controller),
                            ),
                            const SizedBox(height: 18),
                            const FormSectionDivider(),
                            const SizedBox(height: 18),
                          ],

                          // First Name field
                          CustomTextField(
                            formControlName: 'firstName',
                            labelText: l10n.firstName,
                            placeholder: l10n.firstNamePlaceholder,
                            validationMessages: {
                              ValidationMessage.required: (_) => l10n.required,
                              'invalidCharacters': (_) =>
                                  l10n.invalidCharacters,
                            },
                          ),
                          const SizedBox(height: 16),

                          // Last Name field
                          CustomTextField(
                            formControlName: 'lastName',
                            labelText: l10n.lastName,
                            placeholder: l10n.lastNamePlaceholder,
                            validationMessages: {
                              ValidationMessage.required: (_) => l10n.required,
                              'invalidCharacters': (_) =>
                                  l10n.invalidCharacters,
                            },
                          ),
                          const SizedBox(height: 16),

                          // Gender selector
                          GenderSegmentedButton(
                            formControlName: 'gender',
                            labelText: l10n.gender,
                          ),
                          const SizedBox(height: 16),

                          // Birth Date field
                          BirthdatePickerField(
                            formControlName: 'birthDate',
                            labelText: l10n.birthDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          ),
                          const SizedBox(height: 16),

                          // Birth Place field
                          BirthplaceAutocompleteField(
                            formControlName: 'birthPlace',
                            focusNode: _birthplaceFocusNode,
                            labelText: l10n.birthPlace,
                            birthplaces: controller.birthplaces,
                          ),
                          const SizedBox(height: 20),

                          // Real-time calculated Tax Code preview card
                          TaxCodeLivePreviewCard(
                            taxCode: controller.calculatedTaxCode,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Fullscreen loading overlay when submitting form
              if (controller.isLoading)
                const ModalBarrier(
                  dismissible: false,
                  color: Colors.black26,
                ),
              if (controller.isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),

              // Database sync progress overlay
              if (controller.downloadStep != null &&
                  _birthplaceFocusNode.hasFocus)
                ColoredBox(
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
