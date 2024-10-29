import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' hide ProfileScreen;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared/providers/app_state.dart';

import '../settings.dart';
import 'home_page.dart';
import '../widgets/info_modal.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final remoteConfig = FirebaseRemoteConfig.instance;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<AppState>(
      builder: (context, value, child) {
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.hasData) {
              return const HomePage();
            }

            return SignInScreen(
              showAuthActionSwitch: false,
              resizeToAvoidBottomInset: true,
              actions: [
                AuthStateChangeAction<SignedIn>((context, state) {
                  final user = state.user;
                  if (user != null) {
                    final appState = context.read<AppState>();
                    appState.saveUserData(user);
                  }
                })
              ],
              providers: [
                GoogleProvider(
                    clientId:
                        remoteConfig.getString(Settings.googleProviderClientId))
              ],
              headerMaxExtent: screenWidth < 300 ? 0 : null,
              headerBuilder: (context, constraints, shrinkOffset) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.asset(
                                'assets/images/app_icon_512x512.png'),
                          ),
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
                return screenWidth < 300
                    ? SizedBox.shrink()
                    : Padding(
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
                      screenWidth < 300
                          ? SizedBox.shrink()
                          : TextButton(
                              onPressed: () async {
                                await showDialog(
                                    context: context,
                                    builder: (context) => const InfoModal());
                              },
                              child: Text(
                                AppLocalizations.of(context)!.showTerms,
                              ),
                            ),
                    ],
                  ),
                );
              },
              sideBuilder: (context, shrinkOffset) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset('assets/images/app_icon_512x512.png'),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
