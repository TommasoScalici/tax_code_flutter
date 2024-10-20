import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../screens/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<void> saveUserData(User user) async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final userRef = usersCollection.doc(user.uid);
    final userSnapshot = await userRef.get();

    final userData = {
      'id': user.uid,
      'displayName': user.displayName ?? '',
      'email': user.email ?? '',
      'photoURL': user.photoURL ?? '',
      'lastLogin': FieldValue.serverTimestamp(),
    };

    if (!userSnapshot.exists ||
        !userSnapshot.data()!.containsKey('createdAt')) {
      userData['createdAt'] = FieldValue.serverTimestamp();
    }

    await userRef.set(userData, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final clientId =
        '1006489964692-qh5i60jgn4nqqlplqmt6tnvb6vmccgrt.apps.googleusercontent.com';

    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return SignInScreen(
              showAuthActionSwitch: false,
              providers: [GoogleProvider(clientId: clientId)],
              headerBuilder: (context, constraints, shrinkOffset) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child:
                              Image.asset('assets/images/app_icon_512x512.png'),
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.appTitle,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 36),
                      ),
                    ],
                  ),
                );
              },
              subtitleBuilder: (context, action) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: action == AuthAction.signIn
                      ? Text(AppLocalizations.of(context)!.pleaseSignIn)
                      : Text(AppLocalizations.of(context)!.pleaseSignUp),
                );
              },
              footerBuilder: (context, action) {
                return Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.termsAndCondition,
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(AppLocalizations.of(context)!.showTerms),
                    ],
                  ),
                );
              },
              sideBuilder: (context, shrinkOffset) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset('assets/images/app_icon_512x512.png'),
                  ),
                );
              },
            );
          }

          if (snapshot.hasData) {
            final user = snapshot.data;
            if (user != null) {
              Future.microtask(() async {
                if (context.mounted) {
                  final appState = context.read<AppState>();
                  await saveUserData(user);
                  await appState.loadContacts();
                }
              });
            }
          }

          return HomePage();
        });
  }
}
