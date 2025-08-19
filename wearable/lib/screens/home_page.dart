import 'package:flutter/material.dart';
import 'package:tax_code_flutter_wear_os/widgets/contacts_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Padding(padding: EdgeInsets.all(20.0), child: ContactsList()),
    );
  }
}
