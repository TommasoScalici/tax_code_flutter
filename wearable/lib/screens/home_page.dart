import 'package:flutter/material.dart';
import 'package:tax_code_flutter_wear_os/widgets/contact_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: const ContactList(),
      ),
    );
  }
}
