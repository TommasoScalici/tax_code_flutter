import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
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

        return Padding(
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
        );
      });
    });
  }
}
