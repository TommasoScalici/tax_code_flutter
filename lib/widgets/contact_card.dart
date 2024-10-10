import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  final _intl = Intl.getCurrentLocale();
  final _taxCodeTextStyle = const TextStyle(
      color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700);
  final _valueTextStyle = const TextStyle(fontWeight: FontWeight.w600);

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
                      style: _taxCodeTextStyle,
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
                                widget.contact.firstName,
                                style: _valueTextStyle,
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text('${AppLocalizations.of(context)!.lastName}: '),
                            Flexible(
                              child: Text(
                                widget.contact.lastName,
                                style: _valueTextStyle,
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text('${AppLocalizations.of(context)!.gender}: '),
                            Flexible(
                              child: Text(
                                widget.contact.gender,
                                style: _valueTextStyle,
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
                                DateFormat.yMd(_intl)
                                    .format(widget.contact.birthDate),
                                style: _valueTextStyle,
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
                                widget.contact.birthPlace.toString(),
                                style: _valueTextStyle,
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
                              value.editContact(
                                  editedContact, widget.contact.id);
                              await value.saveState();
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
