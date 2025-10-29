import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Handles the full account deletion flow, including re-authentication.
  Future<void> _performDeleteAccount({
    required NavigatorState navigator,
    required AuthService authService,
    required Logger logger,
    required ScaffoldMessengerState scaffoldMessenger,
    required AppLocalizations l10n,
  }) async {
    if (navigator.canPop()) {
      navigator.pop();
    }

    try {
      await authService.deleteUserAccount();

      if (!navigator.mounted) return;
      navigator.popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e, s) {
      if (e.code == 'requires-recent-login') {
        logger.w('Requires recent login. Prompting for re-auth.');

        final reauthenticated = await authService.reauthenticateWithGoogle();

        if (reauthenticated) {
          try {
            await authService.deleteUserAccount();
            if (!navigator.mounted) return;
            navigator.popUntil((route) => route.isFirst);
          } catch (e2, s2) {
            logger.e(
              'Failed to delete account AFTER re-auth',
              error: e2,
              stackTrace: s2,
            );
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text(l10n.genericError)),
            );
          }
        } else {
          logger.w('Re-authentication cancelled or failed.');
          if (authService.errorMessage != null && scaffoldMessenger.mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text(authService.errorMessage!)),
            );
          }
        }
      } else {
        logger.e(
          'FirebaseAuthException while deleting',
          error: e,
          stackTrace: s,
        );
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(l10n.genericError)),
        );
      }
    } catch (e, s) {
      logger.e('Generic error deleting user account', error: e, stackTrace: s);
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.genericError)),
      );
    }
  }

  Future<void> _showDeleteUserConfirmDialog(BuildContext context) async {
    final authService = context.read<AuthService>();
    final logger = context.read<Logger>();
    final l10n = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteConfirmation),
          content: Text(l10n.deleteAccountMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => _performDeleteAccount(
                navigator: navigator,
                authService: authService,
                logger: logger,
                scaffoldMessenger: scaffoldMessenger,
                l10n: l10n,
              ),
              child: Text(
                l10n.delete,
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
    final authService = context.watch<AuthService>();
    final l10n = AppLocalizations.of(context)!;
    final displayName = authService.currentUser?.displayName ?? '';
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.profilePageTitle),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const UserAvatar(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    displayName,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await authService.signOut();
                        if (context.mounted) {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        }
                      } catch (e) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text(l10n.genericError)),
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: Text(l10n.signOut),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteUserConfirmDialog(context),
                    icon: const Icon(Icons.delete),
                    label: Text(
                      l10n.deleteAccount,
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      iconColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
