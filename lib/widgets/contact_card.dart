import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tax_code_flutter/providers/app_state.dart';
import 'package:tax_code_flutter/widgets/form.dart';

import '../models/contact.dart';

final class ContactCard extends StatefulWidget {
  final Contact contact;

  const ContactCard({super.key, required this.contact});

  @override
  State<StatefulWidget> createState() => _ContactCardState();
}

final class _ContactCardState extends State<ContactCard> {
  final intl = Intl.getCurrentLocale();
  final taxCodeTextStyle = const TextStyle(
      color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700);
  final valueTextStyle = const TextStyle(fontWeight: FontWeight.w600);

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
                await context.read<AppState>().saveState();

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
    return Consumer<AppState>(
      builder: (BuildContext context, AppState value, Widget? child) {
        return SizedBox(
          width: 400,
          child: Material(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
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
                  tileColor: const Color.fromARGB(128, 38, 128, 0),
                  title: Center(
                    child: Text(
                      widget.contact.taxCode,
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
                            const Text('Nome: '),
                            Text(
                              widget.contact.firstName,
                              style: valueTextStyle,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Cognome: '),
                            Text(
                              widget.contact.lastName,
                              style: valueTextStyle,
                            )
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Sesso: '),
                            Text(
                              widget.contact.sex,
                              style: valueTextStyle,
                            )
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Data di nascita: '),
                            Text(
                              DateFormat.yMd(intl)
                                  .format(widget.contact.birthDate),
                              style: valueTextStyle,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Luogo di nascita: '),
                            Text(
                              widget.contact.birthPlace.toString(),
                              style: valueTextStyle,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () => Share.share(widget.contact.taxCode),
                          icon: const Icon(Icons.share)),
                      IconButton(
                          onPressed: () async {
                            final editedContact = await Navigator.push<Contact>(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FormPage(contact: widget.contact)),
                            );

                            if (editedContact != null) {
                              value.editContact(editedContact);
                            }
                          },
                          icon: const Icon(Icons.edit)),
                      IconButton(
                          onPressed: () =>
                              _showConfirmationDialog(context, widget.contact),
                          icon: const Icon(Icons.delete)),
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
