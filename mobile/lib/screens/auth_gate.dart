import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' hide ProfileScreen;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';

import '../settings.dart';
import '../widgets/info_modal.dart';
import 'home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final remoteConfig = context.read<FirebaseRemoteConfig>();
    final screenWidth = MediaQuery.of(context).size.width;

    if (authService.isSignedIn) {
      return const HomePage();
    }

    return SignInScreen(
      showAuthActionSwitch: false,
      resizeToAvoidBottomInset: true,
      providers: [
        GoogleProvider(
          clientId: remoteConfig.getString(Settings.googleProviderClientId),
        )
      ],
      headerMaxExtent: screenWidth < 300 ? 0 : null,
      headerBuilder: (context, constraints, shrinkOffset) {
        return const _LoginHeader();
      },
      subtitleBuilder: (context, action) {
        return _LoginSubtitle(action: action, screenWidth: screenWidth);
      },
      footerBuilder: (context, action) {
        return _LoginFooter(screenWidth: screenWidth);
      },
      sideBuilder: (context, shrinkOffset) {
        return const _LoginSideImage();
      },
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset('assets/images/app_icon_512x512.png'),
              ),
            ),
          ),
          Text(
            l10n.appTitle,
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 36),
          ),
        ],
      ),
    );
  }
}

class _LoginSubtitle extends StatelessWidget {
  const _LoginSubtitle({required this.action, required this.screenWidth});

  final AuthAction action;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (screenWidth < 300) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: action == AuthAction.signIn
          ? Text(l10n.pleaseSignIn)
          : Text(l10n.pleaseSignUp),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter({required this.screenWidth});

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          Text(
            l10n.termsAndCondition,
            style: const TextStyle(color: Colors.grey),
          ),
          if (screenWidth >= 300)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const InfoModal(),
                );
              },
              child: Text(l10n.showTerms),
            ),
        ],
      ),
    );
  }
}

class _LoginSideImage extends StatelessWidget {
  const _LoginSideImage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: const AspectRatio(
          aspectRatio: 1,
          child: Image(
            image: AssetImage('assets/images/app_icon_512x512.png'),
          ),
        ),
      ),
    );
  }
}