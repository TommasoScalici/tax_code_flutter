import 'package:flutter/material.dart';

import '../models/contact.dart';

final class ContactCard extends StatefulWidget {
  final Contact contact;

  const ContactCard({super.key, required this.contact});

  @override
  State<StatefulWidget> createState() => _ContactCardState();
}

final class _ContactCardState extends State<ContactCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(widget.contact.taxCode),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nome: ${widget.contact.firstName}'),
                Text('Cognome: ${widget.contact.lastName}'),
                Text('Sesso: ${widget.contact.sex}'),
                Text('Data di nascita: ${widget.contact.birthDate}'),
                Text('Luogo di nascita: ${widget.contact.birthPlace}')
              ],
            ),
          ),
        ],
      ),
    );
  }
}
