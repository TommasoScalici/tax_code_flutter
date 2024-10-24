import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' hide ProfileScreen;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared/providers/app_state.dart';
import 'package:uni_links3/uni_links.dart';

import 'home_page.dart';
import 'profile_screen.dart';
import '../widgets/info_modal.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    initUniLinks();
  }

  Future<void> initUniLinks() async {
    final auth = FirebaseAuth.instance;
    await getInitialLink();
    linkStream.listen((String? link) async {
      if (link != null &&
          link.isNotEmpty &&
          link.contains('tax_code/delete-account.html')) {
        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    auth.currentUser != null ? ProfileScreen() : AuthGate()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final clientId =
        '1006489964692-qta6uauft2ou6jlhotd2u8o3ilv2nfvt.apps.googleusercontent.com';

    final screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return SignInScreen(
              showAuthActionSwitch: false,
              resizeToAvoidBottomInset: true,
              providers: [GoogleProvider(clientId: clientId)],
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
          }

          if (snapshot.hasData) {
            final user = snapshot.data;
            if (user != null) {
              Future.microtask(() async {
                if (context.mounted) {
                  final appState = context.read<AppState>();
                  await appState.saveUserData(user);

                  if (context.mounted) {
                    await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => HomePage()));
                  }
                }
              });
            }
          }

          return CircularProgressIndicator();
        });
  }
}
