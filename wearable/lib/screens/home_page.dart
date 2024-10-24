import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/providers/app_state.dart';
import 'package:tax_code_flutter_wear_os/screens/auth_gate.dart';

import '../widgets/contact_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    _auth.authStateChanges().listen((User? user) {
      if (user == null && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
          (Route<dynamic> route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, value, child) {
      final isRound = MediaQuery.of(context).size.width ==
          MediaQuery.of(context).size.height;
      return FutureBuilder(
        future: value.loadContacts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            backgroundColor: Colors.black,
            body: Padding(
              padding: isRound ? EdgeInsets.all(20.0) : EdgeInsets.all(10.0),
              child: Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: value.contacts.length,
                  itemBuilder: (context, index) {
                    final contact = value.contacts[index];
                    return Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: ContactCard(contact: contact));
                  },
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
