import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tax_code_flutter/screens/barcode_page.dart';

import '../models/contact.dart';

class ContactCardWatch extends StatelessWidget {
  const ContactCardWatch({super.key, required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final valueTextStyle = TextStyle(
        color: Theme.of(context).colorScheme.surfaceBright, fontSize: 10);
    final taxCodeTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.inversePrimary,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    return Card(
        color: Theme.of(context).colorScheme.primary,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BarcodePage(taxCode: contact.taxCode),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
                child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    contact.taxCode,
                    style: taxCodeTextStyle,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${contact.firstName} ${contact.lastName} (${contact.gender})',
                    style: valueTextStyle,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${contact.birthPlace.name} (${contact.birthPlace.state})',
                    style: valueTextStyle,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    DateFormat.yMd(Localizations.localeOf(context).toString())
                        .format(contact.birthDate),
                    style: valueTextStyle,
                  ),
                )
              ],
            )),
          ),
        ));
  }
}
