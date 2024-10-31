import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/providers/app_state.dart';

import '../screens/barcode_page.dart';
import '../screens/form_page.dart';

final class ContactCard extends StatelessWidget {
  final Contact contact;

  const ContactCard({super.key, required this.contact});

  void _showConfirmationDialog(BuildContext context, Contact contact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteConfirmation),
          content: Text(
              AppLocalizations.of(context)!.deleteMessage(contact.taxCode)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                context.read<AppState>().removeContact(contact);
                await context.read<AppState>().saveContacts();

                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final valueTextStyle = const TextStyle(fontWeight: FontWeight.w600);
    final taxCodeTextStyle = TextStyle(
        color: Theme.of(context).colorScheme.surface,
        fontSize: 22,
        fontWeight: FontWeight.w700);

    return Consumer<AppState>(
      builder: (BuildContext context, AppState value, Widget? child) {
        return SizedBox(
          width: 400,
          child: Material(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.surfaceBright,
            elevation: 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  tileColor: Theme.of(context).colorScheme.primary,
                  title: Center(
                    child: Text(
                      contact.taxCode,
                      style: taxCodeTextStyle,
                    ),
                  ),
                ),
                ListTile(
                  title: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                                '${AppLocalizations.of(context)!.firstName}: '),
                            Flexible(
                              child: Text(
                                contact.firstName,
                                style: valueTextStyle,
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text('${AppLocalizations.of(context)!.lastName}: '),
                            Flexible(
                              child: Text(
                                contact.lastName,
                                style: valueTextStyle,
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text('${AppLocalizations.of(context)!.gender}: '),
                            Flexible(
                              child: Text(
                                contact.gender,
                                style: valueTextStyle,
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                                '${AppLocalizations.of(context)!.birthDate}: '),
                            Flexible(
                              child: Text(
                                DateFormat.yMd(Localizations.localeOf(context)
                                        .toString())
                                    .format(contact.birthDate),
                                style: valueTextStyle,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                                '${AppLocalizations.of(context)!.birthPlace}: '),
                            Flexible(
                              child: Text(
                                contact.birthPlace.toString(),
                                style: valueTextStyle,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, bottom: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => Share.share(contact.taxCode),
                        icon: const Icon(Icons.share),
                      ),
                      IconButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BarcodePage(taxCode: contact.taxCode),
                            ),
                          );
                        },
                        icon: Icon(Symbols.barcode),
                      ),
                      IconButton(
                        onPressed: () async {
                          final editedContact = await Navigator.push<Contact>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FormPage(contact: contact),
                            ),
                          );

                          if (editedContact != null) {
                            final contactToUpdate = value.contacts
                                .firstWhere((c) => c.id == editedContact.id);
                            contactToUpdate.updateFrom(editedContact);
                            value.updateContacts(value.contacts);
                            await value.saveContacts();
                          }
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () =>
                            _showConfirmationDialog(context, contact),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
