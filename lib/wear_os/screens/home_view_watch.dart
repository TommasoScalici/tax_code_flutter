import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tax_code_flutter/wear_os/widgets/contact_card.dart';

import '../../providers/app_state.dart';

class HomeViewWatch extends StatelessWidget {
  const HomeViewWatch({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, value, child) {
      final isRound = MediaQuery.of(context).size.width ==
          MediaQuery.of(context).size.height;
      return Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: isRound ? EdgeInsets.all(20) : EdgeInsets.all(10),
          child: ListView.builder(
            itemCount: value.contacts.length,
            itemBuilder: (context, index) {
              final contact = value.contacts[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ContactCardWatch(contact: contact),
              );
            },
          ),
        ),
      );
    });
  }
}
