import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../screens/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<void> saveUserData(User user) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    final userData = {
      'uid': user.uid,
      'displayName': user.displayName ?? '',
      'email': user.email ?? '',
      'phoneNumber': user.phoneNumber ?? '',
      'photoURL': user.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    };

    await userRef.set(userData, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    // ToDo Regenerate
    // final clientId ='';

    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return SignInScreen(
              showAuthActionSwitch: false,
              providers: [GoogleProvider(clientId: '')], // ToDo add clientId
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

          final user = snapshot.data;
          if (user != null) {
            Future.microtask(() async => await saveUserData(user));
          }

          return HomePage();
        });
  }
}
