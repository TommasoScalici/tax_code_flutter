import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:shared/models/contact.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';

final class ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onShare;
  final VoidCallback onShowBarcode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onShare,
    required this.onShowBarcode,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final valueTextStyle = const TextStyle(fontWeight: FontWeight.w600);
    final taxCodeTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.surface,
      fontSize: 22,
      fontWeight: FontWeight.w700,
    );

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
                child: Text(contact.taxCode, style: taxCodeTextStyle),
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
                        Text('${l10n.firstName}: '),
                        Flexible(
                          child: Text(contact.firstName, style: valueTextStyle),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('${l10n.lastName}: '),
                        Flexible(
                          child: Text(contact.lastName, style: valueTextStyle),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('${l10n.gender}: '),
                        Flexible(
                          child: Text(contact.gender, style: valueTextStyle),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('${l10n.birthDate}: '),
                        Flexible(
                          child: Text(
                            DateFormat.yMd(
                              Localizations.localeOf(context).toString(),
                            ).format(contact.birthDate),
                            style: valueTextStyle,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('${l10n.birthPlace}: '),
                        Flexible(
                          child: Text(
                            contact.birthPlace.toString(),
                            style: valueTextStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: onShare,
                    icon: const Icon(Icons.share),
                    tooltip: l10n.tooltipShare,
                  ),
                  IconButton(
                    onPressed: onShowBarcode,
                    icon: const Icon(Symbols.barcode),
                    tooltip: l10n.tooltipShowBarcode,
                  ),
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    tooltip: l10n.tooltipEdit,
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete),
                    tooltip: l10n.tooltipDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
