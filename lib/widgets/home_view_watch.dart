import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter/models/birthplace.dart';
import 'package:tax_code_flutter/models/contact.dart';
import 'package:tax_code_flutter/widgets/contact_card_watch.dart';
import 'package:wear/wear.dart';

import '../providers/app_state.dart';

class HomeViewWatch extends StatelessWidget {
  const HomeViewWatch({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
        builder: (BuildContext context, AppState value, Widget? child) {
      return WatchShape(
          builder: (BuildContext context, WearShape shape, Widget? child) {
        final isRound = shape == WearShape.round;

        final contacts = [
          Contact(
              firstName: 'Tommaso',
              lastName: 'Scalici',
              gender: 'M',
              taxCode: 'SCLTMS91L18G273O',
              birthPlace: Birthplace(name: 'Palermo', state: 'PA'),
              birthDate: DateTime(1991, 7, 18)),
          Contact(
              firstName: 'Carla',
              lastName: 'Craparotta',
              gender: 'F',
              taxCode: 'TestTestTest',
              birthPlace: Birthplace(name: 'Mazara del Vallo', state: 'TP'),
              birthDate: DateTime(1999, 2, 5))
        ];

        return Padding(
          padding: isRound ? EdgeInsets.all(20) : EdgeInsets.all(10),
          child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ContactCardWatch(contact: contact),
              );
            },
          ),
        );
      });
    });
  }
}
