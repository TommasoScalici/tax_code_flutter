import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SizedBox(
              child: Column(
            children: [
              Text(
                contact.taxCode,
                style: taxCodeTextStyle,
              ),
              Text(
                '${contact.firstName} ${contact.lastName} (${contact.gender})',
                style: valueTextStyle,
              ),
              Text(
                '${contact.birthPlace.name} (${contact.birthPlace.state})',
                style: valueTextStyle,
              ),
              Text(
                DateFormat.yMd(Localizations.localeOf(context).toString())
                    .format(contact.birthDate),
                style: valueTextStyle,
              )
            ],
          )),
        ));
  }
}
