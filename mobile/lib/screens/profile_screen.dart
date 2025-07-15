import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tax_code_flutter/i18n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _deleteUser(BuildContext context) async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final currentUser = auth.currentUser;
    final logger = Logger();

    if (currentUser != null) {
      final uid = currentUser.uid;
      final userDocRef = firestore.collection('users').doc(uid);
      final contactsRef = userDocRef.collection('contacts');
      final querySnapshot = await contactsRef.get();

      try {
        final batch = firestore.batch();

        for (var doc in querySnapshot.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
        await userDocRef.delete();
        await currentUser.delete();
        if (context.mounted) Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        logger.e(
            'Error while deleting user, probably needs to reauthenticate: $e');
      }
    }
  }

  Future<void> _showDeleteUserConfirmDialog(BuildContext context) async {
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
              onPressed: () async => await _deleteUser(context),
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
    final auth = FirebaseAuth.instance;

    final displayName =
        auth.currentUser != null && auth.currentUser?.displayName != null
            ? auth.currentUser!.displayName!
            : '';

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
                  displayName,
                  style: TextStyle(fontSize: 24),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await auth.signOut();
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: Icon(Icons.logout),
                  label: Text(AppLocalizations.of(context)!.signOut),
                ),
              ),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async =>
                        await _showDeleteUserConfirmDialog(context),
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
