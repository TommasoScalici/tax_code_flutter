import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared/services/auth_service.dart';
import 'package:tax_code_flutter/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _showRequiresRecentLoginDialog(
    BuildContext context,
    AuthService authService,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.actionRequired),
          content: Text(l10n.requiresRecentLoginMessage),
          actions: [
            TextButton(
              onPressed: () async {
                await authService.signOut();
                if (dialogContext.mounted) {
                  Navigator.of(
                    dialogContext,
                  ).popUntil((route) => route.isFirst);
                }
              },
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
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
              onPressed: () async {
                try {
                  await authService.deleteUserAccount();
                  if (!navigator.mounted) return;
                  navigator.popUntil((route) => route.isFirst);
                } on FirebaseAuthException catch (e, s) {
                  logger.e(
                    'Error deleting user account: requires-recent-login',
                    error: e,
                    stackTrace: s,
                  );
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();
                  if (e.code == 'requires-recent-login') {
                    await _showRequiresRecentLoginDialog(context, authService);
                  } else {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text(l10n.genericError)),
                    );
                  }
                } catch (e, s) {
                  logger.e(
                    'Generic error deleting user account',
                    error: e,
                    stackTrace: s,
                  );
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(l10n.genericError)),
                  );
                }
              },
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
