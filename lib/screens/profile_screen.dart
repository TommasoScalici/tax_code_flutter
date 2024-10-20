import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  Future<void> _showConfirmationDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteConfirmation),
          content: Text(AppLocalizations.of(context)!.deleteAccountMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                final currentUser = auth.currentUser;

                if (currentUser != null) {
                  final uid = currentUser.uid;
                  await firestore.collection('users').doc(uid).delete();
                  await currentUser.delete();

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: Text(
                AppLocalizations.of(context)!.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.appTitle),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              UserAvatar(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  auth.currentUser!.displayName!,
                  style: TextStyle(fontSize: 24),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await auth.signOut();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  icon: Icon(Icons.logout),
                  label: Text(AppLocalizations.of(context)!.signOut),
                ),
              ),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _showConfirmationDialog(context);

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(Icons.delete),
                    label: Text(
                      AppLocalizations.of(context)!.deleteAccount,
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      iconColor: Colors.white,
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
